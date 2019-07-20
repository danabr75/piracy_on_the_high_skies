# Move to UI subfolder

require_relative 'general_object.rb'

class FooterBar < ScreenFixedObject

  def initialize(screen_pixel_width, screen_pixel_height, width_scale, height_scale, window, options = {})
    @window = window
    super(options)

    # @screen_pixel_width = screen_pixel_width
    # @screen_pixel_height = screen_pixel_height
    # @width_scale = width_scale
    # @height_scale = height_scale

    @menu = Menu.new(@window, @screen_pixel_width / 2, @screen_pixel_height - (50 * @height_scale), ZOrder::UI, @height_scale, {button_size: 20})
    @menu.add_item(
      nil, "I",
      0, 0,
      lambda {|window, menu, id| window.block_all_controls = true; (window.ship_loadout_menu.active ? window.menus_disable : window.menus_disable && window.ship_loadout_menu.enable) },
      nil,
      {is_button: true}
    )
    @menu.enable
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

  def get_draw_ordering
    ZOrder::UI
  end

  def draw
    @menu.draw
  end


  def update
    @menu.update
  end

  def onClick element_id
    @menu.onClick(element_id)
  end

end