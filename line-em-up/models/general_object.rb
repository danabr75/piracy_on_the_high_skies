require 'securerandom'
require_relative '../lib/global_variables.rb'

class GeneralObject
  attr_reader :id, :time_alive, :x, :y, :health, :image_width, :image_height, :image_size, :image_radius, :image_width_half, :image_height_half, :image_path, :inited
  attr_reader :current_map_pixel_x, :current_map_pixel_y
  attr_reader :current_map_tile_x,  :current_map_tile_y
  attr_reader :x_offset, :y_offset
  # attr_accessor :x_offset_base, :y_offset_base
  LEFT  = 'left'
  RIGHT = 'right'
  SCROLLING_SPEED = 4
  MAX_SPEED      = 5
  
  def self.get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def get_image
    self.class.get_image
  end

  def self.get_image_path
    "#{MEDIA_DIRECTORY}/question.png"
  end

  def get_image_path
    self.class.get_image_path
  end

  include GlobalVariables

  attr_reader  :width_scale, :height_scale, :screen_pixel_width, :screen_pixel_height, :map_pixel_width, :map_pixel_height
  attr_reader  :map_tile_width, :map_tile_height, :tile_pixel_width, :tile_pixel_height
  def init_global_vars
    @tile_pixel_width    = GlobalVariables.tile_pixel_width
    @tile_pixel_height   = GlobalVariables.tile_pixel_height
    @map_pixel_width     = GlobalVariables.map_pixel_width
    @map_pixel_height    = GlobalVariables.map_pixel_height
    @map_tile_width      = GlobalVariables.map_tile_width
    @map_tile_height     = GlobalVariables.map_tile_height
    @width_scale         = GlobalVariables.width_scale
    @height_scale        = GlobalVariables.height_scale
    @screen_pixel_width  = GlobalVariables.screen_pixel_width
    @screen_pixel_height = GlobalVariables.screen_pixel_height
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
    puts "@tile_pixel_width: #{@tile_pixel_width}"
    validate_float_or_int([@tile_pixel_width, @tile_pixel_height],  self.class.name, __callee__)

    validate_float([@width_scale, @height_scale],  self.class.name, __callee__)
    validate_int([@screen_pixel_width, @screen_pixel_height, @map_pixel_width, @map_pixel_height, @map_tile_width, @map_tile_height], self.class.name, __callee__)
    validate_not_nil([@width_scale, @height_scale, @screen_pixel_width, @screen_pixel_height, @tile_pixel_width, @tile_pixel_height, @map_pixel_width, @map_pixel_height, @map_tile_width, @map_tile_height], self.class.name, __callee__)

    @id    = SecureRandom.uuid
    @image = options[:image] || get_image

    @time_alive = 0
    # For objects that don't take damage, they'll never get hit by anything due to having 0 health
    @image_width  = @image.width  * (@width_scale || @scale)
    @image_height = @image.height * (@height_scale || @scale)
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4

    @image_width_half  = @image_width  / 2
    @image_height_half = @image_height / 2

    @inited = true
    # Don't need these values assigned.
    @x = -50
    @y = -50
    # Not sure if keeping these
    @x_offset = 0
    @y_offset = 0
  end   

  def get_x_with_offset
    @x + (@x_offset)
  end

  def get_y_with_offset
    @y + (@y_offset)
  end

  # For enemies and projectiles... maybe using this
  def update_offsets x_offset, y_offset
    @x_offset = x_offset
    @y_offset = y_offset
  end

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

  HEALTH = 0

  def self.get_initial_health
    self::HEALTH
  end


  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    # Inherit, add logic, then call this to calculate whether it's still visible.
    # @time_alive ||= 0 # Temp solution
    @time_alive += 1
    return is_on_screen?
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

  def calc_radian(point1, point2)
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

  def self.is_angle_between_two_angles?(angle, min_angle, max_angle)
    return angle if min_angle.nil? || max_angle.nil?
    value = false
    if angle == min_angle
      value = true
    elsif angle == max_angle
      value = true
    elsif max_angle < min_angle
      # if max angle is less than min, then it crossed the angle 0/360 barrier
      if angle == 0
        value =  true
      elsif angle > 0 && angle < max_angle
        value =  true
      elsif angle > min_angle
        value =  true
      else
        # return false
      end
    else
      # max angle is greater than min, easy case.
      value = angle < max_angle && angle > min_angle
    end
    return value
  end

  def is_angle_between_two_angles?(angle, min_angle, max_angle)
    GeneralObject.is_angle_between_two_angles?(angle, min_angle, max_angle)
  end

  # Which angle is nearest
  def self.nearest_angle angle, min_angle, max_angle
    puts "NEAREST ANGLE #{angle} - #{min_angle} - #{max_angle}"
    value = nil
    min_angle_diff = angle - min_angle
    max_angle_diff = angle - max_angle
    first_diff = nil
    puts "WAS NOT: #{min_angle_diff.abs} > #{max_angle_diff.abs}"
    if min_angle_diff.abs > max_angle_diff.abs
      puts "CASE 1"
      first_diff = max_angle_diff.abs
      value = max_angle
    else
      puts "CASE 2"
      first_diff = min_angle_diff.abs
      value = min_angle
    end
    # puts "VALUE: #{value}"

    alt_value = nil
    alt_angle = (angle - 360).abs
    min_angle_diff = alt_angle - min_angle
    max_angle_diff = alt_angle - max_angle
    second_diff = nil
    puts "WAS #{min_angle_diff.abs} > #{max_angle_diff.abs}"
    if min_angle_diff.abs > max_angle_diff.abs
      puts "CASE 3"
      second_diff = max_angle_diff.abs
      alt_value = max_angle
    else
      puts "CASE 4"
      second_diff = min_angle_diff.abs
      alt_value = min_angle
    end
    # puts "VALUE: #{value}"
    puts "FIRST DIFF #{first_diff} and SECOND: #{second_diff}" 
    if first_diff > second_diff
      puts "CASE 5"
      value = alt_value
    end
    puts "VALUE: #{value}"
    return value
  end

  def nearest_angle angle, min_angle, max_angle
    GeneralObject.nearest_angle(angle, min_angle, max_angle)
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

  def movement speed, angle
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
    # puts "PRE MOVE: #{new_x} x #{new_y}"
    # new_x = new_x * @width_scale
    # new_y = new_y * @height_scale
    # puts "POST MOVE: #{new_x} x #{new_y}"
    x_diff = (@current_map_pixel_x - new_x) * -1
    y_diff = @current_map_pixel_y - new_y

    # puts "(#{@current_map_pixel_y} - #{y_diff}) > #{@map_pixel_height}"
    # puts "@map_pixel_height: #{@map_pixel_height}"
    # if @tile_width && @tile_height

    # puts "(@current_map_pixel_y - y_diff)"
    # puts "(@#{current_map_pixel_y} - #{y_diff})"
      if (@current_map_pixel_y - y_diff) > @map_pixel_height
        # Block progress along top of map Y 
        # puts "Block progress along bottom of map Y "
        # puts "y_diff = y_diff - ((@current_map_pixel_y + y_diff) - @current_map_pixel_y)"
        # puts "#{y_diff} = #{y_diff} - ((#{@current_map_pixel_y + y_diff}) - #{@current_map_pixel_y})"
        # -27.649999999997817 = -27.649999999997817 - ((28096.762499999866) - 28124.412499999864)
        y_diff = y_diff - ((@current_map_pixel_y + y_diff) - @current_map_pixel_y)
        @current_momentum = 0
      elsif @current_map_pixel_y - y_diff < 0
        # Block progress along bottom of map Y 
        # puts "Block progress along top of map Y "
        y_diff = y_diff + (@current_map_pixel_y + y_diff)
        @current_momentum = 0
      end

      if @current_map_pixel_x - x_diff > @map_pixel_width
        # puts "HITTING WALL LIMIT: #{@location_x} - #{x_diff} > #{@map_pixel_width}"
        x_diff = x_diff - ((@current_map_pixel_x + x_diff) - @current_map_pixel_x)
        @current_momentum = 0
      elsif @current_map_pixel_x - x_diff < 0
        x_diff = x_diff + (@current_map_pixel_x + x_diff)
        @current_momentum = 0
      end

    # else

    #   # IF no global map data.. any other restrictions?

    # end

    # puts "MOVEMNET: #{x_diff.round(3)} - #{y_diff.round(3)}"

    @current_map_pixel_y -= y_diff
    @current_map_pixel_x -= x_diff
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

    return [x_diff, y_diff]
  end

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
      raise "Invalid Parameter. For the #{index}th parameter in class and method #{klass_name}##{method_name}. Expected not Nil. Got Nil" if param.nil?
    end
  end

  def validate parameters, method_name, klass_name, class_type
    class_type = [class_type] unless class_type.class == Array
    parameters.each_with_index do |param, index|
      next if param.nil?
      raise "Invalid Parameter. For the #{index}th parameter in class and method #{klass_name}##{method_name}. Expected type: #{class_type}. Got #{param.class}" if !class_type.include?(param.class)
    end
  end
end