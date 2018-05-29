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
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4
  end


  def draw mouse_x, mouse_y
    @image.draw(mouse_x - get_width / 2, mouse_y - get_height / 2, ZOrder::Cursor, @scale, @scale)
  end

end