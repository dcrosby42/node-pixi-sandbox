class StopWatch
  constructor: ->

  start: ->
    @startMillis = @currentTimeMillis()
    @millis = @startMillis

  lapInSeconds: ->
    newMillis = @currentTimeMillis()
    lapMillis = newMillis - @millis
    @millis = newMillis
    lapMillis / 1000.0

  currentTimeMillis: ->
    new Date().getTime()

  elapsedSeconds: ->
    (@currentTimeMillis() - @startMillis)/1000.0


module.exports = StopWatch
