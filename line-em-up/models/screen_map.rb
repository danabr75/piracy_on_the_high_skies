require_relative 'screen_fixed_object.rb'


class ScreenMap < ScreenFixedObject
  def initialize(background_map_data, map_tile_width, map_tile_height, options = {})
    super(options)
    @map_tile_width  = map_tile_width
    @map_tile_height = map_tile_height
    @font_height  = (15 * @height_scale).to_i
    @font = Gosu::Font.new(@font_height)
    # @screen_pixel_width  = screen_pixel_width
    # @screen_pixel_height = screen_pixel_height
    @x = @screen_pixel_width
    @y = @font_height
    @cell_width  = @height_scale / 2.0
    @cell_height = @height_scale / 2.0

    @mini_map_pixel_width  = @map_tile_width  * @cell_width
    @mini_map_pixel_height = @map_tile_height * @cell_height

    @mini_map = init_map(background_map_data)
    # puts "MINIMAP LENGTH: #{@mini_map.count}"
  end

  def init_map map_data
    map = []
    map_data.each do |y_row|
      map_y_row = []
      y_row.each do |x_row|
        color = nil
        case x_row['terrain_type']
        when 'snow'
          color = Gosu::Color.argb(0xff_ffffff)
        when 'water'
          color = Gosu::Color.argb(0xff_0066ff)
        when 'dirt'
          color = Gosu::Color.argb(0xff_ffb84d)
        else
          color = Gosu::Color.argb(0xff_808080)
          # nothing
        end
        map_y_row << color
      end
      map << map_y_row.reverse
    end
    return map.reverse
  end

  def draw
    # text = 'test'
    # puts "@height_scale: #{@height_scale}"
    # @fot.draw(text, @x - (@font.text_width(text) * @height_scale), @y, ZOrder::UI, @height_scale, @height_scale, 0xff_ffff00)
    # @font.draw(text, @x - 50, @y, ZOrder::UI, @height_scale, @height_scale, 0xff_ffff00)
    y_offset = 0
    x_offset = @mini_map_pixel_height

    @mini_map.each do |y_row|
      y_row.each do |x_row|
        # puts "DRAWING HERE"
        Gosu.draw_rect(x_offset, y_offset, 1.0, 1.0, x_row, ZOrder::UI)
        x_offset -= @cell_width
      end
      y_offset += @cell_height
      x_offset = @mini_map_pixel_height
    end

  end

  def update

  end
end