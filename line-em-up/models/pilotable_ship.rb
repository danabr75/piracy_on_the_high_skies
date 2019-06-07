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

  attr_accessor :bombs, :secondary_weapon, :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
  attr_accessor :special_attack, :main_weapon, :drawable_items_near_self
  attr_accessor :right_broadside_mode, :left_broadside_mode, :right_broadside_hard_points, :left_broadside_hard_points, :front_hard_points
  MAX_HEALTH = 200

  FRONT_HARDPOINT_LOCATIONS = []
  RIGHT_BROADSIDE_HARDPOINT_LOCATIONS = []
  LEFT_BROADSIDE_HARDPOINT_LOCATIONS = []

  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  CONFIG_FILE = "#{CURRENT_DIRECTORY}/../../config.txt"
  attr_accessor :angle
  # BasicShip.new(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options)
  def initialize(x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, angle, tile_pixel_width, tile_pixel_height, options = {})
    # validate_array([], self.class.name, __callee__)
    # validate_string([], self.class.name, __callee__)
    # validate_float([], self.class.name, __callee__)
    # validate_int([], self.class.name, __callee__)
    # validate_not_nil([], self.class.name, __callee__)

    validate_int([x, y, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, angle], self.class.name, __callee__)
    validate_float([width_scale, height_scale], self.class.name, __callee__)
    validate_not_nil([x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height], self.class.name, __callee__)


    @x = x
    @y = y
    puts "ShIP THOUGHT THAT THIS WAS CONFIG_FILE: #{self.class::CONFIG_FILE}"
    @angle = angle || 0
    media_path = self.class::SHIP_MEDIA_DIRECTORY
    path = media_path
    # @right_image = self.class.get_right_image(path)
    # @left_image = self.class.get_left_image(path)
    @right_broadside_image = self.class.get_right_broadside_image(path)
    @left_broadside_image = self.class.get_left_broadside_image(path)
    if options[:use_large_image]
      @use_large_image = true
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
    # trigger_hard_point_load
    @damage_reduction = options[:handicap] ? options[:handicap] : 1
    invert_handicap = 1 - @damage_reduction
    @boost_increase = invert_handicap > 0 ? 1 + (invert_handicap * 1.25) : 1
    @damage_increase = invert_handicap > 0 ? 1 + (invert_handicap) : 1
    @kill_count = 0
    @main_weapon = nil
    @drawable_items_near_self = []
    @right_broadside_mode = false
    @left_broadside_mode = false
    @front_hard_points = []
    @left_broadside_hard_points = []
    @right_broadside_hard_points = []
    @hide_hardpoints = options[:hide_hardpoints] || false

    # Load hardpoints from CONFIG FILE HERE, plug in launcher class !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    # get_config_save_settings = [self.class.name]

    # # ConfigSetting.set_mapped_setting(self.class::CONFIG_FILE, [BasicShip, 'front_hardpoint_locations', 1], 'launcher')
    # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '1'], 'launcher')
    # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '2'], 'launcher')
    # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '3'], 'launcher')
    # ConfigSetting.get_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '1'])

    # Update hardpoints location
    self.class::FRONT_HARDPOINT_LOCATIONS.each_with_index do |location, index|
      item_klass = ConfigSetting.get_mapped_setting(self.class::CONFIG_FILE, [self.class.name, 'front_hardpoint_locations', index.to_s])
      item_klass = eval(item_klass) if item_klass
      # width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height,
      # x, y, group_number, x_offset, y_offset, item, slot_type
      @front_hard_points << Hardpoint.new(
        x, y, 1, location[:x_offset].call(get_image, (width_scale + height_scale) / 2.0),
        location[:y_offset].call(get_image, (width_scale + height_scale) / 2.0), item_klass, location[:slot_type], options
      )
      # @front_hard_points << Hardpoint.new(scale, x, y, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, @scale), location[:y_offset].call(get_image, @scale), nil, options)
    end
    # puts "Front hard points"
    self.class::RIGHT_BROADSIDE_HARDPOINT_LOCATIONS.each_with_index do |location,index|
      # if index < 2
      item_klass = ConfigSetting.get_mapped_setting(self.class::CONFIG_FILE, [self.class.name, 'right_hardpoint_locations', index.to_s])
      item_klass = eval(item_klass) if item_klass
        options[:image_angle] = 90
        # @right_broadside_hard_points << Hardpoint.new(scale, x, y, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, @scale), location[:y_offset].call(get_image, @scale), LaserLauncher, options)
        @right_broadside_hard_points << Hardpoint.new(x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, (width_scale + height_scale) / 2.0), location[:y_offset].call(get_image, (width_scale + height_scale) / 2.0), item_klass, location[:slot_type], map_pixel_width, map_pixel_height, options)
      # else
      #   @right_broadside_hard_points << Hardpoint.new(scale, x, y, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, @scale), location[:y_offset].call(get_image, @scale), LaserLauncher, options)
      # end
    end
    self.class::LEFT_BROADSIDE_HARDPOINT_LOCATIONS.each_with_index do |location,index|
      # @broadside_hard_points << Hardpoint.new(scale, x, y, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, @scale), location[:y_offset].call(get_image, @scale), LaserLauncher, options)
      item_klass = ConfigSetting.get_mapped_setting(self.class::CONFIG_FILE, [self.class.name, 'left_hardpoint_locations', index.to_s])
      item_klass = eval(item_klass) if item_klass
      options[:image_angle] = 270
      @left_broadside_hard_points << Hardpoint.new(x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, @scale), location[:y_offset].call(get_image, @scale), item_klass, location[:slot_type], map_pixel_width, map_pixel_height, options)
    end
    @theta = nil
  end

  # right broadside
  def rotate_hardpoints_counterclockwise angle_increment
    [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
      group.each do |hp|
        step = (Math::PI/180 * (hp.angle)) + 90.0 + 45.0# - 180
        # step = step.round(5)
        hp.x = Math.cos(step) * hp.radius + hp.center_x
        hp.y = Math.sin(step) * hp.radius + hp.center_y

        hp.increment_angle(angle_increment)
        # puts "POST - CC ANGLE: #{hp.angle}"

      end
    end
  end

  # left broadside
  # Key: E
  def rotate_hardpoints_clockwise angle_increment
    [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
      group.each do |hp|
        # 90 and 45 should probably from from hp.. image angle?
        step = (Math::PI/180 * (hp.angle)) + 90.0 + 45.0# - 180
        # step = step.round(5)
        hp.x = Math.cos(step) * hp.radius + hp.center_x
        hp.y = Math.sin(step) * hp.radius + hp.center_y

        hp.decrement_angle(angle_increment)
      end
    end
  end


  def add_hard_point hard_point
  #   @hard_point_items << hard_point
  #   trigger_hard_point_load
  end

  def self.get_image_assets_path
    SHIP_MEDIA_DIRECTORY
  end

  def self.get_right_broadside_image path
    Gosu::Image.new("#{path}/right_broadside.png")
  end
  def self.get_left_broadside_image path
    Gosu::Image.new("#{path}/left_broadside.png")
  end
  def self.get_image path
    Gosu::Image.new("#{path}/default.png")
  end

  def self.get_large_image path
    Gosu::Image.new("#{path}/large.png")
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
    if @right_broadside_mode
      return @right_broadside_image
    elsif @left_broadside_mode
      return @left_broadside_image
    else
      # puts "DEFAULT"
      # puts @image
      return @image
    end
  end
  
  def get_image_path path
    "#{path}/default.png"
  end

  def take_damage damage
    @health -= damage * @damage_reduction
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

  #   [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.x = @x + hp.x_offset
  #     end
  #   end
  #   return @x
  # end
  
  # def move_right
  #   @turn_right = true
  #   @x = [@x + get_speed, (@screen_pixel_width - (get_width/3))].min

  #   [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
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

  #   [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.y = @y + hp.y_offset
  #     end
  #   end
  #   return @y
  # end
  
  # def brake
  #   @y = [@y + get_speed, @max_movable_height - (get_height/2)].min

  #   [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
  #     group.each do |hp|
  #       hp.y = @y + hp.y_offset
  #     end
  #   end
  #   return @y
  # end

  def attack_group initial_angle, current_map_pixel_x, current_map_pixel_y, map_pixel_width, map_pixel_height, pointer, group, relative_object_offset_x, relative_object_offset_y
    if @left_broadside_mode
      # puts "@broadside_hard_points: #{@broadside_hard_points}"
      results = @left_broadside_hard_points.collect do |hp|
        # puts "HP #{hp}"
        hp.attack(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, relative_object_offset_x, relative_object_offset_y) if hp.group_number == group
      end
      # puts "Results :#{results}"
    elsif @right_broadside_mode
      results = @right_broadside_hard_points.collect do |hp|
        # puts "HP #{hp}"
        hp.attack(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, relative_object_offset_x, relative_object_offset_y) if hp.group_number == group
      end
    else
      # puts "@front_hard_points: #{@front_hard_points}"
      results = @front_hard_points.collect do |hp|
        # puts "HP #{hp}"
        hp.attack(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, relative_object_offset_x, relative_object_offset_y) if hp.group_number == group
      end
    end
    results.reject!{|v| v.nil?}
    # puts "Results: #{results}"
    return results
  end

  def deactivate_group group_number
    # puts "deactivate_group: #{group_number}"
    [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
      group.each do |hp|
        # puts "STOPPING ATTACK #{hp.group_number} == #{group_number}: #{hp.group_number == group_number}"
        hp.stop_attack if hp.group_number == group_number
      end
    end
  end

  def attack_group_1 initial_angle, current_map_pixel_x, current_map_pixel_y, map_pixel_width, map_pixel_height, pointer, relative_object_offset_x, relative_object_offset_y
    return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, map_pixel_width, map_pixel_height, pointer, 1, relative_object_offset_x, relative_object_offset_y)
  end

  def attack_group_2 initial_angle, current_map_pixel_x, current_map_pixel_y, map_pixel_width, map_pixel_height, pointer, relative_object_offset_x, relative_object_offset_y
    return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, map_pixel_width, map_pixel_height, pointer, 2, relative_object_offset_x, relative_object_offset_y)
  end

  def deactivate_group_1
    deactivate_group(1)
  end

  def deactivate_group_2
    deactivate_group(2)
  end

  def get_draw_ordering
    ZOrder::Ship
  end

  def draw
    @drawable_items_near_self.reject! { |item| item.draw }
    # puts "DRAWING HARDPOINTS"
    # puts "@right_broadside_hard_points: #{@right_broadside_hard_points.count}"
    if !@hide_hardpoints
      @right_broadside_hard_points.each { |item| item.draw }
      @left_broadside_hard_points.each { |item| item.draw }
      @front_hard_points.each { |item| item.draw }
    end

    # test = Ashton::ParticleEmitter.new(@x, @y, get_draw_ordering)
    # test.draw
    # test.update(5.0)
    # image = self.get_image
    # Why using self?
    image = self.get_image
    # if @broadside_mode
    #   image = @broadside_image
    # else
    #   if @turn_right
    #     image = @right_image
    #   elsif @turn_left
    #     image = @left_image
    #   else
    #     image = @image
    #   end
    # end
    # super
    # puts "DRAWING PLAYER: #{[@x, @y, get_draw_ordering, @angle, 0.5, 0.5, @width_scale, @height_scale]}"
    # DRAWING PLAYER: [450, 450, 8, {:handicap=>1, :max_movable_height=>-27960.0, :tile_width=>112.5, :tile_height=>112.5}, 0.5, 0.5, 1.875, 1.875]
    image.draw_rot(@x, @y, get_draw_ordering, @angle, 0.5, 0.5, @width_scale, @height_scale)
    # @image.draw_rot(@x, @y, ZOrder::Projectile, @current_image_angle, 0.5, 0.5, @width_scale, @height_scale)
    @turn_right = false
    @turn_left = false
  end

  POINTS_X = 7
  POINTS_Y = 7

  def draw_gl_list
    @drawable_items_near_self + [self]
  end

  def draw_gl
    # draw gl stuff
    @drawable_items_near_self.each {|item| item.draw_gl }

    @left_broadside_hard_points.each { |item| item.draw_gl }
    @right_broadside_hard_points.each { |item| item.draw_gl }
    @front_hard_points.each { |item| item.draw_gl }

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
  
    z = get_draw_ordering
    
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
  
  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    # @main_weapon.update(mouse_x, mouse_y, player) if @main_weapon
    @front_hard_points.each do |hardpoint|
      hardpoint.update(mouse_x, mouse_y, self, scroll_factor)
    end
    @left_broadside_hard_points.each do |hardpoint|
      hardpoint.update(mouse_x, mouse_y, self, scroll_factor)
    end
    @right_broadside_hard_points.each do |hardpoint|
      hardpoint.update(mouse_x, mouse_y, self, scroll_factor)
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