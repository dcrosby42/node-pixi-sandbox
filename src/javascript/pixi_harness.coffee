PIXI = require 'pixi.js'
StopWatch = require './stop_watch'

class PixiHarness
  constructor: ({@domElement, @delegate, stage_background, width, height})->
    @stage = new PIXI.Stage(stage_background)
    @renderer = PIXI.autoDetectRenderer(width,height)
    @view = @renderer.view
    @domElement.appendChild @view
    @stopWatch = new StopWatch()


  start: ->
    assets = @delegate.graphicsToPreload()
    loader = new PIXI.AssetLoader(assets)
    loader.onComplete = =>
      console.log "Assets loaded."
      @delegate.setupStage @stage
      @stopWatch.start()
      requestAnimationFrame => @update()

    console.log "Loading assets..."
    loader.load()

  update: ->
    dt = @stopWatch.lapInSeconds()
    @delegate.update(dt)
    @renderer.render(@stage)
    requestAnimationFrame => @update()

module.exports = PixiHarness
