PIXI = require 'pixi.js'

constructor = (texture,width,height) ->
  texture = PIXI.Texture.fromImage("images/bg-far.png")
  PIXI.TilingSprite.call(this, texture, 512, 256)
  this.position.x = 0
  this.position.y = 0
  this.tilePosition.x = 0
  this.tilePosition.y = 0

Far = constructor
Far.constructor = constructor
Far.prototype = Object.create(PIXI.TilingSprite.prototype)

module.exports = Far
