require_relative 'general_object.rb'
require_relative 'rocket_launcher_pickup.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

class PilotableShip < GeneralObject
  SHIP_MEDIA_DIRECTORY = "#{MEDIA_DIRECTORY}/pilotable_ships/basic_ship"
  SPEED = 7
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive

  attr_accessor :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
  attr_accessor :special_attack, :main_weapon, :drawable_items_near_self
  attr_accessor :hardpoints
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
    puts "ShIP THOUGHT THAT THIS WAS CONFIG_FILE: #{self.class::CONFIG_FILE}"
    @angle = angle
    media_path = self.class::SHIP_MEDIA_DIRECTORY
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
    if @debug
      @health = INIT_HEALTH * 10000
    else
      @health = INIT_HEALTH
    end
    @armor = 0
    @rockets = 50
    # @rockets = 250
    @bombs = 3
    @secondary_weapon = RocketLauncherPickup::NAME

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
    @hardpoints = Array.new(self.class::HARDPOINT_LOCATIONS.length) {nil}
    self.class::HARDPOINT_LOCATIONS.each_with_index do |location, index|
      item_klass_string = options[:hardpoint_data] ? options[:hardpoint_data][index.to_s] : nil
      item_klass = item_klass_string && item_klass_string != '' ? eval(item_klass_string) : nil
      raise "bad slot type" if location[:slot_type].nil?
      raise "bad anlge"     if location[:angle_offset].nil?
      options[:block_initial_angle] = true if disable_hardpoint_angles
      # raise "STOP RIGHT HERE" if disable_hardpoint_angles
      hp = Hardpoint.new(
        x, y, hardpoint_z, location[:x_offset].call(get_image, @width_scale),
        location[:y_offset].call(get_image, @height_scale), item_klass, location[:slot_type], @angle, location[:angle_offset], owner, options
      )
      @hardpoints[index] = hp
    end
    options.delete(:hardpoint_data)



    @hardpoints.each_with_index do |hp, hp_index|
      raise "HP WAS NIL HERE: #{hp_index} for group: #{group_index}" if hp.nil?
    end

    @theta = nil
    @speed = self.class::SPEED
    @mass = self.class::MASS
  end

  # right broadside
  # def rotate_hardpoints_counterclockwise angle_increment
  #   [@starboard_hard_points, @port_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.increment_angle(angle_increment)
  #     end
  #   end
  # end

  # # left broadside
  # # Key: E
  # def rotate_hardpoints_clockwise angle_increment
  #   [@starboard_hard_points, @port_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.decrement_angle(angle_increment)
  #     end
  #   end
  # end


  def add_hard_point hard_point
  #   @hard_point_items << hard_point
  #   trigger_hard_point_load
  end

  def self.get_image_assets_path
    SHIP_MEDIA_DIRECTORY
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

  # def get_speed
  #   if @left_broadside_mode || @right_broadside_mode
  #     speed = self.class::SPEED * 0.3
  #   else
  #     speed = self.class::SPEED
  #   end
  #   (speed * @scale).round
  # end

  # def move_left
  #   @turn_left = true
  #   @x = [@x - get_speed, (get_width/3)].max

  #   [@starboard_hard_points, @port_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.x = @x + hp.x_offset
  #     end
  #   end
  #   return @x
  # end
  
  # def move_right
  #   @turn_right = true
  #   @x = [@x + get_speed, (@screen_pixel_width - (get_width/3))].min

  #   [@starboard_hard_points, @port_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.x = @x + hp.x_offset
  #     end
  #   end
  #   return @x
  # end
  
  # def accelerate
  #   # # Top of screen
  #   # @min_moveable_height = options[:min_moveable_height] || 0
  #   # # Bottom of the screen
  #   # @max_movable_height = options[:max_movable_height] || screen_pixel_height

  #   @y = [@y - get_speed, @min_moveable_height + (get_height/2)].max

  #   [@starboard_hard_points, @port_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.y = @y + hp.y_offset
  #     end
  #   end
  #   return @y
  # end
  
  # def brake
  #   @y = [@y + get_speed, @max_movable_height - (get_height/2)].min

  #   [@starboard_hard_points, @port_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.y = @y + hp.y_offset
  #     end
  #   end
  #   return @y
  # end

  def attack_group initial_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer, group
    results = []
    @hardpoints.each do |hp|
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

  def draw
    @drawable_items_near_self.reject! { |item| item.draw }
    # puts "DRAWING HARDPOINTS"
    # puts "@starboard_hard_points: #{@starboard_hard_points.count}"
    if !@hide_hardpoints
      # puts "AI DRAWING HARDPOINT HERE" if options[:test]
      # puts "@front_hard_points.first x-y #{@front_hard_points.first.x} - #{@front_hard_points.first.y}" if options[:test]
      @hardpoints.each { |item| item.draw(@x, @y, @angle) }
    end
    @image.draw_rot(@x, @y, @z, -@angle, 0.5, 0.5, @width_scale, @height_scale)
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
    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    # @main_weapon.update(mouse_x, mouse_y, player) if @main_weapon
    @hardpoints.each do |hardpoint|
      # puts "UPDATING HARDPOINT HERE: #{self}"
      hardpoint.update(mouse_x, mouse_y, self)
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