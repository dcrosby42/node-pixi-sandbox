class SamusMotionSystem
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      controller = estore.getComponent(samus.eid, 'controller')
      movement = estore.getComponent(samus.eid, 'movement')

      movement.x = 0
      movement.y = 0

      dist = samus.runSpeed * dt
      if controller.states.right
        movement.x = dist
        samus.direction = 'right'
        samus.action = 'running'
      else if controller.states.left
        samus.direction = 'left'
        samus.action = 'running'
        movement.x = -dist
      else
        samus.action = 'standing'

      if controller.states.up
        samus.aim = 'up'
      else
        samus.aim = 'straight'

module.exports = SamusMotionSystem
