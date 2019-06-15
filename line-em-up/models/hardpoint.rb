require_relative 'general_object.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

# Not intended to be overridden
class Hardpoint < GeneralObject
  attr_accessor :x, :y, :assigned_weapon_class, :slot_type, :radius, :angle, :center_x, :center_y
  attr_accessor :group_number, :y_offset, :x_offset, :main_weapon, :image_hardpoint, :image_angle

  def initialize(x, y, z, group_number, x_offset, y_offset, item, slot_type, current_ship_angle, angle_offset, options = {})
    # raise "MISSING OPTIONS HERE #{width_scale}, #{height_scale}, #{map_width}, #{map_height}" if [width_scale, height_scale, map_pixel_width, map_pixel_height].include?(nil)
    @group_number = group_number

    @center_x = x
    @center_y = y
    @z = z
    # puts "NEW RADIUS FOR HARDPOINT: #{@radius}"
    @slot_type = slot_type

    super(options)
    puts "GHARDPOINT ID: #{@id}"

    # Scale is already built into offset, via the lambda call
    @x_offset = x_offset #* -1#* width_scale
    @y_offset = y_offset #* height_scale

    # Storing the angle offset here.. oddly enough, don't need it here. Could replace options[:image_angle]
    # The actual angle is calculated via the start and end point
    @angle_offset = angle_offset

    if options[:block_initial_angle]
      puts "block_initial_angle"
      # X IS flipped when non-angling, to be compatible to be displayed without using the angle system.
      @x = x - @x_offset
      @y = y + @y_offset
    else
      @x = x + @x_offset
      @y = y + @y_offset
    end

    @main_weapon = nil
    @drawable_items_near_self = []

    @item = item
    if item
      @assigned_weapon_class = item
      @image_hardpoint = item.get_hardpoint_image
    else
      @image_hardpoint = Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
    end
    @image_angle = options[:image_angle] || 0
    # Maybe these are reversed?
    start_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # Not sure why the offset is getting switched somewhere...
    # Maybe the calc Angle function is off somewhere
    # Without the offset being modified, the hardpoints are flipped across the center x axis
    end_point   = OpenStruct.new(:x => @x, :y => @y)
    # end_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # start_point   = OpenStruct.new(:x => @x, :y => @y)
    @angle = calc_angle(start_point, end_point)
    # ANGLE IS OFF, NOT SURE WHY
    @angle = @angle + 5
    # @init_angle = @angle + current_ship_angle
     # "INIT ANGLE HERE" if options[:from_player]
    # puts "#{@init_angle} = #{@angle} + #{current_ship_angle}"
    @radian = calc_radian(start_point, end_point)
    # @x = @x * width_scale
    # @y = @y * height_scale
    @radius = Gosu.distance(@center_x, @center_y, @x, @y)
    # puts "@radius = Gosu.distance(@center_x, @center_y, @x, @y)"
    # puts "#{@radius} = Gosu.distance(#{@center_x}, #{@center_y}, #{@x}, #{@y})"

    # Increlementing at 0 will adjust the x and y, to make them slightly off.
    # if options[:block_initial_angle]
    #   puts "block_initial_angle"
    #   # The graphical Gosu image drawing system needs the offset minused.
    #   # The angle determining system requires it positive
    #   # This is a mystery
    #   # Can't run these commands after the angling, causes a pixel shift
    #   # @x = x + @x_offset
    #   # @y = y + @y_offset
    # else
    #   # puts "OLD ANGLE: #{@angle} w/ current ship angle: #{current_ship_angle}"
    #   # # Radian, Angle, and distance all check out. Not sure why the angle increment swaps the x offset, or why the angle looks slightly off.
    #   # # This is a stop-gap measure
    #   # @angle = @angle + 5
    #   # self.increment_angle(current_ship_angle) # if current_ship_angle != 0.0
    #   # puts "NEW ANGLE: #{@angle}"
    #   # puts "NEW X AND Y: #{@x} - #{@y}"
    # end
    # puts "NEW Y: #{@y}"
    # raise "old_y is not equal to y: #{old_y} - #{@y}. Angle: #{current_ship_angle}" if old_y != @y
    puts "END HARDPOINT #{@id}"
  end


  # def increment_angle angle_increment
  #   # puts "HUH?  #{angle_increment}"
  #   if @angle + angle_increment >= 360.0
  #     @angle = (@angle + angle_increment) - 360.0
  #   else
  #     @angle += angle_increment
  #   end
  #   step = (Math::PI/180 * (@angle)) + 90.0 + 45.0# - 180
  #   # step = step.round(5)
  #   @x = Math.cos(step) * @radius + @center_x
  #   @y = Math.sin(step) * @radius + @center_y
  #   # @x = @x + @x_offset
  #   # @y = @y + @y_offset
  # end

  # def decrement_angle angle_increment
  #   if @angle - angle_increment <= 0.0
  #     @angle = (@angle - angle_increment) + 360.0
  #   else
  #     @angle -= angle_increment
  #   end
  #   step = (Math::PI/180 * (@angle)) + 90.0 + 45.0# - 180
  #   # step = step.round(5)
  #   @x = Math.cos(step) * @radius + @center_x
  #   @y = Math.sin(step) * @radius + @center_y
  # end


  def stop_attack
    # puts "HARDPOINT STOP ATTACK"
    @main_weapon.deactivate if @main_weapon

  end

  def convert_pointer_to_map_pixel pointer
    return [pointer.current_map_pixel_x, pointer.current_map_pixel_y]
  end

  # Pointer can be cursor.. or player..
  def attack initial_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer, options = {}
    puts "HARDPOINT ATTACK: #{[initial_ship_angle, current_map_pixel_x, current_map_pixel_y]}"
    # pointer convert to map_pixel_x and y!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # puts "pointer"
    # puts pointer
    destination_map_pixel_x, destination_map_pixel_y = convert_pointer_to_map_pixel(pointer)
    puts "DESTINATION ATTACK: #{[initial_ship_angle, current_map_pixel_x, current_map_pixel_y]}"

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
      puts "HARDPOINT CACLINGV"

      # DRAWING
    # Pointed North
    # DRAWING HARDPOINT ANGLE: 76.11199883909319 = 0 + 76.11199883909319
    # Pointed West
    # DRAWING HARDPOINT ANGLE: 346.1119988390932 = 270 + 76.11199883909319
      puts "ATTACking ANGLE HERE:  #{@angle + initial_ship_angle + @angle_offset} = #{@angle} + #{initial_ship_angle}  + #{@angle_offset}"
      # ATTACHKING NORTH
      # ATTACking ANGLE HERE:  76.11199883909319 = 76.11199883909319 + 0
      # ATTCKING WEST
      # 
      step = (Math::PI/180 * (@angle + initial_ship_angle + @angle_offset)) + 90.0 + 45.0# - 180
      # step = step.round(5)
      puts "INGOING: #{current_map_pixel_x.round(2)} - #{current_map_pixel_y.round(2)}"
      projectile_x = Math.cos(step) * @radius + current_map_pixel_x
      # Adjustment - due to X offset issue
      projectile_x = current_map_pixel_x + (current_map_pixel_x - projectile_x)
      projectile_y = Math.sin(step) * @radius + current_map_pixel_y
      # projectile_y = current_map_pixel_y + (current_map_pixel_y - projectile_y)
      puts "OUTGOING: #{projectile_x.round(2)} - #{projectile_y.round(2)}"
      puts "WHATISB : #{(current_map_pixel_x + @x_offset).round(2)} - #{(current_map_pixel_y + @y_offset).round(2)}"

      # attack initial_angle, current_map_pixel_x, current_map_pixel_y, destination_map_pixel_x, destination_map_pixel_y, current_map_tile_x, current_map_tile_y, options = {}
      puts "BULLET LAUNCH ANGLE: #{@angle + initial_ship_angle + @angle_offset} = #{@angle} + #{initial_ship_angle} + #{@angle_offset}"
      # 426.0202923020712 = 66.02029230207123 + 90 + 270
      #   should be correct: initial_angle
      #   should be correct: initial_angle
      attack_projectile = @main_weapon.attack(initial_ship_angle, projectile_x, projectile_y, destination_angle, start_point, end_point, nil, nil, options)
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

  # def get_draw_ordering
  #   ZOrder::Hardpoint
  # end

  def draw center_x, center_y, angle
    # puts "DRAWING HARDPOINT ANGLE: #{angle + @angle} = #{angle} + #{@angle}" if @item
    # Pointed North
    # DRAWING HARDPOINT ANGLE: 76.11199883909319 = 0 + 76.11199883909319
    # Pointed West
    # DRAWING HARDPOINT ANGLE: 346.1119988390932 = 270 + 76.11199883909319
    step = (Math::PI/180 * (angle + @angle)) + 90.0 + 45.0# - 180
    # step = step.round(5)
    @x = Math.cos(step) * @radius + center_x
    @y = Math.sin(step) * @radius + center_y

    # puts "DRAWING HARDPOINT: #{@x} and #{@y}"
    @drawable_items_near_self.reject! { |item| item.draw }

    # if @image_angle != nil
    # angle = @angle + @image_angle
    # puts "ANGLE HERE: #{angle}"
    @image_hardpoint.draw_rot(@x, @y, @z, @image_angle + angle, 0.5, 0.5, @width_scale, @height_scale)
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