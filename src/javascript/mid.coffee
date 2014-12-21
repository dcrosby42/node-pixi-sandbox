PIXI = require 'pixi.js'

class Mid extends PIXI.TilingSprite
  constructor: ->
    texture = PIXI.Texture.fromImage("images/bg-mid.png")
    super texture, 512, 256
    @position.x = 0
    @position.y = 128
    @tilePosition.x = 0
    @tilePosition.y = 0

module.exports = Mid
