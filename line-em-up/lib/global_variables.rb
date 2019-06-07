


module GlobalVariables
  class << self
    attr_reader  :width_scale, :height_scale, :screen_pixel_width, :screen_pixel_height, :map_pixel_width, :map_pixel_height
    attr_reader  :map_tile_width, :map_tile_height, :tile_pixel_width, :tile_pixel_height
  end

  def self.set_config(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height)
    @tile_pixel_width  = tile_pixel_width
    puts "SETTING: @tile_pixel_width - #{@tile_pixel_width}"
    @tile_pixel_height = tile_pixel_height

    @map_pixel_width = map_pixel_width
    @map_pixel_height = map_pixel_height

    @map_tile_width = map_tile_width
    @map_tile_height = map_tile_height

    @width_scale  = width_scale
    @height_scale = height_scale

    @screen_pixel_width  = screen_pixel_width
    @screen_pixel_height = screen_pixel_height
  end


end