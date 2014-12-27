SystemRegistry = require '../ecs/system_registry'

Systems = new SystemRegistry()

Systems.register 'sprite_sync',     require('./systems/sprite_sync_system')
Systems.register 'controller',      require('./systems/controller_system')
Systems.register 'samus_motion',    require('./systems/samus_motion_system')
Systems.register 'samus_animation', require('./systems/samus_animation_system')
Systems.register 'movement',        require('./systems/movement_system')

module.exports = Systems

