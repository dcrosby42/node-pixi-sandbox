PIXI = require 'pixi.js'

class PixiHarness
  constructor: ({@domElement, @delegate, stage_background, width, height})->
    @stage = new PIXI.Stage(stage_background)
    @renderer = PIXI.autoDetectRenderer(width,height)
    @view = @renderer.view
    @domElement.appendChild @view

  start: ->
    assets = @delegate.graphicsToPreload()
    loader = new PIXI.AssetLoader(assets)
    loader.onComplete = =>
      console.log "Assets loaded."
      @delegate.setupStage @stage
      requestAnimationFrame => @update()
    console.log "Loading assets..."
    loader.load()

  update: ->
    @delegate.update()
    @renderer.render(@stage)
    requestAnimationFrame => @update()

module.exports = PixiHarness
