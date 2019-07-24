# Move to UI subfolder

require_relative '../menu.rb'
module OuterMapObjects
  class FooterBar < ScreenFixedObject

    # `outer_window` is for mouse clicks. Local window is for actions.
    def initialize(window, height_scale, width, height, options = {})
      @window, @height_scale, @width, @height = [window, height_scale, width, height]
      # @local_window = local_window
      @menu = Menu.new(@window, @width / 2.0, @height - (20 * @height_scale), ZOrder::UI, @height_scale, {button_size: 20, is_horizontal: true})
      @menu.add_item(
        :inventory_hotbar, "I",
        0, 0,
        lambda {|window, menu, id| window.block_all_controls = true; (window.ship_loadout_menu.active ? window.menus_disable : window.menus_disable && window.ship_loadout_menu.enable) },
        nil,
        {is_button: true}
      )
      # @menu.add_item(
      #   :minimap_hotbar, "M",
      #   0, 0,
      #   lambda {|window, menu, id| window.block_all_controls = true; window.show_minimap = !window.show_minimap},
      #   nil,
      #   {is_button: true}
      # )
      # @menu.add_item(
      #   :factions_hotbar, "R",
      #   0, 0,
      #   lambda {|window, menu, id| window.block_all_controls = true; puts "R"},
      #   nil,
      #   {is_button: true}
      # )
      @menu.add_item(
        :pause_hotbar, "P",
        0, 0,
        lambda {|window, menu, id| window.block_all_controls = true; window.game_pause = !window.game_pause },
        nil,
        {is_button: true}
      )
      @menu.enable

      @menu_padding = 4 * @height_scale
      # @menu.add_item(
      #   :exit_map, "Yes",
      #   0, 0,
      #   # Might be the reason why the mapping has to exist in the game window scope. Might not have access to ship loadout menu here.
      #   lambda {|window, menu, id| window.block_all_controls = true; window.close },
      #   nil,
      #   {is_button: true}
      # )
      # # This will close the window... which i guess is fine.
      # @menu.add_item(
      #   :cancel_map_exit, "No",
      #   0, 0,
      #   lambda {|window, menu, id|  window.block_all_controls = true; window.player.cancel_map_exit; menu.disable  }, 
      #   nil,
      #   {is_button: true}
      # )
    end

    # def block_all_controls
    #   @window.block_all_controls = true
    # end

    def get_draw_ordering
      ZOrder::UI
    end

    def draw
      @menu.draw

      # This could use some work, but will probably replace with better graphics anyway.
      Gosu::draw_rect(@menu.x - @menu.width / 2.0 - @menu.button_size, @menu.y - (@menu.button_size * 0.75), @menu.width + @menu.button_size_half, @menu.height - (@menu.button_size * 0.5), Gosu::Color.argb(0xff_ffcc00), ZOrder::MenuBackground)

    end


    def update
      @menu.update
    end

    def onClick element_id
      @menu.onClick(element_id)
    end

  end
end