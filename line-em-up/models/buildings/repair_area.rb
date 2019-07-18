require_relative 'building.rb'

# Offensive store for now, don't have any other hardport types atm.
module Buildings
  class RepairArea < Buildings::Building


    attr_reader :credits

    def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
      @window = window
      super(current_map_tile_x, current_map_tile_y, options)
      @image = self.class::get_image
      @info = @image.gl_tex_info


      @inactive_color = [1, 1, 1, 1]
      @basic_inactive_color = Gosu::Color.argb(0xff_ffffff)

      @active_color = [0.7, 1, 0.7, 1]
      @basic_active_color = Gosu::Color.argb(0xff_aaffaa)

      @color = @inactive_color
      @basic_color = @basic_inactive_color
    end

    def tile_draw_gl v1, v2, v3, v4
      super(v1, v2, v3, v4, @color)
    end

    def viewable_pixel_offset_x viewable_pixel_offset_x, viewable_pixel_offset_y
      super(viewable_pixel_offset_x, viewable_pixel_offset_y, @basic_color)
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options = {}
      was_used = false
      ships.each do |key, target|
        if Gosu.distance(target.current_map_pixel_x, target.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @average_tile_size
          target.increase_health(0.2 * @fps_scaler)
          was_used = true
        end
      end
      if Gosu.distance(player.current_map_pixel_x, player.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @average_tile_size
        player.increase_health(0.2 * @fps_scaler)
        was_used = true
      end

      if was_used
        @color = @active_color
        @basic_color = @basic_active_color
      else
        @color = @inactive_color
        @basic_color = @basic_inactive_color
      end

      return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options)
    end

    def self.get_minimap_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/minimap_repair_building.png")
    end

    def get_minimap_image
      return self.class.get_minimap_image
    end

    # Not needed on OffensiveStore
    def set_window window
      @window = window
    end



    def self.get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/repair_area.png", :tileable => true)
    end

  end

end