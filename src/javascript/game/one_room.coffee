PIXI = require 'pixi.js'
_ = require 'lodash'
$ = require 'jquery'

Mousetrap = require '../vendor/mousetrap_wrapper'
window.wtf = Mousetrap

KeyboardController = require '../keyboard_controller'

AnimatedSprite = require '../animated_sprite'

SamusSprites = require('../entity/samus/sprites')
window.ss = SamusSprites

class OneRoom
  constructor: ->

  graphicsToPreload: ->
    [
      SamusSprites.samus.spriteSheet
      "images/room0_blank.png"
    ]

  setupStage: (@stage, width, height) ->
    # 
    # Base container:
    #
    base = new PIXI.DisplayObjectContainer()
    base.scale.set(2.5,2)
    @stage.addChild base

    #
    # Map container:
    #
    @mapLayer = new PIXI.DisplayObjectContainer()
    base.addChild @mapLayer

    @sampleMapBg = PIXI.Sprite.fromFrame("images/room0_blank.png")
    @mapLayer.addChild @sampleMapBg
    
    #
    # Main sprite layer:
    #
    @spriteLayer = new PIXI.DisplayObjectContainer()
    base.addChild @spriteLayer

    #
    # Overlay layer:
    #
    @overlay = new PIXI.DisplayObjectContainer()
    base.addChild @overlay

    @samus = @createSamus()
    window.samus = @samus
    @spriteLayer.addChild @samus.ui.sprite

    @setupInput()

    window.stage = @stage

  setupInput: ->
    # Mousetrap.bind 'z', => @stand()
    @samusController = new KeyboardController
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'jump'
      "s": 'shoot'

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
    oldState = animComp.state
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

    if animComp.state != oldState
      animComp.time = 0
    else
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
    ui.sprite.displayAnimation animComp.state, animComp.time
    ui.sprite.position.set posComp.x, posComp.y

  update: (dt) ->
    @updateSamus(dt)

  updateSamus: (dt) ->
    c = @samus.components
    @updateControls  c.controls, @samusController.update()
    @updateMotion    c.motion, c.controls, dt
    @updateCharacter c.character, c.controls
    @updatePosition  c.position, c.motion
    @updateAnimation c.animation, c.character, dt
    
    @syncUI @samus.ui, c.position, c.animation

  createSamus: ->
    e = {}
    e.ui =
      sprite: AnimatedSprite.create(SamusSprites.samus)

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

module.exports = OneRoom

