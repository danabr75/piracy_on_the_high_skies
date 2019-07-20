require_relative 'screen_fixed_object.rb'

class MessageFlash < ScreenFixedObject
  MAX_TIME_ALIVE = 360
  def initialize(text, options = {})
    super(options)
    @text = text
    @font_height  = (15 * @average_scale).to_i
    @font = Gosu::Font.new(@font_height)
    # @screen_pixel_width  = screen_pixel_width
    # @screen_pixel_height = screen_pixel_height
    @y = @screen_pixel_height / 5.0
    @health = 1
  end

  def draw y_index
    y_offset = @font_height * y_index
    @font.draw(@text, ((@screen_pixel_width / 2) - @font.text_width(@text) / 2), @y + y_offset, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
  end
end