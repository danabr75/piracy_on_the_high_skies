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

  def initialize(x, y, group_number, x_offset, y_offset, item, slot_type, current_ship_angle, options = {})
    # raise "MISSING OPTIONS HERE #{width_scale}, #{height_scale}, #{map_width}, #{map_height}" if [width_scale, height_scale, map_pixel_width, map_pixel_height].include?(nil)
    # puts "GHARDPOINT INIT: #{y_offset}"
    @group_number = group_number

    @center_x = x
    @center_y = y
    # puts "NEW RADIUS FOR HARDPOINT: #{@radius}"
    @slot_type = slot_type
    # raise "HERE: #{width_scale} - #{height_scale}"
#def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options = {})
# initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options = {})
    @map_pixel_width = map_pixel_width
    @map_pixel_height = map_pixel_height
  # def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height, options = {})
    super(options)

    # Scale is already built into offset, via the lambda call
    @x_offset = x_offset #* width_scale
    @y_offset = y_offset #* height_scale


    @x = x + @x_offset
    @y = y + @y_offset

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
    @image_angle = options[:image_angle] || 0
    # Maybe these are reversed?
    start_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # Not sure why the offset is getting switched somewhere...
    # Maybe the calc Angle function is off somewhere
    # Without the offset being modified, the hardpoints are flipped across the center x axis
    end_point   = OpenStruct.new(:x => (x + (@x_offset * -1)) * 1.0, :y => @y * 1.0)
    # end_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # start_point   = OpenStruct.new(:x => @x, :y => @y)
    @angle = calc_angle(start_point, end_point)
    @init_angle = @angle# + current_ship_angle
     "INIT ANGLE HERE" if options[:from_player]
    puts "#{@init_angle} = #{@angle} + #{current_ship_angle}"
    @radian = calc_radian(start_point, end_point)
    # @x = @x * width_scale
    # @y = @y * height_scale
    @radius = Gosu.distance(@center_x, @center_y, @x, @y)
    # puts "ID: #{@id}"
    # puts "START POINT : #{@center_x} - #{@center_y}"
    # puts "End POINT : #{@x} - #{@y}"
    # puts "Angle #{@angle} and radius: #{@radius}"
    # puts ""
    # if current_ship_angle == 0
    #   # Do nothing
    # else
    #   increment_angle(current_ship_angle)
    # end
    # init location. Don't need to set X or Y
    puts "init_angle: #{@init_angle} and ship angle: #{current_ship_angle}" if options[:from_player]
    self.increment_angle(current_ship_angle)
    puts "POST ANGLE: #{@angle}" if options[:from_player]
  end


  def increment_angle angle_increment
    if @angle + angle_increment >= 360.0
      @angle = (@angle + angle_increment) - 360.0
    else
      @angle += angle_increment
    end
    step = (Math::PI/180 * (@angle)) + 90.0 + 45.0# - 180
    # step = step.round(5)
    @x = Math.cos(step) * @radius + @center_x
    @y = Math.sin(step) * @radius + @center_y
  end

  def decrement_angle angle_increment
    if @angle - angle_increment <= 0.0
      @angle = (@angle - angle_increment) + 360.0
    else
      @angle -= angle_increment
    end
    step = (Math::PI/180 * (@angle)) + 90.0 + 45.0# - 180
    # step = step.round(5)
    @x = Math.cos(step) * @radius + @center_x
    @y = Math.sin(step) * @radius + @center_y
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
      start_point = OpenStruct.new(:x => current_map_pixel_x,     :y => current_map_pixel_y)
      end_point   = OpenStruct.new(:x => destination_map_pixel_x, :y => destination_map_pixel_y)
      # Reorienting angle to make 0 north
      destination_angle = calc_angle(start_point, end_point) - 90
      if destination_angle < 0.0
        destination_angle = 360.0 - destination_angle.abs
      elsif destination_angle > 360.0
        destination_angle = destination_angle - 360.0
      end

      raise "DESTINATION ANGLE WAS NOT BETWEEN 0 and 360: #{destination_angle}. from start #{[current_map_pixel_x.round(1), current_map_pixel_y.round(1)]} to end: #{[destination_map_pixel_x.round(1), destination_map_pixel_y.round(1)]}" if destination_angle < 0.0 || destination_angle > 360.0

      # attack initial_angle, current_map_pixel_x, current_map_pixel_y, destination_map_pixel_x, destination_map_pixel_y, current_map_tile_x, current_map_tile_y, options = {}
      attack_projectile = @main_weapon.attack(initial_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, nil, nil, options)
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


  def update mouse_x, mouse_y, player
    # Center should stay the same
    # @center_y = player.y
    # @center_x = player.x


    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    @main_weapon.update(mouse_x, mouse_y, self) if @main_weapon
    # @cooldown_wait -= 1              if @cooldown_wait > 0
    # @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    # @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    # @time_alive += 1 if self.is_alive
  end

end