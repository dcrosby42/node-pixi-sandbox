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

  borrowWallSprites: (num) ->
    sprites = [
      @pool.borrowDecoration()
      @pool.borrowWindow()
      @pool.borrowBackEdge()
      @pool.borrowFrontEdge()
      @pool.borrowDecoration()
      @pool.borrowWindow()
      @pool.borrowBackEdge()
    ]
    for sprite,i in sprites
      sprite.position.x = -32 + (i * 64)
      sprite.position.y = 128
      @wallSlices.push(sprite)
      @stage.addChild(sprite)

  returnWallSprites: ->
    for i in [0...@wallSlices.length]
      sprite = @wallSlices[i]
      @stage.removeChild(sprite)
      if i % 2 == 0
        @pool.returnBackEdge(sprite)
      else
        @pool.returnDecoration(sprite)
        
    @wallSlices = []

    # slice1 = PIXI.Sprite.fromFrame("edge_01")
    # slice1.position.x = 32
    # slice1.position.y = 64
    # @stage.addChild(slice1)
    #
    # slice2 = PIXI.Sprite.fromFrame("decoration_03")
    # slice2.position.x = 128
    # slice2.position.y = 64
    # @stage.addChild(slice2)


module.exports = Main
