Far = require './far'
Mid = require './mid'

class Scroller
  constructor: (stage) ->
    @far = new Far()
    @mid = new Mid()

    stage.addChild @far
    stage.addChild @mid

  update: ->
    @far.update()
    @mid.update()

    
module.exports = Scroller
