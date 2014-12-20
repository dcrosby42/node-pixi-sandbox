# View =  require './view'
# view = new View(el: '#content')
# console.log 'app.js loaded!'
#
jquery = require 'jquery'
PIXI = require 'pixi.js'

far = null
mid = null
renderer = null
stage = null

update = ->
  far.position.x -= 0.128
  mid.position.x -= 0.64
  renderer.render(stage)
  requestAnimationFrame(update)

  
init = ->
  canvas = document.getElementById("game-canvas")
  console.log canvas

  stage = new PIXI.Stage(0x66FF99)
  renderer = PIXI.autoDetectRenderer(
    512,
    384,
    document.getElementById("game-canvas")
  )

  farTexture = PIXI.Texture.fromImage("images/bg-far.png")
  far = new PIXI.TilingSprite(farTexture,512,256)
  far.position.x = 0
  far.position.y = 0
  far.tilePosition.x = 0
  far.tilePosition.y = 0
  stage.addChild(far)

  midTexture = PIXI.Texture.fromImage("/images/bg-mid.png")
  mid = new PIXI.TilingSprite(midTexture,512,256)
  mid.position.x = 0
  mid.position.y = 128
  mid.tilePosition.x = 0
  mid.tilePosition.y = 0
  stage.addChild(mid)

  requestAnimationFrame update

window.initGame = init

# jquery ->
#   init()
