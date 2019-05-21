require_relative 'general_object.rb'
class Cursor < GeneralObject
  attr_accessor :x, :y, :image_width_half, :image_height_half


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/crosshair.png")
  end

  
  def initialize scale, screenx, screeny, width_scale, height_scale
    @width_scale  = width_scale
    @height_scale = height_scale
    @screen_width  = screenx
    @screen_height = screeny
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
    @image.draw(@x - @image_width_half, @y - @image_height_half, ZOrder::Cursor, @width_scale, @height_scale)
  end

  # THESE ARE ON-SCREEN COORDS, NOT OPENGL COORDS
  def convert_x_and_y_to_opengl_coords
    # puts "convert_x_and_y_to_opengl_coords"
    # puts "@screen_width: #{@screen_width}"
    middle_x = @screen_width.to_f / 2.0
    # puts "MIDDLE X: #{middle_x}"
    middle_y = @screen_height.to_f / 2.0
    increment_x = 1.0 / middle_x
    # The zoom issue maybe, not quite sure why we need the Y offset.
    increment_y = (1.0 / middle_y)
    new_pos_x = (@x.to_f - middle_x) * increment_x
    # puts ""
    new_pos_y = (@y.to_f - middle_y) * increment_y
    # Inverted Y
    new_pos_y = new_pos_y * -1

    # height = @image_height.to_f * increment_x
    # puts "@screen_height: #{@screen_height}"
    # puts "@screen_width: #{@screen_width}"
    # puts "@new_pos_x: #{new_pos_x}"
    # puts "@new_pos_y: #{new_pos_y}"
    # puts "@x: #{@x}"
    # puts "@y: #{@y}"
    return [new_pos_x, new_pos_y, increment_x, increment_y]
  end

  def update mouse_x, mouse_y
    @x = mouse_x
    @y = mouse_y
    # puts "CURSOR X: #{@x}"
    # puts "CURSOR Y: #{@y}"
    new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords
    # puts "START CURSOR"
    # puts "  new_pos_x: #{new_pos_x}"
    # puts "  new_pos_y: #{new_pos_y}"
    # puts "  increment_x: #{increment_x}"
    # puts "  increment_y: #{increment_y}"
    # puts "END CURSOR"
  end

end