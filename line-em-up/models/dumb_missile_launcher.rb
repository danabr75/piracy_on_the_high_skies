require_relative 'launcher.rb'
require_relative 'missile.rb'
class DumbMissileLauncher < Launcher
  # 0 is NORTH, 180 is SOUTH
  LAUNCHER_MIN_ANGLE = -20
  LAUNCHER_MAX_ANGLE = 20
  # MISSILE_LAUNCHER_INIT_ANGLE = 0.0
  COOLDOWN_DELAY = 45
  # COOLDOWN_DELAY = 15
  HARDPOINT_NAME = "missile_launcher"
  PROJECTILE_CLASS = Missile
  FIRING_GROUP_NUMBER = 1
  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
  end



  # # Calculate offset in the hardpoint, not on the launcher side (multiple projectiles).
  # def attack initial_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options = {}
  #   validate_not_nil([options], self.class.name, __callee__) 
  #   angle_min = LAUNCHER_MIN_ANGLE + initial_angle
  #   angle_max = LAUNCHER_MAX_ANGLE + initial_angle
  #   if angle_min < 0.0
  #     angle_min = 360.0 - angle_min.abs
  #   elsif angle_min > 360.0
  #     angle_min = angle_min - 360.0
  #   end
  #   if angle_max < 0.0
  #     angle_max = 360.0 - angle_max.abs
  #   elsif angle_max > 360.0
  #     angle_max = angle_max - 360.0
  #   end
  #   if is_angle_between_two_angles?(destination_angle, angle_min, angle_max)
  #     if @cooldown_wait <= 0
  #       new_map_pixel_x, new_map_pixel_y = convert_screen_to_map_pixel_location(current_map_pixel_x, current_map_pixel_y)
  #       projectile = init_projectile(initial_angle, new_map_pixel_x, new_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options)
  #       # @projectiles << projectile
  #       @cooldown_wait = get_cooldown
  #       return projectile
  #     end
  #   end
  # end

  def self.name
    "Missile Launcher"
  end

  def self.description
    "This is a standard missile launcher. Fires missiles."
  end
end