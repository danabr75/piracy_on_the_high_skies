require_relative 'general_object.rb'
class Cursor < GeneralObject
  # attr_reader :img, :visible, :imgObj


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/crosshair.png")
  end

  
  def initialize scale
    @scale = scale
    @image = get_image
    @image_width  = @image.width  * @scale
    @image_height = @image.height * @scale
    @image_width_half  = @image_width  / 2
    @image_height_half = @image_height / 2
  end


  def draw mouse_x, mouse_y
    @image.draw(mouse_x - @image_width_half, mouse_y - @image_height_half, ZOrder::Cursor, @scale, @scale)
  end

end