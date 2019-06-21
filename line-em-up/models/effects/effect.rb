module Effects
  class Effect
    # attr_reader  :width_scale, :height_scale, :screen_pixel_width, :screen_pixel_height, :map_pixel_width, :map_pixel_height
    # attr_reader  :map_tile_width, :map_tile_height, :tile_pixel_width, :tile_pixel_height, :damage_increase, :average_scale
    # attr_reader  :average_tile_size
    def init_global_vars
      @tile_pixel_width    = GlobalVariables.tile_pixel_width
      @tile_pixel_height   = GlobalVariables.tile_pixel_height
      @average_tile_size   = GlobalVariables.average_tile_size
      @map_pixel_width     = GlobalVariables.map_pixel_width
      @map_pixel_height    = GlobalVariables.map_pixel_height
      @map_tile_width      = GlobalVariables.map_tile_width
      @map_tile_height     = GlobalVariables.map_tile_height
      @width_scale         = GlobalVariables.width_scale
      @height_scale        = GlobalVariables.height_scale
      @screen_pixel_width  = GlobalVariables.screen_pixel_width
      @screen_pixel_height = GlobalVariables.screen_pixel_height
      @debug               = GlobalVariables.debug
      @damage_increase     = GlobalVariables.damage_increase
      @average_scale       = GlobalVariables.average_scale
    end
    
    def initialize options
      init_global_vars
    end

  end
end