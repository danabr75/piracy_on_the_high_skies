require 'luit'

require_relative 'setting.rb'
require_relative '../models/basic_ship.rb'
require_relative '../models/launcher.rb'
# require "#{MODEL_DIRECTORY}/basic_ship.rb"
# require_relative "config_settings.rb"

class ShipLoadoutSetting < Setting
  # MEDIA_DIRECTORY
  SELECTION = ::Launcher.descendants
  NAME = "ship_loadout"

  # def self.get_weapon_options
  #   ::Launcher.descendants
  # end

  # attr_accessor :x, :y, :font, :max_width, :max_height, :selection, :value, :ship_value
  attr_accessor :value, :ship_value
  attr_accessor :mouse_x, :mouse_y
  def initialize window, fullscreen_height, max_width, max_height, current_height, config_file_path, ship_value
    # @window = window # Want relative to self, not window. Can't do that from settting, not a window.
    @mouse_x, @mouse_y = [0,0]
    @window = self # ignoring outer window here? Want actions relative to this window.
    @font = Gosu::Font.new(20)
    # @x = width
    @y = current_height
    @max_width = max_width
    @max_height = max_height
    @next_x = 15
    @prev_x = @max_width - 15 - @font.text_width('>')
    LUIT.config({window: @window, z: 25})
    @selection = []
    @launchers = ::Launcher.descendants.collect{|d| d.name}
    @meta_launchers = []
    @button_id_mapping = self.class.get_id_button_mapping
    @launchers.each_with_index do |klass_name, index|
      klass = eval(klass_name)
      image = klass.get_hardpoint_image
      button_key = "clicked_launcher_#{index}".to_sym
                         # initialize(holder, id, x, y, w = 0, h = 0)
      # click_area = LUIT::Button.new(@window, button_key, 0, 0, 'X', image.width, image.height)
      click_area = LUIT::ClickArea.new(@window, button_key, 0, 0, image.width, image.height)
      @meta_launchers << {
        klass: klass, click_area: click_area, image: image, index: index, click_key: button_key
      }
      @button_id_mapping[button_key] = lambda { |setting| setting.stick_launcher_to_cursor(self) }
    end
    puts "SELECTION: #{@selection}"
    # puts "INNITING #{config_file_path}"
    @config_file_path = config_file_path
    @name = self.class::NAME
    @ship_value = ship_value
    klass = eval(@ship_value)
    @ship = klass.new(1, @max_width / 2, @y + klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY).height / 2, max_width, max_height, {use_large_image: true})
    # @ship_large_image = klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY)
    # @ship_large_image_y = @y + @ship_large_image.height
    # @ship_large_image_h = @ship_large_image.height
    # @ship_large_image_w = @ship_large_image.width
    # @ship.rotate_counterclockwise
    @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
    @fullscreen_height = fullscreen_height
    @window = window

  end

  def stick_launcher_to_cursor launcher
    puts "LUANCHER: #{launcher}"
    puts "stick_launcher_to_cursor: "
    @meta_launchers
    # Remove launcher from meta_launcher list.
    # Stick it to cursor
  end

  def self.get_id_button_mapping
    {
      next: lambda { |setting| setting.next_clicked },
      previous: lambda { |setting| setting.previous_clicked }
    }
  end

  def get_values
    # puts "GETTING DIFFICULTY: #{@value}"
    if @value
      @value
    end
  end

  def update mouse_x, mouse_y, ship_value
    @mouse_x, @mouse_y = [mouse_x, mouse_y]
    puts "SHIP LOADOUT SETTING - UPDATE"
    x = @next_x
    click_area_x = @next_x
    @meta_launchers.each do |launcher|
      klass = launcher[:klass]
      click_area = launcher[:click_area]

      image = launcher[:image]
      click_area.update(click_area_x, @y)
      # click_area.update(0, 0)
      x = x + image.width
      click_area_x = click_area_x + click_area.w
    end


    if ship_value != @ship_value
      puts "NEW SHIP VALUE"
      @ship_value = ship_value
      klass = eval(@ship_value)
      @ship = klass.new(1, @max_width / 2, @y + klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY).height / 2, @max_width, @max_height, {use_large_image: true})
      # @ship_large_image = klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY)
      # @ship_large_image_y = @y + @ship_large_image.height

      # @ship_large_image_h = @ship_large_image.height
      # @ship_large_image_w = @ship_large_image.width

      # @ship.rotate_counterclockwise
    else
      # Do nothing
    end
    # @ship.y = @y
    # @ship.x = (@max_width / 2)
    return @value
  end

  def get_hardpoints
    klass = eval(@ship_value)
    # puts "KLASS HERE : #{klass.get_image_assets_path(klass::SHIP_MEDIA_DIRECTORY)}"
    return {
      front: klass::FRONT_HARDPOINT_LOCATIONS,
      right: klass::RIGHT_BROADSIDE_HARDPOINT_LOCATIONS,
      left:  klass::LEFT_BROADSIDE_HARDPOINT_LOCATIONS
    }
  end

  def get_image
    klass = eval(@ship_value)
    return klass.get_right_broadside_image(klass::SHIP_MEDIA_DIRECTORY)
  end

  def get_large_image
    klass = eval(@ship_value)
    return klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY)
  end

  # deprecated
  def clicked mx, my
    puts "CLICKED!!!!"
    if is_mouse_hovering_next(mx, my)
      # puts "NEXT!!"
      # puts "Value: #{@value}"
      # puts "@selection: #{@selection}"
      # index = @selection.index(@value)
      # puts "INDEX: #{index}"
      # value = @value
      # if index == 0
      #   value = @selection[@selection.count - 1]
      # else
      #   value = @selection[index - 1]
      # end
      # ConfigSetting.set_setting(@config_file_path, @name, value)
      # @value = value
    elsif is_mouse_hovering_prev(mx, my)
      # puts "NEXT!!"
      # puts "Value: #{@value}"
      # puts "@selection: #{@selection}"
      # index = @selection.index(@value)
      # puts "INDEX: #{index}"
      # value = @value
      # if index == @selection.count - 1
      #   value = @selection[0]
      # else
      #   puts "INDEX: #{index}"
      #   puts "@selection[index + 1]: #{@selection[index + 1]}"
      #   value = @selection[index + 1]
      # end
      # ConfigSetting.set_setting(@config_file_path, @name, value)
      # @value = value
    end
  end

  def is_mouse_hovering_next mx, my
    local_width  = @font.text_width('>')
    local_height = @font.height

    (mx >= @next_x and my >= @y) and (mx <= @next_x + local_width) and (my <= @y + local_height)
  end

  def is_mouse_hovering_prev mx, my
    local_width  = @font.text_width('<')
    local_height = @font.height

    (mx >= @prev_x and my >= @y) and (mx <= @prev_x + local_width) and (my <= @y + local_height)
  end

  def draw
    # @font.draw("<", @next_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
    x = @next_x
    click_area_x = @next_x
    @meta_launchers.each do |launcher|
      klass = launcher[:klass]
      click_area = launcher[:click_area]
      # image = klass.get_hardpoint_image
      image = launcher[:image]
      click_area.draw(click_area_x, @y)
      # click_area.draw(0, 0)
      image.draw(x, @y, 1)
      x = x + image.width
      click_area_x = click_area_x + click_area.w
    end

    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)

    # image = get_image
    # image.draw((@max_width / 2) - image.width / 2, y + image.height / 2, 1)
    @ship.draw
    # put back in
    # @ship_large_image.draw((@max_width / 2) - @ship_large_image_w/2, @ship_large_image_y - @ship_large_image_h / 2, 1)
    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)
    @font.draw(">", @prev_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
  end

end