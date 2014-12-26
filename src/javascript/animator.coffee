Timeline = require './timeline'

class Animator
  constructor: (@spriteDeck, @animations) ->

  display: (state, time=0) ->
    timeline = @animations[state]
    if timeline
      i = timeline.itemAtTime(time)
      @spriteDeck.display(state,i)

  @create: (spriteDeck, config) ->
    animations = []
    _.forOwn config.states, (data,state) ->
      frames = if data.frames?
        data.frames
      else
        [ data.frame ]

      frameDelayMillis = 1000 / data.fps
      frameIndices = _.range(0,frames.length)
      timeline = Timeline.createTimedEvents(frameDelayMillis, frameIndices, true)
      animations[state] = timeline
    new Animator(spriteDeck, animations)

module.exports = Animator
