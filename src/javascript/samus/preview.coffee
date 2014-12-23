PIXI = require 'pixi.js'

_ = require 'lodash'

class SamusPreview
  constructor: ->

  graphicsToPreload: ->
    [
      "images/samus.json"
    ]

  setupStage: (@stage) ->
    @spritesByName = @collectSprites()
    window.sprites = @spritesByName

    @layoutAllSprites(@spritesByName)
    @stage.interactive = true
    @stage.mousedown = (data) ->
      console.log "STAGE MOUSEDOWN", data

  layoutAllSprites: (sprites) ->
    topEdge = 0
    leftEdge = 0
    rightEdge = 512
    console.log "rightEdge: #{rightEdge}"
    cursorX = leftEdge
    cursorY = topEdge
    for name,sprite of sprites
      if cursorX + sprite.width > rightEdge
        cursorX = 0
        cursorY += sprite.height + 10
      sprite.position.x = cursorX
      sprite.position.y = cursorY
      @stage.addChild sprite
      # console.log "Added #{name} @ x=#{cursorX}"
      cursorX += sprite.width

  collectSprites: ->
    byName = {}
    for i in [0..28]
      snum = @_lpad("00", i)
      fname = "samus1-#{snum}-00"
      sprite = PIXI.Sprite.fromFrame(fname)
      sprite.interactive = true
      sprite.mousedown = (data) ->
        console.log "SPRITE MOUSEDOWN", data
      sprite.scale.x = 2
      sprite.scale.y = 2
      byName[fname] = sprite
    byName

  update: ->

  ################

  _lpad: (fmt,num) ->
    str = ""+num
    fmt.substring(0,fmt.length - str.length) + str



module.exports = SamusPreview

