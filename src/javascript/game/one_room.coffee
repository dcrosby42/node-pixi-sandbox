PIXI = require 'pixi.js'
_ = require 'lodash'
# $ = require 'jquery'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

EntityStore    = require '../ecs/entity_store'
SystemRegistry = require '../ecs/system_registry'

SamusSprites = require('./entity/samus/sprites')
C = require './entity/components'

Systems = require './systems'

# Visual config block
#  -> load assets
#  -> create AnimatedSprite (SpriteDeck and timelines)
#
# Entity factory: put all the parts together to make an Entity
# Systems

# TODO: Add Skree 
# TODO: aim-up
# TODO: shooting sprites
# TODO: bullets
# TODO: Sounds: running, shooting
# TODO: map 
# TODO: map+motion collision detection
# TODO: jumping
# TODO: Add Skree 
class OneRoom
  constructor: ->

  graphicsToPreload: ->
    [
      SamusSprites.samus.spriteSheet
      "images/room0_blank.png"
    ]

  setupStage: (@stage, width, height) ->
    @layers = @setupLayers()

    @sampleMapBg = PIXI.Sprite.fromFrame("images/room0_blank.png")
    @layers.map.addChild @sampleMapBg

    @estore = new EntityStore()

    @samusId = @createSamus(@estore)

    @setupSpriteConfigs()

    @setupSystems()

    @setupInput()
    
    @timeDilation = 1

    window.me = @
    window.estore = @estore
    window.samusId = @samusId
    window.stage = @stage

  setupLayers: ->
    base = new PIXI.DisplayObjectContainer()
    base.scale.set(2.5,2) # double size, and stretch the actual nintendo 256 px to look like 320

    map = new PIXI.DisplayObjectContainer()

    creatures = new PIXI.DisplayObjectContainer()

    overlay = new PIXI.DisplayObjectContainer()

    @stage.addChild base
    base.addChild map
    base.addChild creatures
    base.addChild overlay

    {
      base: base
      map: map
      creatures: creatures
      overlay: overlay
      default: creatures
    }

  setupInput: ->
    @input =
      controllers:
        player1: {}
        player2: {}
        admin: {}

    @keyboardController = new KeyboardController
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'jump'
      "s": 'shoot'

    @adminController = new KeyboardController
      "g": 'toggle_gamepad'

    @gamepadController = new GamepadController
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'jump'
      "FACE_3": 'shoot'

    @useGamepad = false
    @p1Controller = @keyboardController

  setupSpriteConfigs: ->
    @spriteConfigs = {}
    _.merge @spriteConfigs, SamusSprites

    @spriteLookupTable = {}

  setupSystems: ->
    @systemsRunner = Systems.sequence [
      'controller'
      'samus_motion'
      'samus_animation'
      'movement'
      ['sprite_sync',
        spriteConfigs: @spriteConfigs
        spriteLookupTable: @spriteLookupTable
        layers: @layers ]
    ]

  update: (dt) ->
    @handleAdminControls()
      
    @input.controllers.player1 = @p1Controller.update()
    # @input.controllers.player2 = @p2Controller.update()


    @systemsRunner.run @estore, dt*@timeDilation, @input

  handleAdminControls: ->
    ac = @adminController.update()
    if ac and ac.toggle_gamepad
      @useGamepad = !@useGamepad
      if @useGamepad
        @p1Controller = @gamepadController
        console.log "Switched to gamepad control"
      else
        @p1Controller = @keyboardController
        console.log "Switched to keyboard control"
    
  createSamus: (estore) ->
    e = estore.newEntity()

    estore.addComponent e, new C.Samus
      action: 'standing' # standing | running | jumping | falling
      direction: 'right' # right | left
      aim: 'straight' # up | straight
      runSpeed: 88/1000 # 88 px/sec
    estore.addComponent e, new C.Position(x: 50, y: 208)
    estore.addComponent e, new C.Movement()
    estore.addComponent e, new C.Controller(inputName: 'player1')
    estore.addComponent e, new C.Visual
      layer: 'creatures'
      spriteName: 'samus'
      state: 'stand-right'
      time: 0

    e

module.exports = OneRoom

