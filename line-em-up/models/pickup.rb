require_relative 'background_fixed_object.rb'

class Pickup < BackgroundFixedObject

  def get_draw_ordering
    ZOrder::Pickups
  end

  # Most classes will want to just override this
  def draw
    @image.draw_rot(@x, @y, ZOrder::Pickups, @y, 0.5, 0.5, @width_scale, @height_scale)
  end


  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    # @y += @current_speed * scroll_factor

    # super(mouse_x, mouse_y)
    true
  end

  def collected_by_player player
    raise "Override me!"
  end

end