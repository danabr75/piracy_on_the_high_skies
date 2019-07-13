require_relative 'screen_fixed_object.rb'


class ScreenMap < ScreenFixedObject

  IMAGE_SCALER = 2.5

  def initialize(map_name, map_tile_width, map_tile_height, options = {})
    super(options)

    file_path = "#{MAP_DIRECTORY}/#{map_name}_minimap.png"
    @image = Gosu::Image.new(file_path)

    @image_width  = @image.width  * @height_scale_with_image_scaler
    @image_height = @image.height * @height_scale_with_image_scaler

    @map_tile_width  = map_tile_width
    @map_tile_height = map_tile_height

    @cell_padding_width  = @height_scale * 3.0
    @cell_padding_height = @height_scale * 3.0

    @font_height  = (15 * @height_scale).to_i
    @font = Gosu::Font.new(@font_height)
    # @screen_pixel_width  = screen_pixel_width
    # @screen_pixel_height = screen_pixel_height
    @x = @screen_pixel_width - @cell_padding_width
    @y = @cell_padding_height
    @cell_width  = @height_scale / 2.0
    @cell_height = @height_scale / 2.0

    @mini_map_pixel_width  = @map_tile_width  * @cell_width
    @mini_map_pixel_height = @map_tile_height * @cell_height

    @color = Gosu::Color.argb(0xcc_ffffff)

    # @mini_map_image = init_map(background_map_data)
    # puts "MINIMAP LENGTH: #{@mini_map.count}"
  end

  def draw
    @image.draw(@x - @image_width, @y, ZOrder::UI, @height_scale_with_image_scaler, @height_scale_with_image_scaler, @color)
    # text = 'test'
    # puts "@height_scale: #{@height_scale}"
    # @fot.draw(text, @x - (@font.text_width(text) * @height_scale), @y, ZOrder::UI, @height_scale, @height_scale, 0xff_ffff00)
    # @font.draw(text, @x - 50, @y, ZOrder::UI, @height_scale, @height_scale, 0xff_ffff00)
    # y_offset = 0
    # x_offset = @mini_map_pixel_height

    # @mini_map.each do |y_row|
    #   y_row.each do |x_row|
    #     # puts "DRAWING HERE"
    #     Gosu.draw_rect(x_offset, y_offset, 1.0, 1.0, x_row, ZOrder::UI)
    #     x_offset -= @cell_width
    #   end
    #   y_offset += @cell_height
    #   x_offset = @mini_map_pixel_height
    # end

  end

  def update

  end
end