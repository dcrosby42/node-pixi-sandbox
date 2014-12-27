PIXI = require 'pixi.js'
_ = require 'lodash'
$ = require 'jquery'

Mousetrap = require '../vendor/mousetrap_wrapper'
window.wtf = Mousetrap

KeyboardController = require '../keyboard_controller'

AnimatedSprite = require '../animated_sprite'

SamusSprites = require('./entity/samus/sprites')


EntityStore = require '../ecs/entity_store'
C = require './entity/components'

ArrayToCacheBinding = require '../utils/array_to_cache_binding'

class ControllerSystem
  run: (estore, dt, input) ->
    for controller in estore.getComponentsOfType('controller')
      if input.controllers and ins = input.controllers[controller.inputName]
        states = controller.states
        _.forOwn ins, (val,key) ->
          states[key] = val

class SamusMotionSystem
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      controller = estore.getComponent(samus.eid, 'controller')
      movement = estore.getComponent(samus.eid, 'movement')
      
      movement.x = 0
      movement.y = 0

      speed = (44 / dt) * 0.75
      if controller.states.right
        movement.x = speed
        samus.direction = 'right'
        samus.action = 'running'
      else if controller.states.left
        samus.direction = 'left'
        samus.action = 'running'
        movement.x = -speed
      else
        samus.action = 'standing'

class SamusAnimationSystem
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      visual = estore.getComponent(samus.eid, 'visual')
      oldState = visual.state
      if samus.action == 'running'
        if samus.direction == 'left'
          visual.state = 'run-left'
        else
          visual.state = 'run-right'
      else if samus.action == 'standing'
        if samus.direction == 'left'
          visual.state = 'stand-left'
        else
          visual.state = 'stand-right'

      if visual.state != oldState
        visual.time = 0
      else
        visual.time += dt


class MovementSystem
  run: (estore, dt, input) ->
    for movement in estore.getComponentsOfType('movement')
      position = estore.getComponent(movement.eid, 'position')

      position.x += movement.x
      position.y += movement.y
  
class SpriteSyncSystem
  constructor: ({@spriteConfigs, @spriteLookupTable, @container}) ->

  run: (estore, dt, input) ->
    visuals = estore.getComponentsOfType('visual')
    ArrayToCacheBinding.update
      source: visuals
      cache: @spriteLookupTable
      identKey: 'eid'
      addFn: (visual) =>
        config = @spriteConfigs[visual.spriteName]
        sprite = AnimatedSprite.create(config)
        @container.addChild sprite
        sprite
      removeFn: (sprite) =>
        @container.removeChild sprite
      syncFn: (visual,sprite) =>
        pos = estore.getComponent(visual.eid, 'position')
        sprite.displayAnimation visual.state, visual.time
        sprite.position.set pos.x, pos.y


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
    @systems = [
      new ControllerSystem()
      new SamusMotionSystem()
      new SamusAnimationSystem()
      new MovementSystem()
      new SpriteSyncSystem(
        spriteConfigs: @spriteConfigs
        spriteLookupTable: @spriteLookupTable
        container: @spriteLayer
      )
    ]

  update: (dt) ->
    @input.controllers.player1 = @p1Controller.update()

    for system in @systems
      system.run(@estore, dt, @input)
    
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

