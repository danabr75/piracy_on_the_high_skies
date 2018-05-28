require_relative 'general_object.rb'
class Cursor < GeneralObject
  # attr_reader :img, :visible, :imgObj


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/crosshair.png")
  end

  
  def initialize scale
    @scale = scale
    @image = get_image
  end


  def draw mouse_x, mouse_y
    @image.draw(mouse_x - get_width / 2, mouse_y - get_height / 2, ZOrder::Cursor, @scale, @scale)
  end

end