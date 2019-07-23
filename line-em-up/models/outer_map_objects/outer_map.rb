require_relative 'player.rb'
require_relative 'cursor.rb'

module OuterMapObjects
  class OuterMap
    attr_reader :active

    ICON_IMAGE_SCALER = 4.0

    ICON_IMAGE_WIDTH  = 128
    ICON_IMAGE_HEIGHT = 128

    def initialize window, width, height, height_scale, config_path
      @width  = width
      @height = height
      @window = window
      @height_scale = height_scale
      # LUIT.config({window: window})
      @map_location_datas = {
        desert_v14_small: {
          outer_map_icon: 'desert',
          displayed_name: 'desert', x: (225 * height_scale), y: (225 * height_scale)
        },
        snow_v15_very_small: {
          outer_map_icon: 'snow',
          displayed_name: 'snow', x: (100 * height_scale), y: (200 * height_scale)
        }
      }

      @cell_width  = 30 * height_scale
      @cell_height = 30 * height_scale

      @height_scale_with_icon_image_scaler = height_scale / ICON_IMAGE_SCALER

      @icon_image_width       = (ICON_IMAGE_WIDTH) / ICON_IMAGE_SCALER
      @icon_image_height      = (ICON_IMAGE_HEIGHT) / ICON_IMAGE_SCALER
      @icon_image_width_half  = (@icon_image_width  / 2.0)
      @icon_image_height_half = (@icon_image_height / 2.0)


      refresh

      @player  = OuterMapObjects::Player.new(@height_scale)
      @pointer = OuterMapObjects::Cursor.new(@height_scale)
      @mouse_x = 0
      @mouse_y = 0
      
      @active = false

      @menu = Menu.new(self, @width / 2, 10 * @height_scale, ZOrder::UI, @height_scale, {add_top_padding: true})
      @menu.add_item(
        :resume, "Resume",
        0, 0,
        lambda {|window, menu, id| menu.disable },
        nil,
        {is_button: true}
      )
      @menu.add_item(
        :save_game, "Save",
        0, 0,
        lambda {|window, menu, id| window.save_game },
        nil,
        {is_button: true}
      )
      @menu.add_item(
        :load_game, "Load",
        0, 0,
        lambda {|window, menu, id| window.load_game },
        nil,
        {is_button: true}
      )
      @menu.add_item(
        :exit_to_main_menu, "Exit to Main Menu",
        0, 0,
        lambda {|window, menu, id| menu.disable; window.activate_main_menu }, 
        nil,
        {is_button: true}
      )
      @menu.add_item(
        :exit_to_desktop, "Exit to Desktop",
        0, 0,
        lambda {|window, menu, id| window.exit_game; }, 
        nil,
        {is_button: true}
      )

    end

    def refresh
      # puts "REFRESH MAP"
      LUIT.config({window: @window})
      @activated_inner_map = nil
      @button_id_mapping = {}
      @map_clickable_locations = []
      @key_pressed_map = {}
      @block_all_controls = false
      @map_location_datas.each do |key, value|
        button_key = key.to_sym
        click_area = LUIT::ClickArea.new(self, button_key, value[:x], value[:y], ZOrder::UI, @icon_image_width, @icon_image_height)
        @button_id_mapping[button_key] = lambda { |window, menu, id| menu.activate_inner_map(id) }
        image = Gosu::Image.new("#{MEDIA_DIRECTORY}/outer_map/#{value[:outer_map_icon]}.png")
        @map_clickable_locations << {click_area: click_area, displayed_name: value[:displayed_name], image: image, x: value[:x], y: value[:y]}
      end
    end

    def exit_game
      @window.close
    end

    def save_game
      @window.save_game
    end

    def activate_main_menu
      @window.activate_main_menu
    end

    def enable
      refresh
      @active = true
    end

    def disable
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

    def activate_inner_map id
      @activated_inner_map = id
    end

    def post_activated_inner_map
      @activated_inner_map = nil
    end

    def update mouse_x, mouse_y
      if Gosu.button_down?(Gosu::KbEscape) && key_id_lock(Gosu::KbEscape)
        if @menu.active
          @menu.disable
        else
          @menu.enable
        end
      end

      # puts "PUTER UPDATE: #{mouse_x} - #{mouse_y}"
      @mouse_x = mouse_x
      @mouse_y = mouse_y
      @player.update
      @pointer.update(mouse_x, mouse_y)
      @menu.update
      @map_clickable_locations.each do |value|
        value[:click_area].update(0,0)
      end
      return @activated_inner_map
    end

    def draw
      Gosu::draw_rect(0, 0, @width, @height, Gosu::Color.argb(0xff_595959), ZOrder::MenuBackground)
      @pointer.draw
      @menu.draw
      @map_clickable_locations.each do |value|
        value[:image].draw(value[:x] - @icon_image_width_half, value[:y] - @icon_image_height_half, ZOrder::MiniMapIcon, @height_scale_with_icon_image_scaler, @height_scale_with_icon_image_scaler)
        # value[:click_area].draw(0,0)
      end
    end

    def onClick element_id
      puts "ONClick Outer - #{element_id}"
      if @menu.active
        @menu.onClick(element_id)
      else
        button_clicked_exists = @button_id_mapping.key?(element_id)
        if button_clicked_exists
          @button_id_mapping[element_id].call(@window, self, element_id)
        else
          puts "Clicked button that is not mapped: #{element_id}"
        end
        return button_clicked_exists
      end
    end

  end
end