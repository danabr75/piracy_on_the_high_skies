# require 'luit'
require_relative 'setting.rb'
require_relative '../models/basic_ship.rb'
# require "#{MODEL_DIRECTORY}/basic_ship.rb"
# require_relative "config_settings.rb"

class ShipSetting < Setting
  # MEDIA_DIRECTORY
  SELECTION = ["MiteShip", "BasicShip"]
  NAME = "ship"

  # attr_accessor :mouse_x, :mouse_y
  def initialize window, fullscreen_height, max_width, max_height, current_height, config_file_path
    puts "fullscreen_height: #{fullscreen_height}"
    puts "max height: #{max_height}"
    @selection = self.class::SELECTION
    # puts "INNITING #{config_file_path}"
    @font = Gosu::Font.new(20)
    # @x = width
    puts "current_height: #{current_height} - 100"
    @y = current_height
    @max_width = max_width
    @max_height = max_height
    @prev_x = 0
    puts "PREV: #{@prev_x} - for max_width: #{max_width}"
    # @next_x = max_width
    # LUIT 205 width == 480
    # X coord system is half that of what it should be, for the LUIT elements
    @next_x = (max_width / 2)
    puts ""
    puts "NEXT: #{@next_x}"
    @config_file_path = config_file_path
    @name = self.class::NAME
    @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
    @fullscreen_height = fullscreen_height
    LUIT.config(window)
    @next_button = LUIT::Button.new(self, :next, @next_x, @y, "Next", 0, 1)
    # @next_button.x = @next_x - (@next_button.w / 2)

    @prev_button = LUIT::Button.new(self, :previous, @prev_x, @y, "Previous", 0, 1)
    @window = window
    @button_id_mapping = self.class.get_id_button_mapping
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

  # def get_image
    # klass = eval(@value)
    # puts "KLASS HERE : #{klass.get_image_assets_path(klass::SHIP_MEDIA_DIRECTORY)}"
    # return klass.get_right_broadside_image(klass::SHIP_MEDIA_DIRECTORY)
  # end

  def update mouse_x, mouse_y
    # @mouse_x = mouse_x
    # @mouse_y = mouse_y
    # @next_x = max_width / 5
    # puts "new next x: #{@next_x}"
    # @next_button.update(@next_x - @next_button.w, @y)
    @next_button.update(@next_x - @next_button.w, @y)
    # puts "NEXT IS AT: #{@next_button.x}"
    # @next_button.update(@next_x - (@next_button.w / 2), @y)
    @prev_button.update(@prev_x, @y)
    return @value
  end

  def draw
    # @font.draw("<", @next_x, @y, 1, 1.0, 1.0, 0xff_ffff00)

    @next_button.draw(@next_x - @next_button.w, @y)

    # @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)

    # image = get_image
    # image.draw((@max_width / 2) - image.width / 2, y + image.height / 2, 1)
    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)
    # @font.draw(">", @prev_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
    @prev_button.draw(@prev_x, @y)
  end

end