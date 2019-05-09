require_relative 'setting.rb'
require_relative '../models/basic_ship.rb'
# require "#{MODEL_DIRECTORY}/basic_ship.rb"
# require_relative "config_settings.rb"

class ShipSetting < Setting
  # MEDIA_DIRECTORY
  SELECTION = ["MiteShip", "BasicShip"]
  NAME = "ship"

  # def initialize fullscreen_height, max_width, max_height, height, config_file_path
  #   @selection = self.class::SELECTION
  #   # puts "INNITING #{config_file_path}"
  #   @font = Gosu::Font.new(20)
  #   # @x = width
  #   @y = height
  #   @max_width = max_width
  #   @max_height = max_height
  #   @next_x = 15
  #   @prev_x = @max_width - 15 - @font.text_width('>')
  #   @config_file_path = config_file_path
  #   @name = self.class::NAME
  #   @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
  #   @fullscreen_height = fullscreen_height
  # end

  def get_values
    # puts "GETTING DIFFICULTY: #{@value}"
    if @value
      @value
    end
  end

  def get_image
    return eval("#{@value}.get_broadside_image")
  end

  def draw
    @font.draw("<", @next_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)

    image = get_image
    image.draw((@max_width / 2) - image.width / 2, y + image.height / 2, 1)
    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)
    @font.draw(">", @prev_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
  end

end