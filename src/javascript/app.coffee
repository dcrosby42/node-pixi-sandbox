# View =  require './view'
# view = new View(el: '#content')
# console.log 'app.js loaded!'
#
jquery = require 'jquery'
PIXI = require 'pixi.js'
Scroller = require './scroller/scroller'

scroller = null
renderer = null
stage = null

update = ->
  scroller.update()
  renderer.render(stage)
  requestAnimationFrame(update)

  
init = ->

  stage = new PIXI.Stage(0x66FF99)
  renderer = PIXI.autoDetectRenderer(
    512,
    384
  )
  jquery('#game-holder').append(renderer.view)
  
  scroller = new Scroller(stage)

  requestAnimationFrame update

jquery ->
  init()
