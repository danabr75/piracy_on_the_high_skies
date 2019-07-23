require_relative 'outer_map_objects/cursor.rb'

class InGameMenu
  attr_reader :active, :current_save_file_path

  def delete_current_save_file(save_file_path)
    File.delete(save_file_path) if File.file?(save_file_path)
  end

  def init_current_save_file(save_file_path)
    # if !File.file?(save_file_path)
      ConfigSetting.set_setting(save_file_path, "current_ship_index", "0")
      ConfigSetting.set_mapped_setting(save_file_path, ["player_fleet", "0", "klass"], "BasicShip")
      init_data = {
        "0":"HardpointObjects::GrapplingHookHardpoint","1":"HardpointObjects::BulletHardpoint",
        "4":"HardpointObjects::BulletHardpoint","3":"HardpointObjects::BulletHardpoint",
        "5":"HardpointObjects::DumbMissileHardpoint","2":"HardpointObjects::BulletHardpoint",
        "10":"HardpointObjects::BasicEngineHardpoint",
        "6":"HardpointObjects::MinigunHardpoint","8":"HardpointObjects::BasicEngineHardpoint",
        "12":"HardpointObjects::BasicSteamCoreHardpoint",
      }
      init_data.each do |key, value|
        ConfigSetting.set_mapped_setting(save_file_path, ["player_fleet", "0", "hardpoint_locations", key], value)
      end
      ConfigSetting.set_setting(save_file_path, "Credits", "500")
    # end
  end

  def initialize window, width, height, width_scale, height_scale, config_path, current_save_file_path
    @width  = width
    @height = height
    @window = window
    @height_scale = height_scale
    @width_scale = width_scale

    @cell_width  = 30 * height_scale
    @cell_height = 30 * height_scale

    @current_save_file_path = current_save_file_path

    @pointer = OuterMapObjects::Cursor.new(@height_scale)
    @mouse_x = 0
    @mouse_y = 0
    
    @active = true

    refresh

    @menu_background = Gosu::Image.new("#{MEDIA_DIRECTORY}/main_screen_background.png")

    @menu = Menu.new(self, @width / 2, 10 * @height_scale, ZOrder::UI, @height_scale, {add_top_padding: true})
    if File.file?(@current_save_file_path)
      @menu.add_item(
        :in_game_menu_resume, "Continue",
        0, 0,
        lambda {|window, menu, id| menu.disable; window.activate_outer_map },
        nil,
        {is_button: true}
      )
    end

    # if loadable save is present
    # @menu.add_item(
    #   :load_game, "Load Last Save",
    #   0, 0,
    #   lambda {|window, menu, id| window.load_game },
    #   nil,
    #   {is_button: true}
    # )

    @menu.add_item(
      :in_game_menu_start_new_game, File.file?(@current_save_file_path) ? "Start New Game (will overwrite your old save)" : "Start New Game",
      0, 0,
      lambda {|window, menu, id| window.delete_current_save_file(window.current_save_file_path); window.init_current_save_file(window.current_save_file_path); menu.disable; window.activate_outer_map },
      nil,
      {is_button: true}
    )
    @menu.add_item(
      :in_game_menu_exit, "Exit",
      0, 0,
      lambda {|window, menu, id| window.exit_game; }, 
      nil,
      {is_button: true}
    )
    @activated_outer_map = false
    # @menu.enable
  end

  def refresh
    LUIT.config({window: @window})
  end

  def exit_game
    @window.close
  end

  def load_game
    @window.load_game
  end

  # def save_game
  #   @window.save_game
  # end

  def enable
    # puts "IN GAME MENY ENABLE - #{@menu.active}"
    refresh
    @menu.enable
    @activated_outer_map = false
    @active = true
    @menu.enable
  end

  def disable
    @menu.disable
    @activated_outer_map = false
    @active = false
  end

  def button_up id
    @block_all_controls = false
    key_id_release(id)
  end

  def key_id_release id
    value = @key_pressed_map.delete(id)
  end

  def key_id_lock id
    if @key_pressed_map.key?(id)
      return false
    else
      @key_pressed_map[id] = true
      return true
    end
  end

  def activate_outer_map
    # raise "STOP HERE"
    @activated_outer_map = true
  end

  def post_activated_outer_map
    @activated_outer_map = false
  end

  def update mouse_x, mouse_y
    # if Gosu.button_down?(Gosu::KbEscape) #&& key_id_lock(Gosu::KbEscape)
    #   # if @menu.active
    #     # @menu.disable
    #   # else
    #     @menu.enable
    #   # end
    # end

    # puts "PUTER UPDATE: #{mouse_x} - #{mouse_y}"
    @mouse_x = mouse_x
    @mouse_y = mouse_y
    @pointer.update(mouse_x, mouse_y)
    @menu.update
    # puts "RETURNING: #{@activated_outer_map}"
    return @activated_outer_map
  end

  def draw
    @menu_background.draw(0, 0, ZOrder::Background, @height_scale / 1.5, @height_scale / 1.5)
    # Gosu::draw_rect(0, 0, @width, @height, Gosu::Color.argb(0xff_d9d9d9), ZOrder::MenuBackground)
    @pointer.draw
    @menu.draw
    # puts "MENU DRaring here:"
    # @map_clickable_locations.each do |value|
    #   value[:image].draw(value[:x] - @icon_image_width_half, value[:y] - @icon_image_height_half, ZOrder::MiniMapIcon, @height_scale_with_icon_image_scaler, @height_scale_with_icon_image_scaler)
    # end
  end

  def onClick element_id
    # if @menu.active
    @menu.onClick(element_id)
    # else
    #   button_clicked_exists = @button_id_mapping.key?(element_id)
    #   if button_clicked_exists
    #     @button_id_mapping[element_id].call(@window, self, element_id)
    #   else
    #     puts "Clicked button that is not mapped: #{element_id}"
    #   end
    #   return button_clicked_exists
    # end
  end

end