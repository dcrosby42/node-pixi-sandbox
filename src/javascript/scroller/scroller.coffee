Far = require './far'
Mid = require './mid'

class Scroller
  constructor: (stage) ->
    @far = new Far()
    @mid = new Mid()
    @viewportX = 0

    stage.addChild @far
    stage.addChild @mid

  getViewportX: ->
    @viewportX

  setViewportX: (x) ->
    @viewportX = x
    @far.setViewportX(x)
    @mid.setViewportX(x)

  moveViewportXBy: (x) ->
    @setViewportX @viewportX + x
    
module.exports = Scroller
