require_relative 'screen_fixed_object.rb'
# require_relative 'rocket_launcher_pickup.rb'
require_relative '../lib/config_setting.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

class Player < ScreenFixedObject
  CONFIG_FILE = "#{CURRENT_DIRECTORY}/../config.txt"
  puts "CONFIG SHOULD BE HERE: #{CONFIG_FILE}"
  # SPEED = 7
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :rockets, :score, :time_alive

  attr_accessor :bombs, :secondary_weapon, :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
  attr_accessor :special_attack, :main_weapon, :drawable_items_near_self, :broadside_mode
  MAX_HEALTH = 200

  SECONDARY_WEAPONS = [RocketLauncherPickup::NAME] + %w[bomb]
  # Range goes clockwise around the 0-360 angle
  MISSILE_LAUNCHER_MIN_ANGLE = 75
  MISSILE_LAUNCHER_MAX_ANGLE = 105
  MISSILE_LAUNCHER_INIT_ANGLE = 90

  SPECIAL_POWER = 'laser'
  SPECIAL_POWER_KILL_MAX = 50

  # x and y is graphical representation of object
  # location x and y where it exists on the global map.
  # Location x and y became screen movement... 
  # gps_location_x and gps_location_y is now global map
  # def initialize(scale, x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, location_x, location_y, map_pixel_width, map_pixel_height, options = {})
 # def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, map_pixel_width, map_pixel_height, options = {})
  def initialize(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options = {})
    validate_int([current_map_tile_x, current_map_tile_y],  self.class.name, __callee__)
    validate_float([current_map_pixel_x, current_map_pixel_y],  self.class.name, __callee__)

    @current_map_pixel_x = current_map_pixel_x
    @current_map_pixel_y = current_map_pixel_y
    @current_map_tile_x  = current_map_tile_x
    @current_map_tile_y  = current_map_tile_y
    # run_pixel_to_tile_validations
    # puts "current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y"
    # puts "#{current_map_pixel_x}, #{current_map_pixel_y}, #{current_map_tile_x}, #{current_map_tile_y}"
    # @x = screen_pixel_width  / 2
    # @y = screen_pixel_height / 2
    # Can't get x and y until we know the screen size... hmmm
    super()
    update_x_and_y(@screen_pixel_width  / 2, @screen_pixel_height / 2)
    puts "NEW2 X AND Y: #{@x} - #{@y}"
    # super(@screen_pixel_width  / 2, @screen_pixel_height / 2)

    @score = 0
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @grapple_hook_cooldown_wait = 0
    @attack_speed = 3
    # @attack_speed = 3
    @health = 100.0
    @armor = 0
    @rockets = 50
    # @rockets = 250
    @bombs = 3
    @secondary_weapon = RocketLauncherPickup::NAME
    @turn_right = false
    @turn_left = false

    @hard_point_items = [RocketLauncherPickup::NAME, 'cannon_launcher', 'cannon_launcher', 'bomb_launcher']
    @rocket_launchers = 0
    @bomb_launchers   = 0
    @cannon_launchers = 0
    trigger_hard_point_load
    @damage_reduction = options[:handicap] ? options[:handicap] : 1
    # invert_handicap = 1 - options[:handicap]
    # @boost_increase = invert_handicap > 0 ? 1 + (invert_handicap * 1.25) : 1
    # @damage_increase = invert_handicap > 0 ? 1 + (invert_handicap) : 1
    @kill_count = 0
    # @drawable_items_near_self = []
    @angle = 0
    ship = ConfigSetting.get_setting(CONFIG_FILE, 'ship', BasicShip.name.to_s)
    if ship
      ship_class = eval(ship)
      puts "SHIP HERE: #{@x} - #{@y}"
      @ship = ship_class.new(@x, @y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, nil, tile_pixel_width, tile_pixel_height, options)
    else
      @ship = BasicShip.new(@x, @y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, nil, tile_pixel_width, tile_pixel_height, options)
    end
    @ship.x = @x
    @ship.y = @y
    # Get details from ship
    # @mass = 50 # Get from ship
    @mass = 300 # Get from ship
    @current_momentum = 0
    @max_momentum = @mass * 3 # speed here?
    # @speed = 3 #/ (@mass / 2)
    @speed = 100 #/ (@mass / 2)
    @rotation_speed = 2
  end

  def get_kill_count_max
    self.class::SPECIAL_POWER_KILL_MAX
  end

  def ready_for_special?
    @kill_count >= get_kill_count_max
  end

  def special_attack object_groups
    # Fire special attack.
    @kill_count = 0
    projectiles = []
    object_groups.each do |group|
      group.each do |object|
        next if object.nil?
          projectiles << Missile.new(@scale, @screen_pixel_width, @screen_pixel_height, self, object.x, object.y, nil, nil, nil, {damage_increase: @damage_increase})
      end
    end
    return projectiles
  end


  def special_attack_2
    # Fire special attack.
    @kill_count = 0
    projectiles = []
    # object_groups.each do |group|
    #   group.each do |object|
    #     next if object.nil?
    #       projectiles << Missile.new(@scale, @screen_pixel_width, @screen_pixel_height, self, object.x, object.y, nil, nil, nil, {damage_increase: @damage_increase})
    #   end
    # end

    r = 10 * @scale
    theta = 0
    count_max = 360
    max_passes = 3
    pass_count = 0
    theta = 0
    # Need a projectile queue system?
    while theta < count_max
      x  =  @x + r * Math.cos(theta)
      y  =  @y + r * Math.sin(theta)
      if y < @y

        projectiles << Missile.new(@scale, @screen_pixel_width, @screen_pixel_height, self, x, y, nil, nil, nil, {damage_increase: @damage_increase})

      end
      theta += 5
    end
    # where r is the radius of the circle, and h,k are the coordinates of the center.

    return projectiles
  end


  # Rocket Launcher, Rocket launcher, Cannon, Cannon, Bomb Launcher
  HARD_POINTS = 12

  def add_kill_count kill_count
    if @kill_count + kill_count > get_kill_count_max
      @kill_count = get_kill_count_max
    else
      @kill_count += kill_count
    end
  end

  def add_hard_point hard_point
    @hard_point_items << hard_point
    trigger_hard_point_load
  end

  def trigger_hard_point_load
    @rocket_launchers, @bomb_launchers, @cannon_launchers = [0, 0, 0]
    count = 0
    # puts "RUNNING ON: #{@hard_point_items}"
    @hard_point_items.each do |hard_point|
      break if count == HARD_POINTS
      case hard_point
      when 'bomb_launcher'
        @bomb_launchers += 1
      when RocketLauncherPickup::NAME
        # puts "INCREASTING ROCKET LAUNCHER: #{RocketLauncherPickup::NAME}"
        @rocket_launchers += 1
      when 'cannon_launcher'
        @cannon_launchers += 1
      else
        "Raise should never get here. hard_point: #{hard_point}"
      end
      count += 1
    end
  end

  # Issue with image.. probably shouldn't be using images to define sizes
  # def get_image
  #   # if @inited
  #   #   @ship.get_image
  #   # end
  #   if @broadside_mode
  #     Gosu::Image.new("#{MEDIA_DIRECTORY}/pilotable_ships/basic_ship/spaceship_broadside.png")
  #   else
  #     Gosu::Image.new("#{MEDIA_DIRECTORY}/pilotable_ships/basic_ship/spaceship.png")
  #   end
  # end
  
  # def get_image_path
  #   "#{MEDIA_DIRECTORY}/spaceship.png"
  # end


  # def increment_angle angle_increment
  #   if @angle + angle_increment >= 360.0
  #     @angle = (@angle + angle_increment) - 360.0
  #   else
  #     @angle += angle_increment
  #   end
  # end

  # def decrement_angle angle_increment
  #   if @angle - angle_increment <= 0.0
  #     @angle = (@angle - angle_increment) + 360.0
  #   else
  #     @angle -= angle_increment
  #   end
  # end

  def rotate_counterclockwise
    increment = @rotation_speed
    if @angle + increment >= 360
      @angle = (@angle + increment) - 360
    else
      @angle += increment
    end
    @ship.angle = @angle
    @ship.rotate_hardpoints_counterclockwise(increment.to_f)
    return 1
  end

  def rotate_clockwise
    increment = @rotation_speed
    if @angle - increment <= 0
      @angle = (@angle - increment) + 360
    else
      @angle -= increment
    end
    @ship.angle = @angle
    @ship.rotate_hardpoints_clockwise(increment.to_f)
    return 1
  end

  # def laser_attack pointer
  #   if @main_weapon.nil?
  #     # options = {damage_increase: @damage_increase, relative_y_padding: @image_height_half}
  #     options = {damage_increase: @damage_increase}
  #     @main_weapon = LaserBeam.new(@scale, @screen_pixel_width, @screen_pixel_height, self, options)
  #     @drawable_items_near_self << @main_weapon
  #     return {
  #       projectiles: [@main_weapon.attack],
  #       cooldown: LaserBeam::COOLDOWN_DELAY
  #     }
  #   else
  #     @main_weapon.active = true if @main_weapon.active == false
  #     @drawable_items_near_self << @main_weapon
  #     return {
  #       projectiles: [@main_weapon.attack],
  #       cooldown: LaserBeam::COOLDOWN_DELAY
  #     }
  #   end
  # end


  def take_damage damage
    @ship.take_damage(damage)
    # @health -= damage * @damage_reduction
  end

  def toggle_secondary
    current_index = SECONDARY_WEAPONS.index(@secondary_weapon)
    if current_index == SECONDARY_WEAPONS.count - 1
      @secondary_weapon = SECONDARY_WEAPONS[0]
    else
      @secondary_weapon = SECONDARY_WEAPONS[current_index + 1]
    end
  end

  def get_secondary_ammo_count
    return case @secondary_weapon
    when 'bomb'
      self.bombs
    else
      self.rockets
    end
  end


  def decrement_secondary_ammo_count count = 1
    return case @secondary_weapon
    when 'bomb'
      self.bombs -= count
    else
      self.rockets -= count
    end
  end

  def get_secondary_name
    return case @secondary_weapon
    when 'bomb'
      'Bomb'
    else
      'Rocket'
    end
  end

  def is_alive
    @ship.is_alive
    # health > 0
  end

  # CAP movement w/ Acceleration!!!!!!!!!!!!!!!!!!!

  def move_left movement_x = 0, movement_y = 0
    # new_speed = (@speed  / (@mass.to_f)) * -1.5
    new_speed = (@speed  / (@mass.to_f)) * -100
    x_diff, y_diff = self.movement(new_speed, @angle + 90, true)
    return [movement_x - x_diff, movement_y - y_diff]
  end
  
  def move_right movement_x = 0, movement_y = 0
    # new_speed = (@speed  / (@mass.to_f)) * -1.5
    new_speed = (@speed  / (@mass.to_f)) * -100
    x_diff, y_diff = self.movement(new_speed, @angle - 90, true)
    return [movement_x - x_diff, movement_y - y_diff]
  end
  
  # Calculate W movement
    # @mass = 50 # Get from ship
    # @current_momentum = 0
    # @max_momentum = @mass
    # @speed = 10 / (@mass / 2)
    # @rotation_speed = 2

  # Figure out why these got switched later, accelerate and brake
  def accelerate movement_x = 0, movement_y = 0
    x_diff, y_diff = self.movement( @speed / (@mass.to_f), @angle, true)

    if @current_momentum <= @max_momentum
      @current_momentum += 1.2
    end
    # puts "PLAYER ACCELETATE:"
    # puts "[movement_x - x_diff, movement_y - y_diff]"
    # puts "[#{movement_x} - #{x_diff}, #{movement_y} - #{y_diff}]"
    return [(movement_x - x_diff), (movement_y - y_diff)]
  end
  
  def brake movement_x = 0, movement_y = 0
    # raise "ISSUE4" if @current_map_pixel_x.class != Integer || @current_map_pixel_y.class != Integer 
    # puts "ACCELERATE: #{movement_x} - #{movement_y}"
    x_diff, y_diff = self.movement( @speed / (@mass.to_f), @angle - 180, true)

    if @current_momentum >= -@max_momentum
      @current_momentum -= 2
    end

    return [(movement_x - x_diff), (movement_y - y_diff)]
  end

  def attack_group_1 pointer
    @ship.attack_group_1(@angle, @current_map_pixel_x, @current_map_pixel_y, pointer)
  end
 
  def deactivate_group_1
    @ship.deactivate_group_1
  end

  def attack_group_2 pointer
    @ship.attack_group_2(@angle, @current_map_pixel_x, @current_map_pixel_y, pointer)
  end
 
  def deactivate_group_2
    @ship.deactivate_group_2
  end

  def get_draw_ordering
    ZOrder::Player
  end

  def draw
    # @drawable_items_near_self.reject! { |item| item.draw }
    @ship.draw
  end

  POINTS_X = 7
  POINTS_Y = 7

  def draw_gl_list
    # @drawable_items_near_self + [self]
    @ship.draw_gl_list
  end

  def draw_gl
    @ship.draw_gl
  end
  
  def update mouse_x, mouse_y, player, movement_x, movement_y
    # run_pixel_to_tile_validations
    # raise "ISSUE" if movement_x.class != Integer || movement_y.class != Integer 
    # puts "HERE: #{@current_map_pixel_x.class} - #{@current_map_pixel_y.class}"
    # puts "HERE2: #{[@current_map_pixel_x , @current_map_pixel_y]}"
    # raise "ISSUE2" if @current_map_pixel_x.class != Integer || @current_map_pixel_y.class != Integer 
    # puts "PLAYER: #{@current_map_pixel_x} - #{@current_map_pixel_y}" if @time_alive % 10 == 0
    @ship.update(mouse_x, mouse_y, player)

    if @current_momentum > 0.0
      speed = (@mass / 10.0) * (@current_momentum / 10.0) / 90.0
      x_diff, y_diff = self.movement(speed, @angle)
      @current_momentum -= 1
      @current_momentum = 0 if @current_momentum < 0
    elsif @current_momentum < 0.0
      speed = (@mass / 10.0) * (@current_momentum / 10.0) / 90.0
      x_diff, y_diff = self.movement(-speed, @angle + 180)
      @current_momentum += 1
      @current_momentum = 0 if @current_momentum > 0
    else
      x_diff, y_diff = [0,0]
    end


    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    # @main_weapon.update(mouse_x, mouse_y, player) if @main_weapon

    @cooldown_wait -= 1              if @cooldown_wait > 0
    @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    @time_alive += 1 if self.is_alive

    puts "PLAYER UPDATE: #{@current_map_pixel_x} - #{@current_map_pixel_y} - @map_pixel_height #{@map_pixel_height} - #{@map_pixel_width}" if @time_alive % 100 == 0

    # puts "PLAYER: @current_map_pixel_y >= @map_pixel_height: #{@current_map_pixel_y} >= #{@map_pixel_height}"
    if @current_map_pixel_y >= @map_pixel_height# * @tile_height
      # puts "CASE 1"
      # puts "LOCATION Y on PLAYER IS OVER MAP HEIGHT"
      @current_momentum = 0
      @current_map_pixel_y = @map_pixel_height
    elsif @current_map_pixel_y < 0
      # puts "CASE 2"
      @current_momentum = 0
      @current_map_pixel_y = 0
    end
    if @current_map_pixel_x >= @map_pixel_width# * @tile_width
      # puts "CASE 3"
      @current_momentum = 0
      @current_map_pixel_x = @map_pixel_width
    elsif @current_map_pixel_x < 0
      # puts "CASE 4"
      @current_momentum = 0
      @current_map_pixel_x = 0
    end

    # raise "ISSUE3" if @current_map_pixel_x.class != Integer || @current_map_pixel_y.class != Integer 
    super(mouse_x, mouse_y, player)
    return [(movement_x - x_diff), (movement_y - y_diff)]
  end

  def collect_pickups(pickups)
    @ship.collect_pickups(pickups)
  end

end