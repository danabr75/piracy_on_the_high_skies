# A 2D object, fixed to the screen permanently. Probably does not move around.
# Only uses X and Y for pixel placement.
# Used by menu (maybe), player, HUD. NOT LASERS.
require_relative 'general_object.rb'

class ScreenFixedObject < GeneralObject
 # def initialize(current_map_pixel_x, current_map_pixel_y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, options = {})
  attr_reader :angle
  MAX_TIME_ALIVE = nil

  def initialize(options = {})
    @x = nil
    @y = nil

    super(options)
  end

  def update_x_and_y x, y
    @x = x
    @y = y
  end

  def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
    # @time_alive += 0

    # Why are we calling general object here? we're not alive. becuase of palyer.
    # return self.class::MAX_TIME_ALIVE.nil? || @time_alive < self.class::MAX_TIME_ALIVE
    return (self.class::MAX_TIME_ALIVE.nil? || @time_alive < self.class::MAX_TIME_ALIVE) && super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
  end

end