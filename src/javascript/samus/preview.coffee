PIXI = require 'pixi.js'
FlipBook = require "../flip_book"
SpriteDeck = require "../sprite_deck"
_ = require 'lodash'
$ = require 'jquery'
DebugShapes = require '../debug_shapes'
Mousetrap = require '../vendor/mousetrap_wrapper'
window.wtf = Mousetrap

KeyboardController = require '../keyboard_controller'

Timeline = require '../timeline'
window.Timeline = Timeline

class Cycle
  constructor: (arr) ->
    @_items = _.clone(arr)
    @_i = 0
    @_length = @_items.length
  
  next: ->
    x = @_items[@_i]
    @_i += 1
    @_i = 0 if @_i >= @_length
    x


class Anim
  constructor: (@spriteDeck, @animations) ->

  display: (state,time=0) ->
    timeline = @animations[state]
    if timeline
      i = timeline.itemAtTime(time)
      @spriteDeck.display(state,i)

  @create: (spriteDeck, config) ->
    animations = []
    _.forOwn config.states, (data,state) ->
      frames = if data.frames?
        data.frames
      else
        [ data.frame ]

      frameDelayMillis = 1000 / data.fps
      frameIndices = _.range(0,frames.length)
      timeline = Timeline.createTimedEvents(frameDelayMillis, frameIndices, true)
      animations[state] = timeline
    new Anim(spriteDeck, animations)


    



class SamusPreview
  constructor: ->

  setupInput: ->
    $('#d-pad-right').on "click", =>
      @buttonRight()
    $('#reset').on "click", =>
      @reset()
    # Mousetrap.bind 'right', => @buttonRight()
    Mousetrap.bind 'r', => @reset()

    Mousetrap.bind 'w', => @cursorUp()
    Mousetrap.bind 'a', => @cursorLeft()
    Mousetrap.bind 's', => @cursorDown()
    Mousetrap.bind 'd', => @cursorRight()
    Mousetrap.bind 'z', => @stand()

    @keyboardController = new KeyboardController
      "right": 'runRight'
      "left": 'runLeft'

  graphicsToPreload: ->
    [
      @samusData().spriteSheet
      "images/room0.png"
    ]

  slice: (col,keys) ->
    _.pick col, (v,k) -> _.contains(keys,k)

  setupStage: (@stage) ->

    @mapLayer = new PIXI.DisplayObjectContainer()
    @mapLayer.scale.set(1.25,1)
    @stage.addChild @mapLayer

    @sampleMapBg = PIXI.Sprite.fromFrame("images/room0.png")
    @mapLayer.addChild @sampleMapBg
    
    @spriteLayer = new PIXI.DisplayObjectContainer()
    @spriteLayer.scale.set(2.5,2)
    @stage.addChild @spriteLayer

    @overlay = new PIXI.DisplayObjectContainer()
    @overlay.scale.set(2.5,2)
    @stage.addChild @overlay


    @cursor = @createCursor()
    @overlay.addChild(@cursor)


    [@samus,@samusAnim] = @createSamus()

    @samus.position.set 50, 208
    # @samus.display("stand-right")
    @spriteLayer.addChild @samus

    @samusAnimComponent = { state: 'stand-right', time: 0 }

    @setupInput()

    window.samus = @samus
    window.samusAnim = @samusAnim
    window.samusAnimComponent = @samusAnimComponent

    window.stage = @stage

  # layoutAllSprites: (sprites) ->
  #   topEdge = 0
  #   leftEdge = 0
  #   rightEdge = 512
  #   console.log "rightEdge: #{rightEdge}"
  #   cursorX = leftEdge
  #   cursorY = topEdge
  #   for name,sprite of sprites
  #     if cursorX + sprite.width > rightEdge
  #       cursorX = 0
  #       cursorY += sprite.height + 10
  #     sprite.position.x = cursorX
  #     sprite.position.y = cursorY
  #     @stage.addChild sprite
  #     cursorX += sprite.width


  createCursor: ->
    cursor = new PIXI.Graphics()
    cursor.lineStyle(1, 0x9999FF)
    cursor.drawRect(-5,-5,10,10)
    cursor.moveTo(0,0).lineTo(-5,0).moveTo(0,0).lineTo(0,-5).moveTo(0,0).lineTo(5,0).moveTo(0,0).lineTo(0,5)
    cursor.position.set(0,0)
    cursor

  update: (dt) ->
    controls = @keyboardController.update()
    console.log controls if controls

    @samusAnimComponent.time += dt

    if @keyboardController.isActive('runLeft')
      @samusAnimComponent.state = 'run-left'
      @face = 'left'
    else if @keyboardController.isActive('runRight')
      @samusAnimComponent.state = 'run-right'
      @face = 'right'
    else
      @samusAnimComponent.state = if @face == 'left'
        'stand-left'
      else
        'stand-right'

    
    @samusAnim.display(@samusAnimComponent.state, @samusAnimComponent.time)

  cursorTo: (pos) ->
    @cursor.position.set(pos.x,pos.y)

  cursorUp: ->
    @cursor.y -= 10
    @showCursorPosition()
  cursorLeft: ->
    @cursor.x -= 10
    @showCursorPosition()
  cursorDown: ->
    @cursor.y += 10
    @showCursorPosition()
  cursorRight: ->
    @cursor.x += 10
    @showCursorPosition()

  showCursorPosition: ->
    #console.log "CURSOR: #{@cursor.x},#{@cursor.y}"

  samusData: ->
    spriteSheet: "images/samus.json"
    states:
      "stand-right":
        frame: "samus1-04-00"
      "run-right":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
      "stand-left":
        frame: "samus1-04-00"
        modify:
          scale: { x: -1 }
      "run-left":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
        modify:
          scale: { x: -1 }
    modify:
      anchor: { x: 0.5, y: 1 }

  createSamus: ->
    config = @samusData()
    samus = SpriteDeck.create config
    anim = Anim.create(samus, config)
    [samus,anim]



module.exports = SamusPreview

