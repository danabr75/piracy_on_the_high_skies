require_relative '../projectiles/bullet.rb'
module HardpointObjects
  class CannonHardpoint < HardpointObjects::HardpointObject
    HARDPOINT_NAME = "cannon_launcher"
    LAUNCHER_MIN_ANGLE = -50
    LAUNCHER_MAX_ANGLE = 50
    # LAUNCHER_ROTATE_SPEED = 3
    PROJECTILE_CLASS = Projectiles::Cannon
    FIRING_GROUP_NUMBER = 2
    SHOW_HARDPOINT_BASE = true
    
    SLOT_TYPE = :offensive


    LAUNCHER_ROTATE_SPEED = 0.8
    # MISSILE_LAUNCHER_INIT_ANGLE = 0.0
    COOLDOWN_DELAY = 240
    # COOLDOWN_DELAY = 15
    # HARDPOINT_NAME = "missile_launcher"
    # PROJECTILE_CLASS = Projectiles::Missile
    # FIRING_GROUP_NUMBER = 2
    STORE_RARITY = 5 # 1 is lowest
    STEAM_POWER_USAGE = 20.0


    def self.get_hardpoint_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end

    def self.name
      "Cannon Launcher"
    end

    def self.description
      [
        "This is a standard cannon launcher. Fires cannons.",
        "A lot of firepower. More damage the closer you are."
      ]
    end

    def self.value
      60
    end

  end
end