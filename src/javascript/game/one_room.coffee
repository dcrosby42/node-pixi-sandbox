PIXI = require 'pixi.js'
_ = require 'lodash'
$ = require 'jquery'

Mousetrap = require '../vendor/mousetrap_wrapper'
window.wtf = Mousetrap

KeyboardController = require '../keyboard_controller'

SamusSprites = require('./entity/samus/sprites')

EntityStore    = require '../ecs/entity_store'
SystemRegistry = require '../ecs/system_registry'

C = require './entity/components'

Systems = require './systems'

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

    @estore = new EntityStore()

    @samusId = @createSamus(@estore)

    @setupSpriteConfigs()

    @setupSystems()

    @setupInput()
    
    window.me = @
    window.estore = @estore
    window.samusId = @samusId
    window.stage = @stage

  setupInput: ->
    @input =
      controllers:
        player1: {}

    @p1Controller = new KeyboardController
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'jump'
      "s": 'shoot'

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
        container: @spriteLayer ]
    ]

  update: (dt) ->
    @input.controllers.player1 = @p1Controller.update()

    @systemsRunner.run @estore, dt, @input
    # for system in @systems
    #   system.run(@estore, dt, @input)
    
  createSamus: (estore) ->
    e = estore.newEntity()

    estore.addComponent e, new C.Samus
      action: 'standing' # standing | running | jumping | falling
      direction: 'right' # right | left
      aim: 'straight' # up | straight
    estore.addComponent e, new C.Position(x: 50, y: 208)
    estore.addComponent e, new C.Movement()
    estore.addComponent e, new C.Controller(inputName: 'player1')
    estore.addComponent e, new C.Visual
      spriteName: 'samus'
      state: 'stand-right'
      time: 0

    e

module.exports = OneRoom

