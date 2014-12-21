PIXI = require 'pixi.js'
jquery = require 'jquery'

Scroller = require './scroller'

class Main
  @STAGE_BG: 0x66FF99
  @WIDTH: 512
  @HEIGHT: 384
  @SCROLL_SPEED: 5

  constructor: ->
    @stage = new PIXI.Stage(Main.STAGE_BG)
    @scroller = new Scroller(@stage)

    @renderer = PIXI.autoDetectRenderer(Main.WIDTH, Main.HEIGHT)

    jquery('#game-holder').append(@renderer.view)
    requestAnimationFrame => @update()

  update: ->
    @scroller.moveViewportXBy(Main.SCROLL_SPEED)
    @renderer.render(@stage)
    requestAnimationFrame => @update()

module.exports = Main
