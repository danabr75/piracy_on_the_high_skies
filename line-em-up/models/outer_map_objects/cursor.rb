module OuterMapObjects
  class Cursor

    def initialize height_scale
      @x = 0
      @y = 0
      @height_scale = height_scale
      @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/crosshair.png")
      @image_width  = @image.width
      @image_height = @image.height
      @image_width_half  = @image_width / 2
      @image_height_half = @image_height / 2
    end

    def update mouse_x, mouse_y
      @x = mouse_x
      @y = mouse_y
    end

    def draw
      @image.draw(@x - @image_width, @y - @image_height, ZOrder::Cursor, @height_scale, @height_scale)
    end


  end
end