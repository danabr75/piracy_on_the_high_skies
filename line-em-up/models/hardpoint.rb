require_relative 'general_object.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

# Not intended to be overridden
class Hardpoint < GeneralObject
  attr_accessor :x, :y, :assigned_weapon_class, :slot_type, :radius, :angle, :center_x, :center_y
  attr_accessor :group_number, :y_offset, :x_offset, :main_weapon, :image_hardpoint, :image_hardpoint_width_half, :image_hardpoint_height_half, :image_angle


  # MISSILE_LAUNCHER_MIN_ANGLE = 75
  # MISSILE_LAUNCHER_MAX_ANGLE = 105
  # MISSILE_LAUNCHER_INIT_ANGLE = 90

  def initialize(
    x, y, group_number, x_offset, y_offset, item, slot_type, options = {}
  )
    # raise "MISSING OPTIONS HERE #{width_scale}, #{height_scale}, #{map_width}, #{map_height}" if [width_scale, height_scale, map_pixel_width, map_pixel_height].include?(nil)
    # puts "GHARDPOINT INIT: #{y_offset}"
    @group_number = group_number
    @x_offset = x_offset #* width_scale
    @y_offset = y_offset #* height_scale
    @center_x = x
    @center_y = y
    # puts "NEW RADIUS FOR HARDPOINT: #{@radius}"
    @slot_type = slot_type
    # raise "HERE: #{width_scale} - #{height_scale}"
    @x = x + x_offset #* width_scale
    @y = y + y_offset #* height_scale
#def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options = {})
# initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options = {})
    @map_pixel_width = map_pixel_width
    @map_pixel_height = map_pixel_height
  # def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height, options = {})
    super(options)
    @main_weapon = nil
    @drawable_items_near_self = []

    if item
      @assigned_weapon_class = item
      @image_hardpoint = item.get_hardpoint_image
    else
      @image_hardpoint = Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
    end
    @image_hardpoint_width_half = @image_hardpoint.width  / 2
    @image_hardpoint_height_half = @image_hardpoint.height  / 2
    @image_angle = options[:image_angle] || 0# 180
    # Maybe these are reversed?
    start_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # Not sure why the offset is getting switched somewhere...
    # Maybe the calc Angle function is off somewhere
    # Without the offset being modified, the hardpoints are flipped across the center x axis
    end_point   = OpenStruct.new(:x => (x + (@x_offset * -1)) * 1.0, :y => @y * 1.0)
    # end_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # start_point   = OpenStruct.new(:x => @x, :y => @y)
    @angle = calc_angle(start_point, end_point)
    @init_angle = @angle
    @radian = calc_radian(start_point, end_point)
    # @x = @x * width_scale
    # @y = @y * height_scale
    @radius = Gosu.distance(@center_x, @center_y, @x, @y)
    # puts "ID: #{@id}"
    # puts "START POINT : #{@center_x} - #{@center_y}"
    # puts "End POINT : #{@x} - #{@y}"
    # puts "Angle #{@angle} and radius: #{@radius}"
    # puts ""
  end


  def increment_angle angle_increment
    if @angle + angle_increment >= 360.0
      @angle = (@angle + angle_increment) - 360.0
    else
      @angle += angle_increment
    end
  end

  def decrement_angle angle_increment
    if @angle - angle_increment <= 0.0
      @angle = (@angle - angle_increment) + 360.0
    else
      @angle -= angle_increment
    end
  end


  def stop_attack
    # puts "HARDPOINT STOP ATTACK"
    @main_weapon.deactivate if @main_weapon

  end

  def convert_pointer_to_map_pixel pointer
    return [pointer.current_map_pixel_x, pointer.current_map_pixel_y]
  end

  def attack initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, options = {}
    # pointer convert to map_pixel_x and y!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # puts "pointer"
    # puts pointer
    destination_map_pixel_x, destination_map_pixel_y = convert_pointer_to_map_pixel(pointer)
    # puts "destination_map_pixel_x, destination_map_pixel_y: #{destination_map_pixel_x}  -- #{destination_map_pixel_y}"
    # puts "current_map_pixel_x, current_map_pixel_y: #{current_map_pixel_x}  -- #{current_map_pixel_y}"

    # puts "HARDPOINT ATTACK"
    attack_projectile = nil
    can_attack = false
    if @main_weapon.nil?
      # options = {damage_increase: @damage_increase, relative_y_padding: @image_height_half}
      options = {}
      options[:image_angle] = @image_angle
      if @assigned_weapon_class
        # @main_weapon = @assigned_weapon_class.new(self, options)
        @main_weapon = @assigned_weapon_class.new(options)
        can_attack = true
      end
    else
      @main_weapon.active = true if @main_weapon.active == false
      can_attack = true
    end

    if can_attack
      # attack initial_angle, current_map_pixel_x, current_map_pixel_y, destination_map_pixel_x, destination_map_pixel_y, current_map_tile_x, current_map_tile_y, options = {}
      attack_projectile = @main_weapon.attack(initial_angle, current_map_pixel_x, current_map_pixel_y, destination_map_pixel_x, destination_map_pixel_y, nil, nil, options)
      @drawable_items_near_self << @main_weapon
    end

    if attack_projectile
      return {
        projectiles: [attack_projectile],
        cooldown: @assigned_weapon_class::COOLDOWN_DELAY
      }
    else
      return nil
    end
  end

  def get_x
    @x
  end

  def get_y
    @y
  end

  def get_draw_ordering
    ZOrder::Hardpoint
  end

  def draw
    # puts "DRAWING HARDPOINT: #{@x} and #{@y}"
    @drawable_items_near_self.reject! { |item| item.draw }

    # if @image_angle != nil
    # angle = @angle + @image_angle
    angle = @image_angle + @angle - @init_angle
    # puts "ANGLE HERE: #{angle}"
    @image_hardpoint.draw_rot(@x, @y, get_draw_ordering, angle, 0.5, 0.5, @width_scale, @height_scale)
    # else
    #   @image_hardpoint.draw(@x - @image_hardpoint_width_half, @y - @image_hardpoint_height_half, get_draw_ordering, @width_scale, @height_scale)
    # end

  end

  def draw_gl
    @drawable_items_near_self.reject! { |item| item.draw_gl }
  end


  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    @center_y = player.y
    @center_x = player.x
    # Update these after angle is working (for when player is on edge of the map.)
    # @x = player.x + @x_offset# * @scale
    # @y = player.y + @y_offset# * @scale

    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    @main_weapon.update(mouse_x, mouse_y, self, scroll_factor) if @main_weapon
    # @cooldown_wait -= 1              if @cooldown_wait > 0
    # @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    # @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    # @time_alive += 1 if self.is_alive
  end

end