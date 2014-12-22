PIXI = require 'pixi.js'

Scroller = require './scroller'
WallSpritesPool = require './wall_sprites_pool'

class Main
  @STAGE_BG: 0x66FF99
  @WIDTH: 512
  @HEIGHT: 384
  @SCROLL_SPEED: 5

  constructor: ({@domElement})->
    @stage = new PIXI.Stage(Main.STAGE_BG)
    @width = Main.WIDTH
    @height = Main.HEIGHT
    @renderer = PIXI.autoDetectRenderer(@width,@height)
    @domElement.appendChild @renderer.view
    @setRendererSize width: @width, height: @height # seems redundant but the renderer has its own idea about how many pixels it renders, but we can "stretch" the canvas in the DOM to be different
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


  #
  # So outsiders can resize the game:
  #

  getRendererSize: ->
    { width: @width, height: @height }

  setRendererSize: ({@width,@height})->
    @renderer.view.style.width = "#{@width}px"
    @renderer.view.style.height = "#{@height}px"

  getRendererView: ->
    @renderer.view

module.exports = Main
