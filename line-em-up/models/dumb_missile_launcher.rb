require_relative 'launcher.rb'
class DumbMissileLauncher < Launcher
  # 0 is NORTH, 180 is SOUTH
  MISSILE_LAUNCHER_MIN_ANGLE = -20
  MISSILE_LAUNCHER_MAX_ANGLE = 20
  # MISSILE_LAUNCHER_INIT_ANGLE = 0.0
  COOLDOWN_DELAY = 45
  # COOLDOWN_DELAY = 15

  # convert pointer x and y to map pixel coordinates
  def init_projectile initial_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, options = {}
    validate_not_nil([options], self.class.name, __callee__)
    Missile.new(
      current_map_pixel_x, current_map_pixel_y, 
      destination_angle, start_point, end_point,
      MISSILE_LAUNCHER_MIN_ANGLE + initial_angle, MISSILE_LAUNCHER_MAX_ANGLE + initial_angle, initial_angle,
      current_map_tile_x, current_map_tile_y, options
    )
  end


  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_launcher.png")
  end
  # def draw
  #   if @inited
  #     if @active
  #       # @image.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @width_scale, @height_scale)
  #     end

  #     return true
  #   else
  #     return false
  #   end
  # end

  # Calculate offset in the hardpoint, not on the launcher side (multiple projectiles).
  def attack initial_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, options = {}
    validate_not_nil([options], self.class.name, __callee__) 
    # current_map_tile_x, current_map_tile_y CALCUATE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # puts "DUMB MISSILE LAUNCHER ATTACK"
    puts "IS ANGLE BETWEEN? #{is_angle_between_two_angles?(destination_angle, MISSILE_LAUNCHER_MIN_ANGLE + initial_angle, MISSILE_LAUNCHER_MAX_ANGLE + initial_angle)} = is_angle_between_two_angles?(#{destination_angle}, #{MISSILE_LAUNCHER_MIN_ANGLE + initial_angle}, #{MISSILE_LAUNCHER_MAX_ANGLE + initial_angle})"
    angle_min = MISSILE_LAUNCHER_MIN_ANGLE + initial_angle
    angle_max = MISSILE_LAUNCHER_MAX_ANGLE + initial_angle
    if angle_min < 0.0
      angle_min = 360.0 - angle_min.abs
    elsif angle_min > 360.0
      angle_min = angle_min - 360.0
    end
    if angle_max < 0.0
      angle_max = 360.0 - angle_max.abs
    elsif angle_max > 360.0
      angle_max = angle_max - 360.0
    end
    if is_angle_between_two_angles?(destination_angle, angle_min, angle_max)
      if @cooldown_wait <= 0
        new_map_pixel_x, new_map_pixel_y = convert_screen_to_map_pixel_location(current_map_pixel_x, current_map_pixel_y)
        projectile = init_projectile(initial_angle, new_map_pixel_x, new_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, options)
        # @projectiles << projectile
        @cooldown_wait = get_cooldown
        return projectile
      end
    end
  end

end