require_relative 'building.rb'

# Offensive store for now, don't have any other hardport types atm.
module Buildings
  class Shipyard < Buildings::Building


    ENABLE_FACTION_COLORS = true
    attr_reader :credits

    def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
      @window = window
      super(current_map_tile_x, current_map_tile_y, window, options)
      # offensive_types = Launcher.descendants
      offensive_types_with_rarities = {}
      PilotableShips::PilotableShip.descendants.each do |launcher_klass|
        next if launcher_klass::ABSTRACT_CLASS
        offensive_types_with_rarities[launcher_klass.to_s] = launcher_klass::RARITY_MAX - launcher_klass::STORE_RARITY
      end
      @store_item_count = rand(5) + 1
      (0..@store_item_count).each do |i|
        @drops << random_weighted(offensive_types_with_rarities)
      end
      @click_area = LUIT::ClickArea.new(@window, self, :object_inventory, 0, 0, ZOrder::HardPointClickableLocation, @image_width, @image_height, nil, nil, {hide_rect_draw: true, key_id: Gosu::KB_E})
      # color, hover_color = [Gosu::Color.argb(0xff_8aff82), Gosu::Color.argb(0xff_c3ffbf)]
      # @click_area = LUIT::ClickArea.new(self, :object_inventory, 0, 0, ZOrder::UI, @image_width, @image_height, color, hover_color)
      @button_id_mapping = {}
      # Need to add sell window to ship_loadout_menu\ship_loadout_setting
      # Also need to cost credits, add credits to player.
      @button_id_mapping[:object_inventory] = lambda { |window, menu, id|
        if !window.ship_loadout_menu.active
          window.block_all_controls = true; window.ship_loadout_menu.loading_object_inventory(menu, menu.drops, menu.credits, :store); window.ship_loadout_menu.enable
        end
      }
      @is_hovering = false
      @is_close_enough_to_open = false
      @max_lootable_pixel_distance = 1 * @average_tile_size
      @image = self.class::get_image
      @info = @image.gl_tex_info
      @credits = rand(500) + 500
      @interactible = true
      # @invulnerable = true
    end

    def self.get_minimap_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/minimap_offensive_store.png")
    end

    def get_minimap_image
      return self.class.get_minimap_image
    end

    def set_drops drops
      @drops = drops
    end

    def add_credits new_credits
      @credits += credits
    end
    def subtract_credits new_credits
      @credits -= credits
    end
    # Not needed on OffensiveStore
    def set_window window
      @window = window
    end

    def onClick element_id
      if @window.player.is_alive && @is_close_enough_to_open && @interactable_object && !is_hostile_to?(@interactable_object.get_faction_id)
        button_clicked_exists = @button_id_mapping.key?(element_id)
        if button_clicked_exists
         # puts "BUTTON EXISTS: #{element_id}"
          @button_id_mapping[element_id].call(@window, self, element_id)
        else
         # puts "Clicked button that is not mapped: #{element_id}"
        end
        return button_clicked_exists
      else
        return false
      end
    end

    def self.get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/offensive_store.png", :tileable => true)
    end

    def random_weighted(weighted)
      max    = sum_of_weights(weighted)
      target = rand(1..max)
      weighted.each do |item, weight|
        return item if target <= weight
        target -= weight
      end
    end

    def sum_of_weights(weighted)
      weighted.inject(0) { |sum, (item, weight)| sum + weight }
    end

  end

end