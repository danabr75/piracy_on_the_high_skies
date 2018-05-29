class GeneralObject
  attr_accessor :time_alive, :x, :y, :health
  LEFT  = 'left'
  RIGHT = 'right'
  SCROLLING_SPEED = 4
  MAX_SPEED      = 5

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def initialize(scale, x = nil, y = nil)
    @scale = scale
    @image = get_image
    @x = x
    @y = y
    @time_alive = 0
    # For objects that don't take damage, they'll never get hit by anything due to having 0 health
    @health = 0
    @image_width  = @image.width  * @scale
    @image_height = @image.height * @scale
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4
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

  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    # Inherit, add logic, then call this to calculate whether it's still visible.
    # @time_alive ||= 0 # Temp solution
    @time_alive += 1
    return is_on_screen?(width, height)
  end

  protected
  def self.get_max_speed
    self::MAX_SPEED
  end

  def is_on_screen? width, height
    # @image.draw(@x - @image.width / 2, @y - @image.height / 2, ZOrder::Player)
    @y > (0 - get_height) && @y < (height + get_height) && @x > (0 - get_width) && @x < (width + get_width)
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


end