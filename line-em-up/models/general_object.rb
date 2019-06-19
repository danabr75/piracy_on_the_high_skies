require 'securerandom'
require_relative '../lib/global_variables.rb'

class GeneralObject
  attr_reader :id, :time_alive, :x, :y, :health, :image_width, :image_height, :image_size, :image_radius, :image_width_half, :image_height_half, :image_path, :inited
  attr_reader :current_map_pixel_x, :current_map_pixel_y
  attr_reader :current_map_tile_x,  :current_map_tile_y
  attr_reader :x_offset, :y_offset
  attr_reader :image

  # attr_accessor :x_offset_base, :y_offset_base
  LEFT  = 'left'
  RIGHT = 'right'
  SCROLLING_SPEED = 4
  MAX_SPEED      = 5
  HEALTH = 0
  
  def self.get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def get_image
    if @image
      return image
    else
      self.class.get_image
    end
  end

  def self.get_image_path
    "#{MEDIA_DIRECTORY}/question.png"
  end

  def get_image_path
    self.class.get_image_path
  end

  include GlobalVariables

  attr_reader  :width_scale, :height_scale, :screen_pixel_width, :screen_pixel_height, :map_pixel_width, :map_pixel_height
  attr_reader  :map_tile_width, :map_tile_height, :tile_pixel_width, :tile_pixel_height, :damage_increase, :average_scale
  attr_reader  :average_tile_size
  def init_global_vars
    @tile_pixel_width    = GlobalVariables.tile_pixel_width
    @tile_pixel_height   = GlobalVariables.tile_pixel_height
    @average_tile_size   = GlobalVariables.average_tile_size
    @map_pixel_width     = GlobalVariables.map_pixel_width
    @map_pixel_height    = GlobalVariables.map_pixel_height
    @map_tile_width      = GlobalVariables.map_tile_width
    @map_tile_height     = GlobalVariables.map_tile_height
    @width_scale         = GlobalVariables.width_scale
    @height_scale        = GlobalVariables.height_scale
    @screen_pixel_width  = GlobalVariables.screen_pixel_width
    @screen_pixel_height = GlobalVariables.screen_pixel_height
    @debug               = GlobalVariables.debug
    @damage_increase     = GlobalVariables.damage_increase
    @average_scale       = GlobalVariables.average_scale
  end

  # Maybe should deprecate X and Y, nothing should really be fixed to the screen anymore, Except the player. And the Grappling hook,
  # # Nevermind, they are useful for figuring out first-time placement
  # X and Y are place on screen. Maybe have the objects themselves figure out where the x and y is... based on other data.
  # Location Y and X are used when fixed to ground tiles
  # Location Y and X are where they are on GPS
  # screen_x and screen_y are used when object is fixed to the map, but are 2D, not 3D.
  # Scale has been deprecated in favor of height scale and width scale.
  def initialize(options = {})
    init_global_vars

    # validate_array([], self.class.name, __callee__)
    # validate_string([], self.class.name, __callee__)
    # validate_float([], self.class.name, __callee__)
    # validate_int([], self.class.name, __callee__)
    # validate_not_nil([], self.class.name, __callee__)
    # puts "@tile_pixel_width: #{@tile_pixel_width}"
    validate_float_or_int([@tile_pixel_width, @tile_pixel_height],  self.class.name, __callee__)

    validate_float_or_int([@width_scale, @height_scale],  self.class.name, __callee__)
    validate_int([@screen_pixel_width, @screen_pixel_height, @map_pixel_width, @map_pixel_height, @map_tile_width, @map_tile_height], self.class.name, __callee__)
    validate_not_nil([@width_scale, @height_scale, @screen_pixel_width, @screen_pixel_height, @tile_pixel_width, @tile_pixel_height, @map_pixel_width, @map_pixel_height, @map_tile_width, @map_tile_height], self.class.name, __callee__)

    @id    = options[:id] || SecureRandom.uuid
    # @class = self.class.name
    @image = options[:image] || get_image
    if self.class.name == "Player"
      raise "DIDN't GET IMAGE from player" if @image.nil?
    end

    @time_alive = 0
    # For objects that don't take damage, they'll never get hit by anything due to having 0 health
    if @image
      @image_width  = @image.width  * (@width_scale || @scale)
      @image_height = @image.height * (@height_scale || @scale)
      @image_size   = @image_width  * @image_height / 2
      @image_radius = (@image_width  + @image_height) / 4

      @image_width_half  = @image_width  / 2
      @image_height_half = @image_height / 2
    end

    @inited = true
    # Don't need these values assigned.
    @x = @x || -50
    @y = @y || -50
    # Not sure if keeping these
    # Used for hardpoints, objects relative to other objects
    @x_offset = @x_offset || 0
    @y_offset = @y_offset || 0
  end   

  # def get_x_with_offset
  #   @x + (@x_offset)
  # end

  # def get_y_with_offset
  #   @y + (@y_offset)
  # end

  # # For enemies and projectiles... maybe using this
  # def update_offsets x_offset, y_offset
  #   @x_offset = x_offset
  #   @y_offset = y_offset
  # end

  # If using a different class for ZOrder than it has for model name, or if using subclass (from subclass or parent)
  def get_draw_ordering
    raise "Need to override via subclass: #{self.class.name}"
    nil
  end

  def self.calc_angle(point1, point2)
    bearing = (180/Math::PI)*Math.atan2(point1.y-point2.y, point2.x-point1.x)
    return bearing
  end


  def draw
    # Will generate error if class name is not listed on ZOrder
    @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @width_scale, @height_scale)
    # @image.draw(@xΩ - @image.width / 2, @y - @image.height / 2, get_draw_ordering)
  end

  def draw_rot
    # draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
    @image.draw_rot(@x, @y, get_draw_ordering, @y, 0.5, 0.5, @width_scale, @height_scale)
  end

  def get_height
    @image_height
  end

  def get_width
    @image_width
  end

  def get_size
    @image_size
  end

  def get_radius
    @image_radius
  end

  def is_alive
    @health > 0
  end

  def take_damage damage
    @health -= damage
  end


  def self.get_initial_health
    self::HEALTH
  end


  def update mouse_x, mouse_y, player
    # Inherit, add logic, then call this to calculate whether it's still visible.
    # @time_alive ||= 0 # Temp solution
    @time_alive += 1
    get_map_tile_location_from_map_pixel_location
    # return is_on_screen?
    return is_alive
  end

  def self.get_max_speed
    self::MAX_SPEED
  end

  def is_on_screen?
    # @image.draw(@x - @image.width / 2, @y - @image.height / 2, ZOrder::Player)
    @y > (0 - get_height) && @y < (@screen_pixel_height + get_height) && @x > (0 - get_width) && @x < (@screen_pixel_width + get_width)
  end


  def point_is_between_the_ys_of_the_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
    (a_point_on_polygon.y <= point.y && point.y < trailing_point_on_polygon.y) || 
    (trailing_point_on_polygon.y <= point.y && point.y < a_point_on_polygon.y)
  end

  def ray_crosses_through_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
    (point.x < (trailing_point_on_polygon.x - a_point_on_polygon.x) * (point.y - a_point_on_polygon.y) / 
               (trailing_point_on_polygon.y - a_point_on_polygon.y) + a_point_on_polygon.x)
  end

  # def is_on_screen?
  #   # @image.draw(@x - get_width / 2, @y - get_height / 2, ZOrder::Player)
  #   @y > (0 - get_height) && @y < (HEIGHT + get_height) && @x > (0 - get_width) && @x < (WIDTH + get_width)
  # end

  def calc_angle(point1, point2)
    bearing = (180/Math::PI)*Math.atan2(point1.y-point2.y, point2.x-point1.x)
    return bearing
  end

  # https://www.mathsisfun.com/geometry/radians.html
  def calc_radian(point1, point2)
    return self.class.calc_radian(point1, point2)
    # rdn = Math.atan2(point1.y-point2.y, point2.x-point1.x)
    # return rdn
  end

  def self.calc_radian(point1, point2)
    # Should be 1° × π/180 = 0.01745rad
    rdn = Math.atan2(point1.y-point2.y, point2.x-point1.x)
    return rdn
  end

  def add_angles angle1, angle2
    angle_sum = angle1 + angle2
    if angle_sum > 360
      angle_sum = angle_sum - 360
    end
  end
  def subtract_angles angle1, angle2
    angle_sum = angle1 - angle2
    if angle_sum < 0
      angle_sum = angle_sum + 360
    end
  end

  def self.angle_1to360 angle
    value = angle
    if angle == -0.0
      value = 0.0
    elsif angle > 360.0
      value = angle % 360.0
    elsif angle < 0.0
      value = angle % 360.0
    end
    return value
  end
  # CONFIRMED WORKING IN ALL CASES
  def self.is_angle_between_two_angles?(angle, min_angle, max_angle)
    raise "BAD MIN OR MAX ANGLE: #{min_angle} or #{max_angle}" if min_angle.nil? || max_angle.nil?
    angle     = angle_1to360(angle); 
    angle_min = angle_1to360(min_angle);
    angle_max = angle_1to360(max_angle);

    if (angle_min < angle_max)
      return angle_min <= angle && angle <= angle_max
    else
      return angle_min <= angle || angle <= angle_max
    end
  end
  raise "Validation failed" unless GeneralObject.is_angle_between_two_angles?(0.0, 20, 340)        == false
  raise "Validation failed" unless GeneralObject.is_angle_between_two_angles?(135.0, 90.0, 180.0)  == true
  raise "Validation failed" unless GeneralObject.is_angle_between_two_angles?(275.0, 180.0, 270.0) == false
  raise "Validation failed" unless GeneralObject.is_angle_between_two_angles?(0.0, 340, 20)        == true


  def is_angle_between_two_angles?(angle, min_angle, max_angle)
    GeneralObject.is_angle_between_two_angles?(angle, min_angle, max_angle)
  end

  # Which angle is nearest
  # FULLY WORKING
  def self.nearest_angle angle, min_angle, max_angle, options = {}
    min_value = min_angle - angle
    min_value = (min_value + 180) % 360 - 180

    max_value = max_angle - angle
    max_value = (max_value + 180) % 360 - 180
    # puts "MIN VALUE, MAX VALUE: #{[min_value, max_value]}"
    if min_value.abs < max_value.abs
      if options[:with_diff]
        return [min_angle, min_value]
      else
        return min_angle
      end
    else
      if options[:with_diff]
        return [max_angle, max_value]
      else
        return max_angle
      end
    end
  end
  raise "Validation failed" unless GeneralObject.nearest_angle(0.0, 30.0, 340.0)    == 340.0
  raise "Validation failed" unless GeneralObject.nearest_angle(5.0, 20.0, 359.0)    == 359.0
  raise "Validation failed" unless GeneralObject.nearest_angle(359.0, 5.0, 275.0)   == 5.0
  raise "Validation failed" unless GeneralObject.nearest_angle(136.0, 90.0, 180.0)  == 180.0
  raise "Validation failed" unless GeneralObject.nearest_angle(275.0, 180.0, 270.0) == 270.0
  raise "Validation failed" unless GeneralObject.nearest_angle(278, 320, 20) == 320.0
  raise "Validation failed" unless GeneralObject.nearest_angle(278, 20, 320) == 320.0



  def nearest_angle angle, min_angle, max_angle
    return GeneralObject.nearest_angle(angle, min_angle, max_angle)
  end

  def self.nearest_angle_with_diff angle, min_angle, max_angle
    return GeneralObject.nearest_angle(angle, min_angle, max_angle, {with_diff: true})
  end
  raise "Validation failed" unless GeneralObject.nearest_angle_with_diff(278, 20, 320) == [320.0, 42]
  raise "Validation failed" unless GeneralObject.nearest_angle_with_diff(278, 320, 20) == [320.0, 42]
  raise "Validation failed" unless GeneralObject.nearest_angle_with_diff(0.5, 240.0, 300.0) == [300.0, -60.5]

  def nearest_angle_with_diff angle, min_angle, max_angle
    return GeneralObject.nearest_angle(angle, min_angle, max_angle, {with_diff: true})
  end

