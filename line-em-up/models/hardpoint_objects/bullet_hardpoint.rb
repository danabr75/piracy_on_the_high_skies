module HardpointObjects
  class BulletHardpoint < HardpointObjects::HardpointObject
    HARDPOINT_NAME = "bullet_launcher"
    LAUNCHER_MIN_ANGLE = -60
    LAUNCHER_MAX_ANGLE = 60
    LAUNCHER_ROTATE_SPEED = 1
    PROJECTILE_CLASS = Bullet
    FIRING_GROUP_NUMBER = 2
    SHOW_HARDPOINT_BASE = true

    def self.get_hardpoint_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end

    def self.name
      "Bullet Launcher"
    end

    def self.description
      "This is a standard bullet launcher. Fires bullets."
    end

    def self.value
      30
    end

  end
end