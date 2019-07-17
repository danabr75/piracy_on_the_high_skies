require_relative 'building.rb'

# Offensive store for now, don't have any other hardport types atm.
module Buildings
  class RepairArea < Buildings::Building


    attr_reader :credits

    def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
      @window = window
      super(current_map_tile_x, current_map_tile_y, options)
    end



    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, air_targets = {}, options = {}
      air_targets.each do |key, target|
        if Gosu.distance(target.current_map_pixel_x, target.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @average_tile_size
          target.increase_health(1)
        end
      end
      if Gosu.distance(player.current_map_pixel_x, player.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @average_tile_size
        player.increase_health(1)
      end

      return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, air_targets, options)
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
      Gosu::Image.new("#{MEDIA_DIRECTORY}/repair_area.png", :tileable => true)
    end

  end

end