# # new_pos_x = @x / @screen_pixel_width.to_f * (AXIS_X_MAX - AXIS_X_MIN) + AXIS_X_MIN;
# # new_pos_y = (1 - @y / @screen_pixel_height.to_f) * (AXIS_Y_MAX - AXIS_Y_MIN) + AXIS_Y_MIN;
#   # This isn't exactly right, objects are drawn farther away from center than they should be.
#   def convert_x_and_y_to_opengl_coords
#     # Don't have to recalce these 4 variables on each draw, save to singleton somewhere?
#     middle_x = (@screen_pixel_width.to_f) / 2.0
#     middle_y = (@screen_pixel_height.to_f) / 2.0
#     increment_x = 1.0 / middle_x
#     increment_y = 1.0 / middle_y
#     new_pos_x = (@x.to_f - middle_x) * increment_x
#     new_pos_y = (@y.to_f - middle_y) * increment_y
#     # Inverted Y
#     new_pos_y = new_pos_y * -1.0

#     # height = @image_height.to_f * increment_x
#     return [new_pos_x, new_pos_y, increment_x, increment_y]
#   end


  # This isn't exactly right, objects are drawn farther away from center than they should be.
  # Are these still being used? X and Y should only be used to draw on the screen
  # They are still being used... maybe it's ok
  def convert_x_and_y_to_opengl_coords
    middle_x = @screen_pixel_width / 2
    middle_y = @screen_pixel_height / 2

    ratio = @screen_pixel_width.to_f / (@screen_pixel_height.to_f)

    increment_x = (ratio / middle_x) * 0.97
    # The zoom issue maybe, not quite sure why we need the Y offset.
    increment_y = (1.0 / middle_y) * 0.75
    new_pos_x = (@x - middle_x) * increment_x
    new_pos_y = (@y - middle_y) * increment_y
    # Inverted Y
    new_pos_y = new_pos_y * -1

    # height = @image_height.to_f * increment_x
    return [new_pos_x, new_pos_y, increment_x, increment_y]
  end

  # Are these still being used? X and Y should only be used to draw on the screen
  # They are still being used... maybe it's ok
  def self.convert_x_and_y_to_opengl_coords(x, y, screen_pixel_width, screen_pixel_height)
    middle_x = screen_pixel_width.to_f / 2.0
    middle_y = screen_pixel_height.to_f / 2.0

    ratio = screen_pixel_width.to_f / screen_pixel_height.to_f

    increment_x = (ratio / middle_x) * 0.97
    # The zoom issue maybe, not quite sure why we need the Y offset.
    increment_y = (1.0 / middle_y)
    new_pos_x = (x.to_f - middle_x) * increment_x
    new_pos_y = (y.to_f - middle_y) * increment_y
    # Inverted Y
    new_pos_y = new_pos_y * -1
    return [new_pos_x, new_pos_y, increment_x, increment_y]
  end


  def y_is_on_screen
    @y >= 0 && @y <= @screen_pixel_height
  end

  def collision_triggers
    # Explosion or something
    # Override
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end


  def is_on_map?
    # puts "@current_map_pixel: #{@current_map_pixel_x} - #{@current_map_pixel_y}"
    # @image.draw(@x - @image.width / 2, @y - @image.height / 2, ZOrder::Player)
    # puts "@current_map_pixel_x < @map_pixel_width && @current_map_pixel_x > 0"
    # puts "#{@current_map_pixel_x} < #{@map_pixel_width} && #{@current_map_pixel_x} > 0"
    # puts "#{@current_map_pixel_x < @map_pixel_width} && #{@current_map_pixel_x > 0}"
    # 17402.549329529695 < 28125 && 17402.549329529695 > 0
    # true && true
    result = @current_map_pixel_x < @map_pixel_width && @current_map_pixel_x > 0 && @current_map_pixel_y < @map_pixel_height && @current_map_pixel_y > 0
    # puts "#{@current_map_pixel_x < @map_pixel_width} && #{@current_map_pixel_x > 0} && #{@current_map_pixel_y < @map_pixel_height} && #{@current_map_pixel_y > 0}"
    # puts "RESULT: #{result}"
    # raise "STOP" if result == false
    return result
  end

  # Launched, pointed north, at the top right corner of the map
  # Current map_pixel_x: 197.02986467841077 = @X: 450.0
  # ...
  # Current map_pixel_x: 101.52206203019966 = @X: 354.4921973517889
  # ...
  # Current map_pixel_x: -32.18886167729589 = @X: 220.78127364429332

  # Launched, pointed north, at the center of the map
  # Current map_pixel_x: 14062.5 = @X: 450.0
  # ...
  # Current map_pixel_x: 1359.9622477878852 = @X: -12252.537752212114
  # ...
  # Current map_pixel_x: -72.6547919352809 = @X: -13685.154791935282

  # Don't need allow_over_edge_of_map param, all objects are allowed past. Player has it's own logic to stop itself
  # ANGLE HERE = 0 is NORTH, 180 is SOUTH
  def movement speed, angle, allow_over_edge_of_map = false
    # puts "MOVEMENT"
    # raise "ISSUE6" if @current_map_pixel_x.class != Integer || @current_map_pixel_y.class != Integer 
    raise " NO SCALE PRESENT FOR MOVEMENT" if @width_scale.nil? || @height_scale.nil?
    raise " NO LOCATION PRESENT" if @current_map_pixel_x.nil? || @current_map_pixel_y.nil?
    # puts "MOVEMENT: #{speed}, #{angle}"
    # puts "PLAYER MOVEMENT map size: #{@map_pixel_width} - #{@map_pixel_height}"
    # base = speed# / 100.0
    base = speed * ((@width_scale + @height_scale) / 2.0)
    # @width_scale  = width_scale
    # @height_scale = height_scale
    # raise "BASE: #{base}"
    
    map_edge = 50

    step = (Math::PI/180 * (angle + 90))# - 180
    # puts "BASE HERE: #{base}"
    # puts "STEP HERE: #{step}"
    # puts "_____ #{@location_x}   -    #{@current_map_pixel_y}"
    new_x = Math.cos(step) * base + @current_map_pixel_x
    new_y = Math.sin(step) * base + @current_map_pixel_y
    # puts "new_y = Math.sin(step) * base + @current_map_pixel_y"
    # puts "#{new_y} = Math.sin(#{step}) * #{base} + #{@current_map_pixel_y}"

    # PRE MOVMENET: 7.885561234832409 - 71.5517865980955
    # new_y = Math.sin(step) * base + @current_map_pixel_y
    # 78.96594488335472 = Math.sin(0.22689280275926285) * 32.958984375 + 71.5517865980955
    # POST MOVMENET: -24.2286865058919 - 78.96594488335472


    # puts "PRE MOVE: #{new_x} x #{new_y}"
    # new_x = new_x * @width_scale
    # new_y = new_y * @height_scale
    # puts "POST MOVE: #{new_x} x #{new_y}"
    # Because X is swapped
    # Not sure why we're reversing direction of x here.. maybe a miscalculation on the Math
    x_diff = (@current_map_pixel_x - new_x)# * -1
    y_diff = @current_map_pixel_y - new_y

    # puts "(#{@current_map_pixel_y} - #{y_diff}) > #{@map_pixel_height}"
    # puts "@map_pixel_height: #{@map_pixel_height}"
    # if @tile_width && @tile_height

    # puts "(@current_map_pixel_y - y_diff)"
    # puts "(@#{current_map_pixel_y} - #{y_diff})"
    hit_map_boundary = false
    if !allow_over_edge_of_map
      if (@current_map_pixel_y - y_diff) > @map_pixel_height
        # Block progress along top of map Y 
        # puts "Block progress along bottom of map Y "
        # puts "y_diff = y_diff - ((@current_map_pixel_y + y_diff) - @current_map_pixel_y)"
        # puts "#{y_diff} = #{y_diff} - ((#{@current_map_pixel_y + y_diff}) - #{@current_map_pixel_y})"
        # -27.649999999997817 = -27.649999999997817 - ((28096.762499999866) - 28124.412499999864)
        y_diff = y_diff - ((@current_map_pixel_y + y_diff) - @current_map_pixel_y)
        # @current_momentum = 0
        hit_map_boundary = true
      elsif @current_map_pixel_y - y_diff < 0
        # Block progress along bottom of map Y 
        # puts "Block progress along top of map Y "
        y_diff = y_diff + (@current_map_pixel_y + y_diff)
        # @current_momentum = 0
        hit_map_boundary = true
      end

      if @current_map_pixel_x - x_diff > @map_pixel_width
        # puts "HITTING WALL LIMIT: #{@location_x} - #{x_diff} > #{@map_pixel_width}"
        x_diff = x_diff - ((@current_map_pixel_x + x_diff) - @current_map_pixel_x)
        # @current_momentum = 0
        hit_map_boundary = true
      elsif @current_map_pixel_x - x_diff < 0
        x_diff = x_diff + (@current_map_pixel_x + x_diff)
        # @current_momentum = 0
        hit_map_boundary = true
      end
    end

    # else

    #   # IF no global map data.. any other restrictions?

    # end

    # puts "MOVEMNET: #{x_diff.round(3)} - #{y_diff.round(3)}"
    @current_map_pixel_y += y_diff
    @current_map_pixel_x += x_diff
    # PLAYER MOVEMENT: 14118.0 - 28124.412499999864
    # puts "PLAYER MOVEMENT: #{@current_map_pixel_x} - #{@current_map_pixel_y}"

    # Block elements from going off map. Not really working here... y still builds up.
    # if @location_y > @map_pixel_height
    #   @location_y = @map_pixel_height
    # elsif @location_y < 0
    #   @location_y = 0
    # end
    # if @location_x > @map_pixel_width
    #   @location_x = @map_pixel_width
    # elsif @location_x < 0
    #   @location_x = 0
    # end

    return [x_diff, y_diff, hit_map_boundary]
  end

  # Need to adjust this method. Should go from X,Y to map_pixel_x and map_pixel_y
  # X and Y are no longer used to calculate collisions
  # Keeping this around, but not going to use for the future.
  def update_from_3D(vert0, vert1, vert2, vert3, oz, viewMatrix, projectionMatrix, viewport)
    # left-top, left-bottom, right-top, right-bottom
    ox = vert0[0] - (vert0[0] - vert2[0])
    oy = vert2[1] + (vert2[1] - vert3[1])
    # puts "update_from_3D: #{[ox, oy, oz]}"
    # oz = z
    oz2 = (vert0[2] + vert1[2] + vert2[2] + vert3[2]) / 4
    x, y, z = convert3DTo2D(vert0[0] - (vert0[0] - vert2[0]) / 2, vert2[1] - (vert2[1] - vert3[1]) / 2, oz2, viewMatrix, projectionMatrix, viewport)
    y = @screen_pixel_height - y
    @x = x
    @y = y
  end

  def convert3DTo2D(o_x, o_y, o_z, viewMatrix, projectionMatrix, viewport)
    return self.class.convert3DTo2D(o_x, o_y, o_z, viewMatrix, projectionMatrix, viewport)
  end

  def self.convert3DTo2D(o_x, o_y, o_z, viewMatrix, projectionMatrix, viewport)
    return gluProject(o_x, o_y, o_z, viewMatrix, projectionMatrix, viewport)
  end

  def validate_array parameters, klass_name, method_name
    validate(parameters, method_name, klass_name, Array)
  end

  def validate_string parameters, klass_name, method_name
    validate(parameters, method_name, klass_name, String)
  end

  def validate_float parameters, klass_name, method_name
    validate(parameters, method_name, klass_name, Float)
  end

  def validate_float_or_int parameters, klass_name, method_name
    validate(parameters, method_name, klass_name, [Float, Integer])
  end

  def validate_int parameters, klass_name, method_name
    validate(parameters, method_name, klass_name, Integer)
  end

  def validate_not_nil parameters, klass_name, method_name
    parameters.each_with_index do |param, index|
      puts caller if param.nil?
      raise "Invalid Parameter. For the #{index}th parameter in class and method #{klass_name}##{method_name}. Expected not Nil. Got Nil" if param.nil?
    end
  end

  def validate parameters, method_name, klass_name, class_type
    class_type = [class_type] unless class_type.class == Array
    parameters.each_with_index do |param, index|
      next if param.nil?
      puts caller if  !class_type.include?(param.class)
      raise "Invalid Parameter. For the #{index}th parameter in class and method #{klass_name}##{method_name}. Expected type: #{class_type}. Got #{param.class} w/ value: #{param}" if !class_type.include?(param.class)
    end
  end

  def get_map_tile_location_from_map_pixel_location
    # puts "@current_map_tile: #{@current_map_tile_x} X #{@current_map_tile_y}"
    # If statement is due to the fact that some objects are created without these variables being initted.
    # Indexed at 0. on a 250 x 250 tile map, values are 0..249
    # It is possible to exceed the mapped areas, like projectiles flying off the edge of the map.
    @current_map_tile_x = (@current_map_pixel_x / (@tile_pixel_width)).to_i  if @current_map_pixel_x && @tile_pixel_width
    @current_map_tile_y = (@current_map_pixel_y / (@tile_pixel_height)).to_i if @current_map_pixel_y && @tile_pixel_height
  end

  # Used a lot by buildings
  def get_map_pixel_location_from_map_tile_location depth_factor_x = nil, depth_factor_y = nil
    # puts "get_map_pixel_location_from_map_tile_location"
    # puts "@current_map_tile: #{@current_map_tile_x} X #{@current_map_tile_y}"
    # If statement is due to the fact that some objects are created without these variables being initted.
    # Indexed at 0. on a 250 x 250 tile map, values are 0..249
    # It is possible to exceed the mapped areas, like projectiles flying off the edge of the map.
    @current_map_pixel_x = ((@current_map_tile_x) * @tile_pixel_width)  + (@tile_pixel_width  / 2.0) if @current_map_tile_x && @tile_pixel_width
    @current_map_pixel_y = ((@current_map_tile_y) * @tile_pixel_height) + (@tile_pixel_height / 2.0) if @current_map_tile_y && @tile_pixel_height
    # puts "TILE = #{[@current_map_tile_x, @current_map_tile_y]}"
    # puts "GOT PIXEL: #{[@current_map_pixel_x, @current_map_pixel_y]}"
    # TILE = [124, 128]
    # GOT PIXEL: [14006.25, 14456.25]
  end

  def self.convert_map_pixel_location_to_screen player, current_map_pixel_x, current_map_pixel_y, screen_pixel_width, screen_pixel_height
    # puts "HERE: (#{player.current_map_pixel_x} - #{current_map_pixel_x}) + (#{screen_pixel_width} / 2)"
    x = (player.current_map_pixel_x - current_map_pixel_x) + (screen_pixel_width / 2)
    # puts "Current map_pixel_x: #{@current_map_pixel_x} = @X: #{@x}"

    # puts "@x = @current_map_pixel_x - player.current_map_pixel_x"
    # puts "#{@x} = #{@current_map_pixel_x} - #{player.current_map_pixel_x}"
    y = (current_map_pixel_y - player.current_map_pixel_y) + (screen_pixel_height / 2)
    return [x, y]
  end

  def convert_map_pixel_location_to_screen player
    @x = (player.current_map_pixel_x - @current_map_pixel_x) + (@screen_pixel_width / 2)
    # puts "X #{@x} GENERATED FOR OBJECT ID: #{@id}"
    # puts "Current map_pixel_x: #{@current_map_pixel_x} = @X: #{@x}"

    # puts "@x = @current_map_pixel_x - player.current_map_pixel_x"
    # puts "#{@x} = #{@current_map_pixel_x} - #{player.current_map_pixel_x}"
    @y = (@current_map_pixel_y - player.current_map_pixel_y) + (@screen_pixel_height / 2)
    # puts "Y #{@y} GENERATED FOR OBJECT ID: #{@id}"
  end

  # object can be player.. or an enemy. This is used to calculate projectiles emerging from hardpoints.
  def convert_screen_to_map_pixel_location object_map_pixel_x, object_map_pixel_y
    current_map_pixel_x = -(( @x    ) - (@screen_pixel_width  / 2) - object_map_pixel_x)
    # Y is reversed
    current_map_pixel_y = -((@screen_pixel_height  -    @y    ) - (@screen_pixel_height / 2) - object_map_pixel_y)
    return [current_map_pixel_x, current_map_pixel_y]
  end

  def convert_map_tile_location_to_opengl x, y, w = nil, h = nil, include_adjustments_for_not_exact_opengl_dimensions = false
    # puts "IT's SET RIUGHT HERE2!!: #{@screen_pixel_height} - #{y}"
    opengl_x   = ((x / (@screen_pixel_width.to_f )) * 2.0) - 1
    # opengl_x   = opengl_x * 1.2 if include_adjustments_for_not_exact_opengl_dimensions
    opengl_y   = ((y / (@screen_pixel_height.to_f)) * 2.0) - 1
    # opengl_y   = opengl_y * 0.92 if include_adjustments_for_not_exact_opengl_dimensions
    if w && h
      open_gl_w  = ((w / (@screen_pixel_width.to_f )) * 2.0)
      # open_gl_w = open_gl_w - opengl_x
      open_gl_h  = ((h / (@screen_pixel_height.to_f )) * 2.0)
      # open_gl_h = open_gl_h - opengl_y
      # puts "RETURNING: #{{o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}}"
      return {o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}
    else
      # puts "RETURNING: #{{o_x: opengl_x, o_y: opengl_y}}"
      return {o_x: opengl_x, o_y: opengl_y}
    end
  end
  
  def get_map_pixel_location_from_opengl(o_x, oy, oz, viewMatrix, projectionMatrix, viewport, player)
    x, y, z = convert3DTo2D(o_x, oy, oz, viewMatrix, projectionMatrix, viewport)
    # y = @screen_pixel_height - y
    # @x = x
    # @y = y
    @current_map_pixel_x = -(x  - (@screen_pixel_width / 2)  - player.current_map_pixel_x)
    @current_map_pixel_y = -(y  - (@screen_pixel_height / 2) - player.current_map_pixel_y)
    # puts "Current map_pixel_x: #{@current_map_pixel_x} = @X: #{@x}"

    # puts "@x = @current_map_pixel_x - player.current_map_pixel_x"
    # puts "#{@x} = #{@current_map_pixel_x} - #{player.current_map_pixel_x}"
    # @y = (@current_map_pixel_y - player.current_map_pixel_y) + (@screen_pixel_height/ 2)


    return [x, y, z]
  end


  def run_pixel_to_tile_validations
    raise "STOP USING ME"
  end

  def stop
    if @debug
      raise "STOP HERE"
    end
  end

end