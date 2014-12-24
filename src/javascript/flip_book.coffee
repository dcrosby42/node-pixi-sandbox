PIXI = require 'pixi.js'
_    = require 'lodash'

class FlipBook extends PIXI.DisplayObjectContainer
  constructor: (spritesByName,{@defaultFrame}={}) ->
    super
    @sprites = _.clone(spritesByName)
    for sprite in _.values(@sprites)
      sprite.x = 0
      sprite.y = 0
      sprite.visible = false
      @addChild sprite

    ##

    # @dots = {}
    # cornercolor = 0x00ff00
    # @dots.ul = @mkdot(1,cornercolor)
    # @dots.ur = @mkDot(1,cornerColor)
    # @dots.ll = @mkDot(1,cornerColor)
    # @dots.lr = @mkDot(1,cornerColor)

    ##
    @defaultFrame ||= _.keys(@sprites)[0]
    @showingFrame = null
    @showFrame(@defaultFrame)

  mkDot: (radius, color) ->
    dot = new PIXI.Graphics()
    dot.lineStyle(0.5,color)
    dot.drawCircle(0,0,radius)
    @addChild(dot)

  updateDots: (sprite) ->
    # b = sprite.getBounds()
    # console.log "Updating dots to meet bounds:",b
    # @dots.ul.position.set b.x, b.y
    # console.log "  ul: #{@dots.ul.position.x}, #{@dots.ul.position.y}"
    # @dots.ur.position.set b.x+b.width, b.y
    # @dots.ll.position.set b.x, b.y+b.height
    # @dots.lr.position.set b.x+b.width, b.y+b.height

  showFrame: (name) ->
    return if name == @showingFrame
    nextSprite = @sprites[name]
    if nextSprite
      nextSprite.visible = true
      @showingSprite = nextSprite
      @updateDots(@showingSprite)
      if @showingFrame
        if oldSprite = @sprites[@showingFrame]
          oldSprite.visible = false
      @showingFrame = name
      console.log "FlipBook showingFrame: #{@showingFrame}"
    else
      console.log "FlipBook error: can't find a sprite for frame '#{name}'"

  
module.exports = FlipBook
#
# flipX = (fr) -> { frame: fr, mod: {"scale.x": -1} }
# flipY = (fr) -> { frame: fr, mod: {"scale.y": -1} }
#
# {
#   stand_right: 4,
#   run_right: [6, 7, 8],
#   stand_shoot_right: 18,
#   run_shoot_right: { kind: 'animation', frames: [flipX(19), flipX(20), flipX(21)] },
#   stand_shoot_right: 18,
#
#
