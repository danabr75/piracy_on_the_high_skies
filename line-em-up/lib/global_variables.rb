module GlobalVariables
  class << self
    attr_reader  :width_scale, :height_scale, :screen_pixel_width, :screen_pixel_height, :map_pixel_width, :map_pixel_height
    attr_reader  :map_tile_width, :map_tile_height, :tile_pixel_width, :tile_pixel_height, :debug, :damage_increase, :average_scale
    attr_reader  :average_tile_size
  end

  def self.set_config(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height, debug)
    @tile_pixel_width  = tile_pixel_width
    @tile_pixel_height = tile_pixel_height

    @average_tile_size   = (@tile_pixel_width + @tile_pixel_height) / 2.0

    @map_pixel_width = map_pixel_width
    @map_pixel_height = map_pixel_height

    @map_tile_width = map_tile_width
    @map_tile_height = map_tile_height

    @width_scale  = width_scale
    @height_scale = height_scale

    @screen_pixel_width  = screen_pixel_width
    @screen_pixel_height = screen_pixel_height
    @debug = debug
    @damage_increase = 1
    @average_scale = (@width_scale * @height_scale) / 2.0
  end


end