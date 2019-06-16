require_relative 'launcher.rb'
require_relative 'bullet.rb'
class BulletLauncher < Launcher
  HARDPOINT_NAME = "bullet_launcher"
  LAUNCHER_MIN_ANGLE = -60
  LAUNCHER_MAX_ANGLE = 60
  PROJECTILE_CLASS = Bullet

  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
  end

  # convert pointer x and y to map pixel coordinates
  def init_projectile hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner_id, options = {}
    validate_not_nil([options], self.class.name, __callee__)
    PROJECTILE_CLASS.new(
      current_map_pixel_x, current_map_pixel_y, 
      destination_angle, start_point, end_point,
      LAUNCHER_MIN_ANGLE + hardpoint_firing_angle, LAUNCHER_MAX_ANGLE + hardpoint_firing_angle, hardpoint_firing_angle,
      current_map_tile_x, current_map_tile_y,
      owner_id, options
    )
  end


  # Calculate offset in the hardpoint, not on the launcher side (multiple projectiles).
  def attack hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner_id, options = {}
    validate_not_nil([options], self.class.name, __callee__) 
    # current_map_tile_x, current_map_tile_y CALCUATE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # puts "DUMB MISSILE LAUNCHER ATTACK"
    # puts "IS ANGLE BETWEEN? #{is_angle_between_two_angles?(destination_angle, LAUNCHER_MIN_ANGLE + initial_angle, LAUNCHER_MAX_ANGLE + initial_angle)} = is_angle_between_two_angles?(#{destination_angle}, #{LAUNCHER_MIN_ANGLE + initial_angle}, #{LAUNCHER_MAX_ANGLE + initial_angle})"
    angle_min = self.class.angle_1to360(LAUNCHER_MIN_ANGLE + hardpoint_firing_angle)
    angle_max = self.class.angle_1to360(LAUNCHER_MAX_ANGLE + hardpoint_firing_angle)

    # hardpoint_angle: 13 THIS IS INCORRECT< SHOULD BE 0
    puts "hardpoint_firing_angle: #{hardpoint_firing_angle}"
    puts "BULLET ATTACk here MIN : #{LAUNCHER_MIN_ANGLE}"
    puts "BULLET ATTACk here MAX : #{LAUNCHER_MAX_ANGLE}"


    puts "BULLET LAUNCHER ATTACK: #{angle_min} and #{angle_max}"
    if is_angle_between_two_angles?(destination_angle, angle_min, angle_max)
      puts "ANGLE WAS BETWEEN TWO ANGLES: #{destination_angle} w #{angle_min} and #{angle_max}"
      if @cooldown_wait <= 0
        # new_map_pixel_x, new_map_pixel_y = convert_screen_to_map_pixel_location(current_map_pixel_x, current_map_pixel_y)
        # projectile = init_projectile(initial_angle, new_map_pixel_x, new_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, options)
        projectile = init_projectile(hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner_id, options)
        # @projectiles << projectile
        @cooldown_wait = get_cooldown
        return projectile
      end
    else
      puts "ANGLE WAS NOT BETWEEN TWO ANGLES: #{destination_angle} w #{angle_min} and #{angle_max}"
    end
  end

  def self.name
    "Bullet Launcher"
  end

  def self.description
    "This is a standard bullet launcher. Fires bullets."
  end

end