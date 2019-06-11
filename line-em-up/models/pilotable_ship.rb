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
  def initialize(x, y, angle, options = {})

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
    puts "ShIP THOUGHT THAT THIS WAS CONFIG_FILE: #{self.class::CONFIG_FILE}"
    @angle = angle
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
      # puts "ANGLE HERE: #{@angle}"
      hp = Hardpoint.new(
        x, y, 1, location[:x_offset].call(get_image, @average_scale),
        location[:y_offset].call(get_image, @average_scale), item_klass, location[:slot_type], @angle, 0, options
      )
      # Init HP location
      # hp.rotate_hardpoints_counterclockwise(0)
      # .merge({init_angle: @angle}
      # if @angle > 
      # puts "ANGLE HERE: #{@angle}"
      # rotate_hardpoints_counterclockwise(@angle)
      @front_hard_points << hp
    end
    # puts "Front hard points"
    self.class::RIGHT_BROADSIDE_HARDPOINT_LOCATIONS.each_with_index do |location,index|
      # if index < 2
      item_klass = ConfigSetting.get_mapped_setting(self.class::CONFIG_FILE, [self.class.name, 'right_hardpoint_locations', index.to_s])
      item_klass = eval(item_klass) if item_klass
      options[:image_angle] = 90
        # @right_broadside_hard_points << Hardpoint.new(scale, x, y, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, @scale), location[:y_offset].call(get_image, @scale), LaserLauncher, options)
        # @right_broadside_hard_points << Hardpoint.new(x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, (width_scale + height_scale) / 2.0), location[:y_offset].call(get_image, (width_scale + height_scale) / 2.0), item_klass, location[:slot_type], map_pixel_width, map_pixel_height, options)
      # else
      #   @right_broadside_hard_points << Hardpoint.new(scale, x, y, screen_pixel_width, screen_pixel_height, 1, location[:x_offset].call(get_image, @scale), location[:y_offset].call(get_image, @scale), LaserLauncher, options)
      # end
      hp = Hardpoint.new(
        x, y, 1, location[:x_offset].call(get_image, @average_scale),
        location[:y_offset].call(get_image, @average_scale), item_klass, location[:slot_type].to_s + 'test', @angle, 90, options
      )
      @right_broadside_hard_points << hp
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
        hp.increment_angle(angle_increment)
      end
    end
  end

  # left broadside
  # Key: E
  def rotate_hardpoints_clockwise angle_increment
    [@right_broadside_hard_points, @left_broadside_hard_points, @front_hard_points].each do |group|
      group.each do |hp|
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

  def attack_group initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, group
    results = []
    [
      {objects: @right_broadside_hard_points,  angle_offset: 90},
      {objects: @left_broadside_hard_points,   angle_offset: -90},
      {objects: @front_hard_points,            angle_offset: 0}
    ].each do |section|
      results << section[:objects].collect do |hp|
        hp.attack(initial_angle + section[:angle_offset], current_map_pixel_x, current_map_pixel_y, pointer) if hp.group_number == group
      end
    end
    results = results.flatten
    results.reject!{|v| v.nil?}
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

# RESULT HERE?
# [{:projectiles=>[#<Missile:0x00007f97cd75c6c0 @tile_pixel_width=112.5, @tile_pixel_height=112.5, @map_pixel_width=28125, @map_pixel_height=28125, @map_tile_width=250, @map_tile_height=250, @width_scale=1.875, @height_scale=1.875, @screen_pixel_width=900, @screen_pixel_height=900, @debug=true, @damage_increase=1, @average_scale=1.7578125, @id="40347bd5-cc14-4ab0-95a5-13ecb7619954", @image=##############
# #      o     #
# #     .@.    #
# #     i@.    #
# #     i@i    #
# #     i@i    #
# #     o@i    #
# #     V@V    #
# #     @@V    #
# #     @@V    #
# #     @@V    #
# #     @@V    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #            #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@:  #
# #   i@@@@@@M.#
# # .M@@@@@@@@@#
# #.@@@@@@@@@@@#
# #i@@@@@@@@@@:#
# #.@@@@@@@@V: #
# #  :M@@@@M   #
# #    :M@M.   #
# #     V@V    #
# ##############
# , @time_alive=0, @image_width=22.5, @image_height=78.75, @image_size=885.9375, @image_radius=25.3125, @image_width_half=11.25, @image_height_half=39.375, @inited=true, @x=-50, @y=-50, @x_offset=0, @y_offset=0, @current_map_pixel_x=14054.801557577564, @current_map_pixel_y=14012.875559766864, @current_map_tile_x=124, @current_map_tile_y=124, @angle=359.2119350338511, @radian=1.5570419984159805, @health=1, @end_image_angle=449.2119350338511, @current_image_angle=90, @image_angle_incrementor=0.2>], :cooldown=>45}, {:projectiles=>[#<Missile:0x00007f97ce2af040 @tile_pixel_width=112.5, @tile_pixel_height=112.5, @map_pixel_width=28125, @map_pixel_height=28125, @map_tile_width=250, @map_tile_height=250, @width_scale=1.875, @height_scale=1.875, @screen_pixel_width=900, @screen_pixel_height=900, @debug=true, @damage_increase=1, @average_scale=1.7578125, @id="f2cc89b4-28ef-4e3f-9abc-23f6566abdad", @image=##############
# #      o     #
# #     .@.    #
# #     i@.    #
# #     i@i    #
# #     i@i    #
# #     o@i    #
# #     V@V    #
# #     @@V    #
# #     @@V    #
# #     @@V    #
# #     @@V    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #     @@@    #
# #            #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@   #
# #    @@@@@:  #
# #   i@@@@@@M.#
# # .M@@@@@@@@@#
# #.@@@@@@@@@@@#
# #i@@@@@@@@@@:#
# #.@@@@@@@@V: #
# #  :M@@@@M   #
# #    :M@M.   #
# #     V@V    #
# ##############
# , @time_alive=0, @image_width=22.5, @image_height=78.75, @image_size=885.9375, @image_radius=25.3125, @image_width_half=11.25, @image_height_half=39.375, @inited=true, @x=-50, @y=-50, @x_offset=0, @y_offset=0, @current_map_pixel_x=14078.814389317577, @current_map_pixel_y=14015.00587630687, @current_map_tile_x=125, @current_map_tile_y=124, @angle=359.2119350338511, @radian=1.5570419984159805, @health=1, @end_image_angle=449.2119350338511, @current_image_angle=90, @image_angle_incrementor=0.2>], :cooldown=>45}]

  def attack_group_1 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer
    return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 1)
  end

  def attack_group_2 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer
    return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 2)
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
    # image = self.get_image
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
    @image.draw_rot(@x, @y, get_draw_ordering, @angle, 0.5, 0.5, @width_scale, @height_scale)
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
  
  def update mouse_x = nil, mouse_y = nil, player = nil
    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    # @main_weapon.update(mouse_x, mouse_y, player) if @main_weapon
    @front_hard_points.each do |hardpoint|
      hardpoint.update(mouse_x, mouse_y, self)
    end
    @left_broadside_hard_points.each do |hardpoint|
      hardpoint.update(mouse_x, mouse_y, self)
    end
    @right_broadside_hard_points.each do |hardpoint|
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