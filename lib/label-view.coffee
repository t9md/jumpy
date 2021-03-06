class LabelView extends HTMLElement
  initialize: ({labelPreference, @editorView, label, @position}) ->
    {fontSize, highContrast} = labelPreference
    @classList.add 'jumpy', 'label'
    @classList.add 'high-contrast' if highContrast

    @style.fontSize = fontSize
    @textContent = label
    @editor = @editorView.getModel()
    this

  flash: ->
    range = @editor.getLastCursor().getCurrentWordBufferRange()
    marker = @editor.markBufferRange range,
      invalidate: 'never'
      persistent: false

    decoration = @editor.decorateMarker marker,
      type: 'highlight'
      class: "jumpy-beacon"

    timeoutID = setTimeout  =>
      decoration.getMarker().destroy()
    , 150

  jump: ->
    atom.workspace.paneForItem(@editor).activate()
    if (@editor.getSelections().length is 1) and (not @editor.getLastSelection().isEmpty())
      @editor.selectToScreenPosition @position
    else
      @editor.setCursorScreenPosition @position

    if atom.config.get('jumpy.useHomingBeaconEffectOnJumps')
      @flash()
    # console.log "Jumpy jumped to: '#{@textContent}' at #{@position.toString()}"

  attachedCallback: ->
    px = @editorView.pixelPositionForScreenPosition @position
    scrollLeft = @editor.getScrollLeft()
    scrollTop  = @editor.getScrollTop()
    @style.left  = "#{px.left - scrollLeft}px"
    @style.top   = "#{px.top - scrollTop}px"

  reset: ->
    @classList.remove 'irrelevant'

  unMatch: ->
    @classList.add 'irrelevant'

  destroy: ->
    @remove()

module.exports = document.registerElement 'jumpy-label',
  prototype: LabelView.prototype
  extends:   'div'
