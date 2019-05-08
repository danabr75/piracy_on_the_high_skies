class GeneralObject
  attr_accessor :time_alive, :x, :y, :health, :image_width, :image_height, :image_size, :image_radius, :image_width_half, :image_height_half, :image_path, :inited
  LEFT  = 'left'
  RIGHT = 'right'
  SCROLLING_SPEED = 4
  MAX_SPEED      = 5

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def get_image_path
    "#{MEDIA_DIRECTORY}/question.png"
  end

  def initialize(scale, x, y, screen_width, screen_height, options = {})
    @scale = scale
    @image = options[:image] || get_image


    if options[:relative_object]
      if LEFT == options[:side]
        @x = options[:relative_object].x - (options[:relative_object].get_width / 2)
        @y = options[:relative_object].y
      elsif RIGHT == options[:side]
        @x = (options[:relative_object].x + options[:relative_object].get_width / 2)
        @y = options[:relative_object].y
      else
        @x = options[:relative_object].x
        @y = options[:relative_object].y
      end
    else
      @x = x
      @y = y
    end
    @x = @x + options[:relative_x_padding] if options[:relative_x_padding]
    @y = @y + options[:relative_y_padding] if options[:relative_y_padding]
    # if options[:relative_y_padding]
      # puts "options[:relative_y_padding]: #{options[:relative_y_padding]}"
    # end

    @time_alive = 0
    # For objects that don't take damage, they'll never get hit by anything due to having 0 health
    @health = 0
    @image_width  = @image.width  * @scale
    @image_height = @image.height * @scale
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4

    @image_width_half  = @image_width  / 2
    @image_height_half = @image_height / 2



    @screen_width  = screen_width
    @screen_height = screen_height
    @off_screen = screen_height + screen_height
    @inited = true
  end

  # If using a different class for ZOrder than it has for model name, or if using subclass (from subclass or parent)
  def get_draw_ordering
    raise "Need to override via subclass: #{self.class.name}"
    nil
  end


  def draw
    # Will generate error if class name is not listed on ZOrder
    @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)
    # @image.draw(@xΩ - @image.width / 2, @y - @image.height / 2, get_draw_ordering)
  end

  def draw_rot
    # draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
    @image.draw_rot(@x, @y, get_draw_ordering, @y, 0.5, 0.5, @scale, @scale)
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

  def update mouse_x = nil, mouse_y = nil, player = nil
    # Inherit, add logic, then call this to calculate whether it's still visible.
    # @time_alive ||= 0 # Temp solution
    @time_alive += 1
    return is_on_screen?
  end

  protected
  
  def self.get_max_speed
    self::MAX_SPEED
  end

  def is_on_screen?
    # @image.draw(@x - @image.width / 2, @y - @image.height / 2, ZOrder::Player)
    @y > (0 - get_height) && @y < (@screen_height + get_height) && @x > (0 - get_width) && @x < (@screen_width + get_width)
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
    value = nil
    min_angle_diff = angle - min_angle
    max_angle_diff = angle - max_angle
    first_diff = nil
    if min_angle_diff.abs > max_angle_diff.abs
      # puts "CASE 1"
      first_diff = max_angle_diff.abs
      value = max_angle
    else
      # puts "CASE 2"
      first_diff = min_angle_diff.abs
      value = min_angle
    end
    # puts "VALUE: #{value}"

    alt_value = nil
    alt_angle = (angle - 360).abs
    min_angle_diff = alt_angle - min_angle
    max_angle_diff = alt_angle - max_angle
    second_diff = nil
    if min_angle_diff.abs > max_angle_diff.abs
      # puts "CASE 3"
      second_diff = max_angle_diff.abs
      alt_value = max_angle
    else
      # puts "CASE 4"
      second_diff = min_angle_diff.abs
      alt_value = min_angle
    end
    # puts "VALUE: #{value}"

    if first_diff > second_diff
      # puts "CASE 5"
      value = alt_value
    end
    # puts "VALUE: #{value}"
    return value
  end

  def nearest_angle angle, min_angle, max_angle
    GeneralObject.nearest_angle(angle, min_angle, max_angle)
  end

# # new_pos_x = @x / @screen_width.to_f * (AXIS_X_MAX - AXIS_X_MIN) + AXIS_X_MIN;
# # new_pos_y = (1 - @y / @screen_height.to_f) * (AXIS_Y_MAX - AXIS_Y_MIN) + AXIS_Y_MIN;
#   # This isn't exactly right, objects are drawn farther away from center than they should be.
#   def convert_x_and_y_to_opengl_coords
#     # Don't have to recalce these 4 variables on each draw, save to singleton somewhere?
#     middle_x = (@screen_width.to_f) / 2.0
#     middle_y = (@screen_height.to_f) / 2.0
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
    middle_x = @screen_width / 2
    middle_y = @screen_height / 2

    ratio = @screen_width.to_f / @screen_height.to_f

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

  def self.convert_x_and_y_to_opengl_coords(x, y, screen_width, screen_height)
    middle_x = screen_width.to_f / 2.0
    middle_y = screen_height.to_f / 2.0

    ratio = screen_width.to_f / screen_height.to_f

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
    @y >= 0 && @y <= @screen_height
  end

  def collision_triggers
    # Explosion or something
    # Override
  end

end