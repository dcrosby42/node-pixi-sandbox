# View =  require './view'
# view = new View(el: '#content')
# console.log 'app.js loaded!'
#
jquery = require 'jquery'
PIXI = require 'pixi.js'
Far = require './far'
Mid = require './mid'

far = null
mid = null
renderer = null
stage = null

update = ->
  far.tilePosition.x -= 0.128
  mid.tilePosition.x -= 0.64
  renderer.render(stage)
  requestAnimationFrame(update)

  
init = ->

  stage = new PIXI.Stage(0x66FF99)
  renderer = PIXI.autoDetectRenderer(
    512,
    384
  )
  jquery('#game-holder').append(renderer.view)
  

  far = new Far()
  stage.addChild(far)

  # midTexture = PIXI.Texture.fromImage("/images/bg-mid.png")
  # mid = new PIXI.TilingSprite(midTexture,512,256)
  # mid.position.x = 0
  # mid.position.y = 128
  # mid.tilePosition.x = 0
  # mid.tilePosition.y = 0
  mid = new Mid()
  stage.addChild(mid)

  requestAnimationFrame update

window.initGame = init

# jquery ->
#   init()
