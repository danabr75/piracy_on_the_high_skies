require_relative 'setting.rb'
# require_relative "config_settings.rb"

class ResolutionSetting < Setting
  FULLSCREEN_NAME = "fullscreen"
  NAME = "resolution"
  SELECTION = ["480x480", "640x480", "800x600", "960x720", "1024x768", "1280x960", "1400x1050", "1440x1080", "1600x1200", "1856x1392", "1920x1440", "2048x1536", FULLSCREEN_NAME]
  # attr_accessor :x, :y, :font, :max_width, :max_height
  def get_values
    if @value == FULLSCREEN_NAME
      height = @fullscreen_height
      width = (@fullscreen_height / 3) * 4
      [width, height, true]
    elsif @value
      @value.split('x').collect{|s| s.to_i }
    end
  end


end