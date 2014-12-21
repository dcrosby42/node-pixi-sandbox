PIXI = require 'pixi.js'

class Far extends PIXI.TilingSprite
  constructor: ->
    texture = PIXI.Texture.fromImage("images/bg-far.png")
    super texture, 512, 256
    @position.x = 0
    @position.y = 0
    @tilePosition.x = 0
    @tilePosition.y = 0

  update: ->
    @tilePosition.x -= 0.128

module.exports = Far
