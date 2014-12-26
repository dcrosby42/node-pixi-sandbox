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

    # Mousetrap.bind 'w', => @cursorUp()
    # Mousetrap.bind 'a', => @cursorLeft()
    # Mousetrap.bind 's', => @cursorDown()
    # Mousetrap.bind 'd', => @cursorRight()
    # Mousetrap.bind 'z', => @stand()

    @keyboardController = new KeyboardController
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'jump'
      "s": 'shoot'

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


    # [@samus,@samusAnim] = @createSamus()
    @samus = @createSamus()

    # @samus.position.set 50, 208
    # @samus.display("stand-right")
    @spriteLayer.addChild @samus.ui.spriteDeck


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

  updateCharacter: (charComp, controlsComp) ->
    if controlsComp.left
      charComp.direction = 'left'
      charComp.action = 'running'
    else if controlsComp.right
      charComp.direction = 'right'
      charComp.action = 'running'
    else
      charComp.action = 'standing'

  updateAnimation: (animComp, charComp, dt) ->
    if charComp.action == 'running'
      if charComp.direction == 'left'
        animComp.state = 'run-left'
      else
        animComp.state = 'run-right'
    else if charComp.action == 'standing'
      if charComp.direction == 'left'
        animComp.state = 'stand-left'
      else
        animComp.state = 'stand-right'

    animComp.time += dt

  updateControls: (comp, kbUpdate) ->
    comp = _.merge(comp,kbUpdate)

  updateMotion: (motionComp, controlsComp, dt) ->
    motionComp.x = 0
    motionComp.y = 0

    speed = (44 / dt) * 0.75
    if controlsComp.right
      motionComp.x = speed
    else if controlsComp.left
      motionComp.x = -speed

  updatePosition: (posComp, motionComp) ->
    posComp.x += motionComp.x
    posComp.y += motionComp.y

  syncUI: (ui, posComp, animComp) ->
    ui.animator.display animComp.state, animComp.time
    ui.spriteDeck.position.set posComp.x, posComp.y

  update: (dt) ->
    keyboardUpdate = @keyboardController.update()

    @updateControls @samus.components.controls, keyboardUpdate
    @updateMotion @samus.components.motion, @samus.components.controls, dt
    @updateCharacter @samus.components.character, @samus.components.controls
    @updatePosition @samus.components.position, @samus.components.motion
    @updateAnimation @samus.components.animation, @samus.components.character, dt
    
    @syncUI @samus.ui, @samus.components.position, @samus.components.animation


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
    e = {}
    e.ui = {}
    sd = SpriteDeck.create(config)
    e.ui.spriteDeck = sd
    e.ui.animator = Anim.create(sd, config)

    e.components = {}

    e.components.character =
      type: 'character'
      action: 'standing' # standing | running | jumping | falling
      direction: 'right' # right | left
      aim: 'straight' # up | straight
      
    e.components.motion =
      type: 'action'
      x: 0
      y: 0

    e.components.position =
      type: 'position'
      x: 50
      y: 208

    e.components.controls =
      type: 'controls'
      left: false
      right: false
      up: false
      down: false
      jump: false
      shoot: false

    e.components.animation =
      type: 'animation'
      state: 'stand-right'
      time: 0

    e



module.exports = SamusPreview

