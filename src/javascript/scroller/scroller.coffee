Far = require './far'
Mid = require './mid'
Walls = require './walls'

class Scroller
  constructor: (stage) ->
    @far = new Far()
    @mid = new Mid()
    @front = new Walls()
    @viewportX = 0

    stage.addChild @far
    stage.addChild @mid
    stage.addChild @front

  getViewportX: ->
    @viewportX

  setViewportX: (x) ->
    @viewportX = x
    @far.setViewportX(x)
    @mid.setViewportX(x)
    @front.setViewportX(x)

  moveViewportXBy: (x) ->
    @setViewportX @viewportX + x
    
module.exports = Scroller
