module HardpointObjects
  class MinigunHardpoint < HardpointObjects::HardpointObject

    HARDPOINT_NAME = "minigun_launcher"
    LAUNCHER_MIN_ANGLE = -40
    LAUNCHER_MAX_ANGLE = 40
    LAUNCHER_ROTATE_SPEED = 1
    PROJECTILE_CLASS = Bullet
    FIRING_GROUP_NUMBER = 2
    COOLDOWN_DELAY = 20
    ACTIVE_DELAY   = 120
    STORE_RARITY = 15 # 1 is lowest
    STEAM_POWER_USAGE = 5.0
    SHOW_HARDPOINT_BASE = true

    # def attack hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options = {}
    #   angle_min = self.class.angle_1to360(self.class::LAUNCHER_MIN_ANGLE + hardpoint_firing_angle)
    #   angle_max = self.class.angle_1to360(self.class::LAUNCHER_MAX_ANGLE + hardpoint_firing_angle)
    #   # puts "GRAPPLING HOOK L ATTACK HERE: #{@active} -test: #{@test}"
    #   # puts "#{@projectiles.count >= self.class::ACTIVE_PROJECTILE_LIMIT} && #{!@active} && #{is_angle_between_two_angles?(destination_angle, angle_min, angle_max)}"
    #   # @projectiles.last.time_alive check is to prevent accidental quick double-clicks
    #  # puts "GRAP ATTACK HERE: #{@active_for}"
    #   if 
    #     return super(hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options)
    #   end
    # end

    def self.get_starting_sound
      return Gosu::Sample.new("#{SOUND_DIRECTORY}/mini-gun-spin-up.ogg")
    end

    def self.get_hardpoint_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end

    def self.name
      "MiniGun Launcher"
    end

    def self.description
      "This is a standard MiniGun launcher. Fires bullets."
    end

    def self.value
      120
    end
  end
end