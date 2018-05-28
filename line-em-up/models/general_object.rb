class GeneralObject
  attr_accessor :time_alive, :x, :y
  LEFT  = 'left'
  RIGHT = 'right'
  SCROLLING_SPEED = 4

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def initialize(scale, x = nil, y = nil)
    @scale = scale
    @image = get_image
    @x = x
    @y = y
    @time_alive = 0
  end

  # If using a different class for ZOrder than it has for model name, or if using subclass (from subclass or parent)
  def get_draw_ordering
    # raise "Need to override via subclass"
    nil
  end


  def draw
    # Will generate error if class name is not listed on ZOrder
    @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering || Module.const_get("ZOrder::#{self.class.name}"), @scale, @scale)
    # @image.draw(@x - @image.width / 2, @y - @image.height / 2, get_draw_ordering)
  end

  def draw_rot
    # draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
    @image.draw_rot(@x, @y, get_draw_ordering || Module.const_get("ZOrder::#{self.class.name}"), @y, 0.5, 0.5, @scale, @scale)
  end

  def get_height
    @image.height * @scale
  end

  def get_width
    @image.width * @scale
  end

  def get_size
    (get_height * get_width) / 2
  end

  def get_radius
    ((get_height + get_width) / 2) / 2
  end  

  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    # Inherit, add logic, then call this to calculate whether it's still visible.
    @time_alive ||= 0 # Temp solution
    @time_alive += 1
    return is_on_screen?(width, height)
  end

  protected

  def is_on_screen? width, height
    # @image.draw(@x - @image.width / 2, @y - @image.height / 2, ZOrder::Player)
    @y > (0 - get_height) && @y < (height + get_height) && @x > (0 - get_width) && @x < (width + get_width)
  end
end