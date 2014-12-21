PIXI = require 'pixi.js'
jquery = require 'jquery'

Scroller = require './scroller'
WallSpritesPool = require './wall_sprites_pool'

class Main
  @STAGE_BG: 0x66FF99
  @WIDTH: 512
  @HEIGHT: 384
  @SCROLL_SPEED: 5

  constructor: ({@domElement})->
    @stage = new PIXI.Stage(Main.STAGE_BG)
    @renderer = PIXI.autoDetectRenderer(Main.WIDTH, Main.HEIGHT)
    @domElement.appendChild @renderer.view
    @loadSpriteSheet()

  update: ->
    @scroller.moveViewportXBy(Main.SCROLL_SPEED)
    @renderer.render(@stage)
    requestAnimationFrame => @update()

  loadSpriteSheet: ->
    assetsToLoad = [
      "images/wall.json"
      "images/bg-far.png"
      "images/bg-mid.png"
    ]
    loader = new PIXI.AssetLoader(assetsToLoad)
    loader.onComplete = => @spriteSheetLoaded()
    loader.load()

  spriteSheetLoaded: ->
    @scroller = new Scroller(@stage)
    requestAnimationFrame => @update()

    @pool = new WallSpritesPool()
    @wallSlices = []

  generateTestWallSpan: ->
    lookupTable = [
      @pool.borrowFrontEdge
      @pool.borrowWindow
      @pool.borrowDecoration
      @pool.borrowWindow
      @pool.borrowDecoration
      @pool.borrowWindow
      @pool.borrowBackEdge
    ]
    for borrowFunc,i in lookupTable
      sprite = borrowFunc.call(@pool)
      sprite.position.x = 32 + (i*64)
      sprite.position.y = 128
      @wallSlices.push sprite
      @stage.addChild sprite

  clearTestWallSpan: ->
    lookupTable = [
      @pool.returnFrontEdge
      @pool.returnWindow
      @pool.returnDecoration
      @pool.returnWindow
      @pool.returnDecoration
      @pool.returnWindow
      @pool.returnBackEdge
    ]
    for returnFunc,i in lookupTable
      sprite = @wallSlices[i]
      returnFunc.call(@pool,sprite)
      @stage.removeChild sprite

    @wallSlices = []

        

module.exports = Main
