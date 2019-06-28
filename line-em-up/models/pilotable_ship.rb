require_relative 'general_object.rb'
# require_relative 'rocket_launcher_pickup.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

class PilotableShip < GeneralObject

  ITEM_MEDIA_DIRECTORY = "#{MEDIA_DIRECTORY}/pilotable_ships/basic_ship"
  SPEED = 1
  ROTATION_SPEED = 1
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive

  attr_accessor :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
  attr_accessor :special_attack, :main_weapon, :drawable_items_near_self
  attr_accessor :hardpoints
  attr_reader :rotation_speed
  # attr_reader :steam_max_capacity, :steam_rate_increase, :current_steam_capacity
  # attr_reader :mass, :boost_speed, :speed, :speed_steam_usage, :boost_speed_steam_usage
  # attr_reader :boost_mass

  attr_reader :current_steam_capacity, :tiles_per_second

  attr_accessor :current_momentum

    # @speed             = ((self.class::SPEED * @average_scale) + (acceleration_boost  * @average_scale)) / 3.0
    # @speed_steam_usage = @engine_steam_usage_increment
    # @boost_speed       = ((self.class::SPEED * @average_scale) + ((acceleration_boost * boost_speed_modifier)  * @average_scale)) / 3.0
    # @boost_speed_steam_usage = @engine_steam_usage_increment + @boost_steam_usage


  MAX_HEALTH = 200
  INIT_HEALTH = 200

  # FRONT_HARDPOINT_LOCATIONS = []
  # PORT_HARDPOINT_LOCATIONS = []
  # STARBOARD_HARDPOINT_LOCATIONS = []

  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  CONFIG_FILE = "#{CURRENT_DIRECTORY}/../../config.txt"
  attr_accessor :angle
  # BasicShip.new(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options)
  def initialize(x, y, z, hardpoint_z, angle, owner, options = {})

    # validate_array([], self.class.name, __callee__)
    # validate_string([], self.class.name, __callee__)
    # validate_float([], self.class.name, __callee__)
    # validate_int([], self.class.name, __callee__)
    validate_not_nil([x, y, angle], self.class.name, __callee__)

    # validate_int([x, y, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, angle], self.class.name, __callee__)
    # validate_float([width_scale, height_scale], self.class.name, __callee__)
    # validate_not_nil([x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height], self.class.name, __callee__)


    @x = x
    @y = y
    @z = z
    # puts "ShIP THOUGHT THAT THIS WAS CONFIG_FILE: #{self.class::CONFIG_FILE}"
    @angle = angle
    media_path = self.class::ITEM_MEDIA_DIRECTORY
    path = media_path
    # @right_image = self.class.get_right_image(path)
    # @left_image = self.class.get_left_image(path)
    # @right_broadside_image = self.class.get_right_broadside_image(path)
    # @left_broadside_image = self.class.get_left_broadside_image(path)
    disable_hardpoint_angles = false
    if options[:use_large_image]
      @use_large_image = true
      disable_hardpoint_angles = true
      @image = self.class.get_large_image(path)
    else
      @image = self.class.get_image(path)
    end
    options[:image] = @image
  # def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height, options = {})
    super(options)
    # Top of screen
    # @min_moveable_height = options[:min_moveable_height] || 0
    # Bottom of the screen
    # @max_movable_height = options[:max_movable_height] || screen_pixel_height
    @score = 0
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @grapple_hook_cooldown_wait = 0
    @attack_speed = 3
    # @attack_speed = 3
    # if @debug
    #   @health = INIT_HEALTH * 10000
    # else
      @health = INIT_HEALTH
    # end
    @armor = 0
    @rockets = 50
    # @rockets = 250
    @bombs = 3
    # @secondary_weapon = RocketLauncherPickup::NAME

    # @hard_point_items = [RocketLauncherPickup::NAME, 'cannon_launcher', 'cannon_launcher', 'bomb_launcher']
    @rocket_launchers = 0
    @bomb_launchers   = 0
    @cannon_launchers = 0
    # trigger_hard_point_load
    @damage_reduction = options[:handicap] ? options[:handicap] : 1
    invert_handicap = 1 - @damage_reduction
    @boost_increase = invert_handicap > 0 ? 1 + (invert_handicap * 1.25) : 1
    @damage_increase = invert_handicap > 0 ? 1 + (invert_handicap) : 1
    @kill_count = 0
    @main_weapon = nil
    @drawable_items_near_self = []

    @hide_hardpoints = options[:hide_hardpoints] || false

    # Load hardpoints from CONFIG FILE HERE, plug in launcher class !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    # get_config_save_settings = [self.class.name]

    # # ConfigSetting.set_mapped_setting(self.class::CONFIG_FILE, [BasicShip, 'front_hardpoint_locations', 1], 'launcher')
    # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '1'], 'launcher')
    # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '2'], 'launcher')
    # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '3'], 'launcher')
    # ConfigSetting.get_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '1'])

    # Update hardpoints location
    @engine_hardpoints     = []
    @steam_core_hardpoints = []
    @hardpoints = Array.new(self.class::HARDPOINT_LOCATIONS.length) {nil}
    self.class::HARDPOINT_LOCATIONS.each_with_index do |location, index|
      item_klass_string = options[:hardpoint_data] ? options[:hardpoint_data][index.to_s] : nil

      found_errors = false
      begin
        item_klass = item_klass_string && item_klass_string != '' ? eval(item_klass_string) : nil
      rescue NameError, SyntaxError, NoMethodError => e
        found_errors = true
        puts "ISSUE: #{e.class}"
        # puts e.backtrace
        puts "ISSUE WITH: #{item_klass_string}"
        puts "RAW DATA: #{options}"
      end
      raise "Finishing w/ errors" if found_errors

      raise "bad slot type" if location[:slot_type].nil?
      raise "bad anlge"     if location[:angle_offset].nil?
      if [:engine, :generic].include?(location[:slot_type]) && !item_klass.nil? && HardpointObjects::EngineHardpoint.descendants.include?(item_klass)
        @engine_hardpoints << item_klass
      end
      # ADD BACK IN
      # HardpointObjects::SteamCoreHardpoint
      if [:steam_core].include?(location[:slot_type]) && !item_klass.nil? && HardpointObjects::SteamCoreHardpoint.descendants.include?(item_klass)
        @steam_core_hardpoints << item_klass
      end
      # Always point engines toward the rear
      if (location[:slot_type] == :engine || location[:slot_type] == :generic) && HardpointObjects::EngineHardpoint.descendants.include?(item_klass)
        location[:angle_offset] = 180
      end
      # puts "ITEM CLASS " if owner.class == Player
      puts "@engine_hardpoints.count: #{@engine_hardpoints.count}" if owner.class == Player
      options[:block_initial_angle] = true if disable_hardpoint_angles
      hp = Hardpoint.new(
        x, y, hardpoint_z, location[:x_offset].call(get_image, @width_scale),
        location[:y_offset].call(get_image, @height_scale), item_klass, location[:slot_type], @angle, location[:angle_offset], owner, options
      )
      @hardpoints[index] = hp
    end

    # acceleration_boost = 0.0
    # rotation_boost     = 0.0
    # mass_boost         = 0.0
    engine_permanent_steam_usage     = 0.0
    engine_tiles_per_second_modifier = 1.0
    # engine_steam_usage_increment = 0.0
    # boost_speed_modifier         = 0.0
    # boost_steam_usage            = 0.0
    # boost_mass_modifier          = 1.0
    @engine_hardpoints.each do |engine_klass|
    #   # puts "ENGINEKLASS HERE: #{engine_klass}"
    #   acceleration_boost += engine_klass::ACCELERATION
    #   rotation_boost     += engine_klass::ROTATION_BOOST
    #   mass_boost         += engine_klass::MASS_BOOST

      engine_permanent_steam_usage += engine_klass::PERMANENT_STEAM_USE
    #   engine_steam_usage_increment += engine_klass::STEAM_USAGE_INCREMENT
    #   boost_speed_modifier         += engine_klass::BOOST_SPEED_MODIFIER
    #   boost_steam_usage            += engine_klass::BOOST_STEAM_USAGE
    #   boost_mass_modifier          = boost_mass_modifier * engine_klass::BOOST_MASS_MODIFIER
    engine_tiles_per_second_modifier = engine_tiles_per_second_modifier * engine_klass::TILES_PER_SECOND_MODIFIER
    end
    @engine_permanent_steam_usage     = engine_permanent_steam_usage
    @engine_tiles_per_second_modifier = engine_tiles_per_second_modifier
    # @engine_steam_usage_increment = engine_steam_usage_increment
    # @boost_speed_modifier         = boost_speed_modifier
    # @boost_steam_usage            = boost_steam_usage


    steam_max_capacity = 0.0
    steam_rate_increase = 0.0
    @steam_core_hardpoints.each do |steam_core_klass|
      # puts "ENGINEKLASS HERE: #{engine_klass}"
      steam_max_capacity    += steam_core_klass::STEAM_MAX_CAPACITY
      steam_rate_increase   += steam_core_klass::STEAM_RATE_INCREASE
    end

    @steam_original_max_capacity = steam_max_capacity
    @steam_max_capacity          = steam_max_capacity
    @current_steam_capacity      = @steam_max_capacity
    @steam_rate_increase         = steam_rate_increase

    puts "@engine_hardpoints: #{@engine_hardpoints.count}"

    options.delete(:hardpoint_data)



    @hardpoints.each_with_index do |hp, hp_index|
      raise "HP WAS NIL HERE: #{hp_index} for group: #{group_index}" if hp.nil?
    end

    @theta = nil
    @rotation_speed    = self.class::ROTATION_SPEED #+ rotation_boost


    @mass             = self.class::MASS
    @half_mass        = self.class::MASS / 2.0
    @momentum_rate    = self.class::MOMENTUM_RATE
    @current_momentum = options[:current_momentum] || 0

    if @engine_hardpoints.count > 0
      @tiles_per_second = (self.class::TILES_PER_SECOND * @engine_tiles_per_second_modifier) * @average_scale
    else
      @tiles_per_second = (self.class::TILES_PER_SECOND / 2.0) * @average_scale
    end

    # @speed             = ((self.class::SPEED * @average_scale) + (acceleration_boost  * @average_scale)) / 3.0
    # puts "SPEED #{@speed}" if owner.class == Player
    # @speed_steam_usage = @engine_steam_usage_increment
    # @boost_speed       = ((self.class::SPEED * @average_scale) + ((acceleration_boost * boost_speed_modifier)  * @average_scale)) / 3.0
    # puts "BOOST SPEED #{@boost_speed}" if owner.class == Player
    # @boost_speed_steam_usage = @engine_steam_usage_increment + @boost_steam_usage

    # # HERE22: 4.125 = 4.125
    # @mass           = (self.class::MASS  + mass_boost) * @average_scale
    # puts "@MASS JERE: #{@mass}   =   (#{self.class::MASS}  + #{mass_boost}) * #{ @average_scale}" if owner.class == Player
    # @boost_mass = @mass * boost_mass_modifier
    # puts "@boost_mass JERE: #{@boost_mass}   =#{ @mass} * #{boost_mass_modifier}" if owner.class == Player
    # puts "MASS #{@mass}" if owner.class == Player
    # puts "BOOST MASS #{@boost_mass}" if owner.class == Player

    # @current_map_pixel_x = current_map_pixel_x
    # @current_map_pixel_y = current_map_pixel_y
    # @current_map_tile_x  = current_map_tile_x
    # @current_map_tile_y  = current_map_tile_y
    @block_momentum_increase = false
    @block_momentum_decrease = false
  end

  def accelerate boost = false
    if @current_momentum <= @mass && !@block_momentum_increase
      @current_momentum += @momentum_rate
      @current_momentum = @mass if @current_momentum > @mass
    end
  end

  def reverse
    if @current_momentum >= -@half_mass && !@block_momentum_decrease
      @current_momentum -= @momentum_rate
      @current_momentum = -@half_mass if @current_momentum < -@half_mass
    end
  end

  def brake
    if @current_momentum > 0
      reverse
      if @current_momentum < 0
        @current_momentum = 0
      end
    elsif @current_momentum < 0
      accelerate
      if @current_momentum > 0
        @current_momentum = 0
      end
    end
    return true
  end

  def use_steam usage
    if usage < @current_steam_capacity
      @current_steam_capacity -= usage
      return true
    else
      return false
    end
  end

  def add_hard_point hard_point
  #   @hard_point_items << hard_point
  #   trigger_hard_point_load
  end

  def self.get_image_assets_path
    ITEM_MEDIA_DIRECTORY
  end

  # def self.get_right_broadside_image path
  #   Gosu::Image.new("#{path}/right_broadside.png")
  # end
  # def self.get_left_broadside_image path
  #   Gosu::Image.new("#{path}/left_broadside.png")
  # end
  def get_image
    @image
  end
  def self.get_image path
    Gosu::Image.new("#{path}/default.png")
  end

  def self.get_tilable_image path
    Gosu::Image.new("#{path}/default.png", :tileable => true)
  end

  def self.get_destroyed_image path
    Gosu::Image.new("#{path}/destroyed_default.png")
  end

  def self.get_large_image path
    Gosu::Image.new("#{path}/large.png")
  end

  # these should be get_init_*
  def self.get_mass
    self.class::MASS
  end
  def self.get_speed
    self.class::SPEED
  end

  # def get_armor
  #   self.class::ARMOR
  # end
  def get_health
    @health
  end

  # def self.get_right_image path
  #   Gosu::Image.new("#{path}/right.png")
  # end
  
  # def self.get_left_image path
  #   Gosu::Image.new("#{path}/left.png")
  # end
  def self.get_image_path path
    "#{path}/default.png"
  end

  def get_image
    # puts "GET IMAGE"
    # if @right_broadside_mode
    #   return @right_broadside_image
    # elsif @left_broadside_mode
    #   return @left_broadside_image
    # else
      # puts "DEFAULT"
      # puts @image
      return @image
    # end
  end
  
  def get_image_path path
    "#{path}/default.png"
  end

  def take_damage damage
    @health -= damage * @damage_reduction
  end


  def decrement_secondary_ammo_count count = 1
    # return case @secondary_weapon
    # when 'bomb'
    #   self.bombs -= count
    # else
    #   self.rockets -= count
    # end
  end

  def get_secondary_name
    # return case @secondary_weapon
    # when 'bomb'
    #   'Bomb'
    # else
    #   'Rocket'
    # end
  end

  def get_x
    @x
  end
  def get_y
    @y
  end

  def is_alive
    health > 0
  end

  NON_ATTACK_HARDPOINT_SLOTS = [:engine]

  def attack_group initial_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer, group
    results = []
    @hardpoints.each do |hp|
      next if NON_ATTACK_HARDPOINT_SLOTS.include?(hp.slot_type)
      # puts "HARDPOINT HERE: initial_ship_angle #{initial_ship_angle}" if hp.item
      results << hp.attack(initial_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer) if hp.group_number == group && hp.item
    end
    # results = results.flatten
    results.reject!{|v| v.nil?}
    return results
  end

  def deactivate_group group_number
    # puts "deactivate_group: #{group_number}"
    @hardpoints.each do |hp|
      next if NON_ATTACK_HARDPOINT_SLOTS.include?(hp.slot_type)
      hp.stop_attack if hp.group_number == group_number
    end
  end

  def attack_group_1 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer
    return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 1)
  end

  def attack_group_2 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer
    return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 2)
  end

  def attack_group_3 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer
    return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 3)
  end

  def deactivate_group_1
    deactivate_group(1)
  end

  def deactivate_group_2
    deactivate_group(2)
  end

  def deactivate_group_3
    deactivate_group(3)
  end

  def switch_to_destroyed_image path
    @image = self.class.get_destroyed_image(path)
  end

  def turn_off_hardpoints
    @hide_hardpoints = true
  end

  def draw viewable_pixel_offset_x = 0, viewable_pixel_offset_y = 0, scale_offset = 1, options = {}
    @drawable_items_near_self.reject! { |item| item.draw(viewable_pixel_offset_x, viewable_pixel_offset_y) }
    # puts "DRAWING HARDPOINTS"
    # puts "@starboard_hard_points: #{@starboard_hard_points.count}"
    if !@hide_hardpoints
      # puts "AI DRAWING HARDPOINT HERE" if options[:test]
      # puts "@front_hard_points.first x-y #{@front_hard_points.first.x} - #{@front_hard_points.first.y}" if options[:test]
      @hardpoints.each { |item| item.draw(@x, @y, @angle, viewable_pixel_offset_x, viewable_pixel_offset_y) }
    end
    @image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, @z, -@angle, 0.5, 0.5, @width_scale * scale_offset, @height_scale * scale_offset)
    # @image.draw_rot(@x, @y, ZOrder::Projectile, @current_image_angle, 0.5, 0.5, @width_scale, @height_scale)
  end

  def draw_gl_list
    @drawable_items_near_self + [self]
  end

  def draw_gl
    # draw gl stuff
    @drawable_items_near_self.each {|item| item.draw_gl }

    @hardpoints.each { |item| item.draw_gl }

    info = @image.gl_tex_info

    # glDepthFunc(GL_GEQUAL)
    # glEnable(GL_DEPTH_TEST)
    # glEnable(GL_BLEND)

    # glMatrixMode(GL_PROJECTION)
    # glLoadIdentity
    # perspective matrix
    # glFrustum(-0.10, 0.10, -0.075, 0.075, 1, 100)

    # glMatrixMode(GL_MODELVIEW)
    # glLoadIdentity
    # glTranslated(0, 0, -4)
  
    z = @z
    
    # offs_y = 1.0 * @scrolls / SCROLLS_PER_STEP
    # offs_y = 1
    new_width1, new_height1, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y - @image_height_half/2, @screen_pixel_width, @screen_pixel_height)
    new_width2, new_height2, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y + @image_height_half/2, @screen_pixel_width, @screen_pixel_height)
    new_width3, new_height3, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y - @image_height_half/2, @screen_pixel_width, @screen_pixel_height)
    new_width4, new_height4, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y + @image_height_half/2, @screen_pixel_width, @screen_pixel_height)

    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, info.tex_name)

    glBegin(GL_TRIANGLE_STRIP)
      # glColor4d(1, 1, 1, get_draw_ordering)
      glTexCoord2d(info.left, info.top)
      # glVertex3f(new_width1, new_height1, z)

      # glColor4d(1, 1, 1, get_draw_ordering)
      glTexCoord2d(info.left, info.bottom)
      # glVertex3f(new_width2, new_height2, z)
    
      # glColor4d(1, 1, 1, get_draw_ordering)
      glTexCoord2d(info.right, info.top)
      # glVertex3f(new_width3, new_height3, z)

      # glColor4d(1, 1, 1, get_draw_ordering)
      glTexCoord2d(info.right, info.bottom)
      # glVertex3f(new_width4, new_height4, z)
    glEnd
  end
  
  def update mouse_x, mouse_y, player

    puts "BEFORE MAX CAPACOTY: #{@steam_max_capacity}"
    capacity_diff = 0
    if @current_momentum != 0 && @engine_permanent_steam_usage != 0
      @steam_max_capacity = @steam_original_max_capacity - (@engine_permanent_steam_usage * (@current_momentum.abs / (@mass)))
      if @steam_max_capacity < 0
        # capacity_diff = 0 - @steam_max_capacity
        @steam_max_capacity = 0
        puts "BLOCKLING INCREATE HERE!!!!"
        @block_momentum_increase = true if @current_momentum > 0
        @block_momentum_decrease = true if @current_momentum < 0
      else
        @block_momentum_increase = false
        @block_momentum_decrease = false
      end
    end
    puts "AFTER MAX CAPACITY: #{@steam_max_capacity}"
    # @steam_max_capacity          = steam_max_capacity #- @engine_permanent_steam_usage

    # @steam_max_capacity  = steam_max_capacity
    # @steam_rate_increase = steam_rate_increase
    # @current_steam_capacity
    puts "STARTED: #{@current_steam_capacity}"
    if @current_steam_capacity < @steam_max_capacity
      @current_steam_capacity += @steam_rate_increase
      # @steam_power = @steam_max_capacity if @current_steam_capacity > @steam_max_capacity - @engine_permanent_steam_usage
    end
    if @current_steam_capacity > @steam_max_capacity
      @current_steam_capacity = @steam_max_capacity
    end
    puts "ENDED: #{@current_steam_capacity}"

    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    # @main_weapon.update(mouse_x, mouse_y, player) if @main_weapon
    if !@hide_hardpoints
      @hardpoints.each do |hardpoint|
        # puts "UPDATING HARDPOINT HERE: #{self}"
        hardpoint.update(mouse_x, mouse_y, player)
      end
    end

    # @cooldown_wait -= 1              if @cooldown_wait > 0
    # @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    # @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    # @time_alive += 1 if self.is_alive
  end

  def collect_pickups(pickups)
    pickups.reject! do |pickup|
      if Gosu.distance(@x, @y, pickup.x, pickup.y) < ((self.get_radius) + (pickup.get_radius)) * 1.2 && pickup.respond_to?(:collected_by_player)
        pickup.collected_by_player(self)
        if pickup.respond_to?(:get_points)
          self.score += pickup.get_points
        end
        # stop that!
        # @beep.play
        true
      else
        false
      end
    end
  end


end