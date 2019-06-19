# A 2D object, fixed to the screen permanently. Probably does not move around.
# Only uses X and Y for pixel placement.
# Used by menu (maybe), player, HUD. NOT LASERS.
require_relative 'general_object.rb'

class ScreenFixedObject < GeneralObject
 # def initialize(current_map_pixel_x, current_map_pixel_y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, options = {})
  attr_reader :angle
  MAX_TIME_ALIVE = 360

  def initialize(options = {})
    @x = nil
    @y = nil

    super(options)

    # validate_array([], self.class.name, __callee__)
    # validate_string([], self.class.name, __callee__)
    # validate_float([], self.class.name, __callee__)
    # validate_int([], self.class.name, __callee__)
    # validate_not_nil([], self.class.name, __callee__)

    # validate_int([x, y, screen_pixel_width, screen_pixel_height], self.class.name, __callee__)
    # validate_float([width_scale, height_scale], self.class.name, __callee__)
    # validate_not_nil([yx, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height], self.class.name, __callee__)

    # super(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options)
    # if options[:relative_object]
    #   if LEFT == options[:side]
    #     @x = options[:relative_object].x - (options[:relative_object].get_width / 2)
    #     @y = options[:relative_object].y
    #   elsif RIGHT == options[:side]
    #     @x = (options[:relative_object].x + options[:relative_object].get_width / 2)
    #     @y = options[:relative_object].y
    #   else
    #     @x = options[:relative_object].x
    #     @y = options[:relative_object].y
    #   end
    # else
    #   @x = x
    #   @y = y
    # end
    # @x = @x + options[:relative_x_padding] if options[:relative_x_padding]
    # @y = @y + options[:relative_y_padding] if options[:relative_y_padding]

    # @x_offset = 0
    # @y_offset = 0
    # @time_alive = 0
  end

  def update_x_and_y x, y
    @x = x
    @y = y
  end

  def update mouse_x, mouse_y, player
    # @time_alive += 0

    # Why are we calling general object here? we're not alive. becuase of palyer.
    # return self.class::MAX_TIME_ALIVE.nil? || @time_alive < self.class::MAX_TIME_ALIVE
    return (self.class::MAX_TIME_ALIVE.nil? || @time_alive < self.class::MAX_TIME_ALIVE) && super(mouse_x, mouse_y, player)
  end

end