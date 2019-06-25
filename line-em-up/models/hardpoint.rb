require_relative 'general_object.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

# Not intended to be overridden
# Is a Hardpoint Container
class Hardpoint < GeneralObject
  attr_accessor :x, :y, :assigned_weapon_class, :slot_type, :radius, :angle_from_center, :center_x, :center_y
  attr_accessor :group_number, :y_offset, :x_offset, :main_weapon, :image_hardpoint, :image_angle
  attr_accessor :item

  attr_reader :hardpoint_colors

  def get_radius
    @image_radius / 5
  end

  def initialize(x, y, z, x_offset, y_offset, item_klass, slot_type, current_ship_angle, angle_offset, owner, options = {})
    # raise "MISSING OPTIONS HERE #{width_scale}, #{height_scale}, #{map_width}, #{map_height}" if [width_scale, height_scale, map_pixel_width, map_pixel_height].include?(nil)
    # @group_number = group_number

    @center_x = x
    @center_y = y
    @z = z
    # puts "NEW RADIUS FOR HARDPOINT: #{@radius}"
    @slot_type = slot_type

    @hardpoint_colors = self.class.get_hardpoint_colors(@slot_type)

    super(options)
    # puts "GHARDPOINT ID: #{@id}"

    # Scale is already built into offset, via the lambda call
    @x_offset = -x_offset #* -1#* width_scale
    @y_offset = y_offset #* height_scale

    # Used for image calculation and firing angle
    @angle_offset = angle_offset

    if options[:block_initial_angle]
      # puts "block_initial_angle"
      # We're minus, cause the screen and map x are opposed. If we're not angling, then we don't have to obey the map orientation.
      @x = x - @x_offset
      @y = y + @y_offset
    else
      # X IS flipped when non-angling because the Screen X and the Map X are opposed
      @x = x + @x_offset
      @y = y + @y_offset
    end

    @main_weapon = nil
    @drawable_items_near_self = []

    @item_klass = item_klass
    if @item_klass
      @assigned_weapon_class = @item_klass
      # @image_hardpoint = @item_klass.get_hardpoint_image
      @group_number  = @item_klass::FIRING_GROUP_NUMBER
    else
      @group_number  = 1 # by default
      @image_hardpoint_empty = Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
    end


    # @image_angle = options[:image_angle] || 0
    # Maybe these are reversed?
    start_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # Not sure why the offset is getting switched somewhere...
    # Maybe the calc Angle function is off somewhere
    # Without the offset being modified, the hardpoints are flipped across the center x axis
    end_point   = OpenStruct.new(:x => @x, :y => @y)
    # end_point = OpenStruct.new(:x => @center_x,        :y => @center_y)
    # start_point   = OpenStruct.new(:x => @x, :y => @y)
    @angle_from_center = self.class.angle_1to360(calc_angle(start_point, end_point) - 90)

    # if @item_klass
    #   puts "START: #{start_point}"
    #   puts " END : #{end_point}"
    #   puts "@angle_from_center: #{@angle_from_center}"
    #   # START: #<OpenStruct x=450, y=450>
    #   #  END : #<OpenStruct x=462.05357142857144, y=401.25>
    #   # @angle_from_center: 346.1119988390932
    #   # END HARDPOINT f16d336d-26ef-4a69-a132-ea131733c711
    #   # @ANGLE_FROM_CENTER: 346.1119988390932
    #   # stop

    # end
    @angle_from_center = @angle_from_center

    # ANGLE INIT HERE: 60.97169847574529
    # ANGLE IS OFF, NOT SURE WHY
    # @init_angle = @angle_from_center + current_ship_angle
     # "INIT ANGLE HERE" if options[:from_player]
    # puts "#{@init_angle} = #{@angle_from_center} + #{current_ship_angle}"
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
    #   # puts "OLD ANGLE: #{@angle_from_center} w/ current ship angle: #{current_ship_angle}"
    #   # # Radian, Angle, and distance all check out. Not sure why the angle increment swaps the x offset, or why the angle looks slightly off.
    #   # # This is a stop-gap measure
    #   # @angle_from_center = @angle_from_center + 5
    #   # self.increment_angle(current_ship_angle) # if current_ship_angle != 0.0
    #   # puts "NEW ANGLE: #{@angle_from_center}"
    #   # puts "NEW X AND Y: #{@x} - #{@y}"
    # end
    # puts "NEW Y: #{@y}"
    # raise "old_y is not equal to y: #{old_y} - #{@y}. Angle: #{current_ship_angle}" if old_y != @y
    @item = @item_klass.new({image_angle: @angle_from_center, hp_reference: self}) if @item_klass
    # puts "END HARDPOINT #{@id}"
    @owner = owner
    # puts "@ANGLE_FROM_CENTER: #{@angle_from_center}" if @item
    @current_map_pixel_x = nil
    @current_map_pixel_y = nil
  end


  # Hover colors. Default is usually a lighter shade than the hover shade.
  def self.get_hardpoint_colors(slot_type)
    color, hover_color = [nil,nil]
    if slot_type    == :generic
      color, hover_color = [Gosu::Color.argb(0xff_8aff82), Gosu::Color.argb(0xff_c3ffbf)]
    elsif slot_type == :offensive
      color, hover_color = [Gosu::Color.argb(0xff_ff3232), Gosu::Color.argb(0xff_ffb5b5)]
    elsif slot_type == :engine
      color, hover_color = [Gosu::Color.argb(0xff_2e63bf), Gosu::Color.argb(0xff_7fbbff)]
    elsif slot_type == :steam_core
      color, hover_color = [Gosu::Color.argb(0xff_d4ce55), Gosu::Color.argb(0xff_fff36b)]
    end
    return [color, hover_color]
  end

  # def increment_angle angle_increment
  #   # puts "HUH?  #{angle_increment}"
  #   if @angle_from_center + angle_increment >= 360.0
  #     @angle_from_center = (@angle_from_center + angle_increment) - 360.0
  #   else
  #     @angle_from_center += angle_increment
  #   end
  #   step = (Math::PI/180 * (@angle_from_center)) + 90.0 + 45.0# - 180
  #   # step = step.round(5)
  #   @x = Math.cos(step) * @radius + @center_x
  #   @y = Math.sin(step) * @radius + @center_y
  #   # @x = @x + @x_offset
  #   # @y = @y + @y_offset
  # end

  # def decrement_angle angle_increment
  #   if @angle_from_center - angle_increment <= 0.0
  #     @angle_from_center = (@angle_from_center - angle_increment) + 360.0
  #   else
  #     @angle_from_center -= angle_increment
  #   end
  #   step = (Math::PI/180 * (@angle_from_center)) + 90.0 + 45.0# - 180
  #   # step = step.round(5)
  #   @x = Math.cos(step) * @radius + @center_x
  #   @y = Math.sin(step) * @radius + @center_y
  # end


  def stop_attack
    # puts "HARDPOINT STOP ATTACK"
    @item.deactivate if @item
  end

  def convert_pointer_to_map_pixel pointer
    return [pointer.current_map_pixel_x, pointer.current_map_pixel_y]
  end

  # def get_max_launcher_angle
  #   if @item
  #   end
  # end

  # def get_steam_usage
  #   if @item_klass
  #     return @item_klass::STEAM_POWER_USAGE
  #   else
  #     return 0.0
  #   end
  # end

  # Pointer can be cursor.. or player..
  def attack current_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer, options = {}
    validate_not_nil([current_ship_angle, current_map_pixel_x, current_map_pixel_y], self.class.name, __callee__)
    # puts "HARDPOINT ATTACK: #{[current_ship_angle, current_map_pixel_x, current_map_pixel_y]}"
    # pointer convert to map_pixel_x and y!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # puts "pointer"
    # puts pointer
    destination_map_pixel_x, destination_map_pixel_y = convert_pointer_to_map_pixel(pointer)
    # puts "DESTINATION ATTACK: #{[current_ship_angle, current_map_pixel_x, current_map_pixel_y]}"

    # puts "destination_map_pixel_x, destination_map_pixel_y: #{destination_map_pixel_x}  -- #{destination_map_pixel_y}"
    # puts "current_map_pixel_x, current_map_pixel_y: #{current_map_pixel_x}  -- #{current_map_pixel_y}"

    # puts "HARDPOINT ATTACK"
    attack_projectile = nil
    can_attack = false
    if @item.nil?
      # options = {damage_increase: @damage_increase, relative_y_padding: @image_height_half}
      options = {}
      options[:image_angle] = @angle_from_center
      if @item_klass
        # @main_weapon = @assigned_weapon_class.new(self, options)
        # should be in init
        @item = @item_klass.new(options)
        can_attack = true
      end
    else
      # Let the item decide whether it's active or not.
      # @item.active = true if @item.active == false
      can_attack = true
    end

    if can_attack && @current_map_pixel_x && @current_map_pixel_y


      # TECHNICALLY, should factor in hardpoint location, not player location here
      start_point = OpenStruct.new(:x => current_map_pixel_x,     :y => current_map_pixel_y)
      end_point   = OpenStruct.new(:x => destination_map_pixel_x, :y => destination_map_pixel_y)
      # Reorienting angle to make 0 north
      destination_angle = self.class.angle_1to360(-(calc_angle(start_point, end_point) - 90))

      raise "DESTINATION ANGLE WAS NOT BETWEEN 0 and 360: #{destination_angle}. from start #{[current_map_pixel_x.round(1), current_map_pixel_y.round(1)]} to end: #{[destination_map_pixel_x.round(1), destination_map_pixel_y.round(1)]}" if destination_angle < 0.0 || destination_angle > 360.0


      # # Calculate New Projectile location, based of ships angle, and the hardpoints angle from center
      # angle_correction = 5
      # step = (Math::PI/180 * (360 -  @angle_from_center + current_ship_angle + 90 + angle_correction)) + 90.0 + 45.0# - 180
      # # step = step.round(5)
      # # puts "INGOING: #{current_map_pixel_x.round(2)} - #{current_map_pixel_y.round(2)}"
      # projectile_x = Math.cos(step) * @radius + current_map_pixel_x
      # # Adjustment - due to X offset issue
      # # projectile_x = current_map_pixel_x + (current_map_pixel_x - projectile_x)
      # projectile_y = Math.sin(step) * @radius + current_map_pixel_y

      # Hardpoints angle_from_center IS USED TO CALCULATE POS X,Y, not to find firing angle.
      attack_projectile = @item.attack(current_ship_angle - @angle_offset,  @current_map_pixel_x, @current_map_pixel_y, destination_angle, start_point, end_point, nil, nil, @owner, options)
      @drawable_items_near_self << @item
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


  def update_current_map_pixel_coords ship_angle, ship_map_pixel_x, ship_map_pixel_y
      angle_correction = 5
      step = (Math::PI/180 * (360 -  @angle_from_center + ship_angle + 90 + angle_correction)) + 90.0 + 45.0# - 180
      # step = step.round(5)
      # puts "INGOING: #{current_map_pixel_x.round(2)} - #{current_map_pixel_y.round(2)}"
      @current_map_pixel_x = Math.cos(step) * @radius + ship_map_pixel_x
      # Adjustment - due to X offset issue
      # projectile_x = current_map_pixel_x + (current_map_pixel_x - projectile_x)
      @current_map_pixel_y = Math.sin(step) * @radius + ship_map_pixel_y
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

  def draw center_x, center_y, ship_current_angle, viewable_pixel_offset_x, viewable_pixel_offset_y
    drawing_correction  = 6
    step = (Math::PI/180 * (360 - ship_current_angle + @angle_from_center + 90 + drawing_correction)) + 90.0 + 45.0# - 180
    # step = step.round(5)
    @x = Math.cos(step) * @radius + center_x
    @y = Math.sin(step) * @radius + center_y

    @item.draw(-ship_current_angle + @angle_offset, @x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, @z) if @item
    @image_hardpoint_empty.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, @z, -ship_current_angle + @angle_offset, 0.5, 0.5, @width_scale, @height_scale) if !@item
  end

  def draw_gl
    @drawable_items_near_self.reject! { |item| item.draw_gl }
  end


  def update mouse_x, mouse_y, player
    # puts "IS PLAYER HERE? #{[@owner.angle, @owner.current_map_pixel_x, @owner.current_map_pixel_y]}"
    update_current_map_pixel_coords(@owner.angle, @owner.current_map_pixel_x, @owner.current_map_pixel_y)
    # Center should stay the same
    # @center_y = player.y
    # @center_x = player.x


    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    @item.update(mouse_x, mouse_y, self) if @item
    # @cooldown_wait -= 1              if @cooldown_wait > 0
    # @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    # @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    # @time_alive += 1 if self.is_alive
  end

end