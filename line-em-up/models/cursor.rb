require_relative 'general_object.rb'
class Cursor < GeneralObject
  attr_accessor :x, :y, :image_width_half, :image_height_half


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
    @x = 0
    @y = 0
  end


  def draw
    @image.draw(@x - @image_width_half, @y - @image_height_half, ZOrder::Cursor, @scale, @scale)
  end

  def update mouse_x, mouse_y
    @x = mouse_x
    @y = mouse_y
  end

end