
DebugShapes =
  dot: ({color}) ->
    color ||= 0x00FF00
    dot = new PIXI.Graphics()
    dot.lineStyle(0.5,color)
    dot.drawCircle(0,0,radius)
    dot
    
module.exports = DebugShapes
