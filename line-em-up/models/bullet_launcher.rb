require_relative 'launcher.rb'
require_relative 'bullet.rb'
class BulletLauncher < Launcher
  HARDPOINT_NAME = "bullet_launcher"
  LAUNCHER_MIN_ANGLE = -60
  LAUNCHER_MAX_ANGLE = 60
  PROJECTILE_CLASS = Bullet
  FIRING_GROUP_NUMBER = 2

  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
  end

  # Calculate offset in the hardpoint, not on the launcher side (multiple projectiles).
  # def attack hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner_id, options = {}
  #   validate_not_nil([options], self.class.name, __callee__) 
  #   angle_min = self.class.angle_1to360(LAUNCHER_MIN_ANGLE + hardpoint_firing_angle)
  #   angle_max = self.class.angle_1to360(LAUNCHER_MAX_ANGLE + hardpoint_firing_angle)

  #   if is_angle_between_two_angles?(destination_angle, angle_min, angle_max)
  #     if @cooldown_wait <= 0
  #       projectile = init_projectile(hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner_id, options)
  #       @cooldown_wait = get_cooldown
  #       return projectile
  #     end
  #   else
  #     # puts "ANGLE WAS NOT BETWEEN TWO ANGLES: #{destination_angle} w #{angle_min} and #{angle_max}"
  #   end
  # end

  def self.name
    "Bullet Launcher"
  end

  def self.description
    "This is a standard bullet launcher. Fires bullets."
  end

end