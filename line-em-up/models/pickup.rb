require_relative 'general_object.rb'

class Pickup < GeneralObject
  POINT_VALUE_BASE = 0
  attr_reader :x, :y

  def initialize(scale, x = nil, y = nil)
    @scale = scale
    @image = get_image
    @x = x
    @y = y
    @time_alive = 0
  end

  def get_draw_ordering
    ZOrder::Projectile
  end

  # def draw
  #   # @image.draw_rot(@x, @y, ZOrder::Pickups, @y, 0.5, 0.5, 1, 1)
  #   raise "override me!"
  # end


  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    @y += SCROLLING_SPEED * @scale

    super(width, height, mouse_x, mouse_y)
  end

  def collected_by_player player
    raise "Override me!"
  end

end