
class SamusAnimationSystem
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      visual = estore.getComponent(samus.eid, 'visual')
      oldState = visual.state
      if samus.action == 'running'
        if samus.direction == 'left'
          visual.state = 'run-left'
        else
          visual.state = 'run-right'
      else if samus.action == 'standing'
        if samus.direction == 'left'
          visual.state = 'stand-left'
        else
          visual.state = 'stand-right'

        if samus.aim == 'up'
          visual.state += '-aim-up'

      if visual.state != oldState
        visual.time = 0
      else
        visual.time += dt

module.exports = SamusAnimationSystem
