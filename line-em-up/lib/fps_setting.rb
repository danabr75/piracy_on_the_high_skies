require_relative 'setting.rb'
# require_relative "config_settings.rb"

class FpsSetting < Setting
  NAME = "Frames Per Second"
  # SELECTION = ["FPS 20", "FPS 30", "FPS 40", "FPS 50", "FPS 60", "FPS 70", "FPS 144"]
  SELECTION = ["FPS 20", "FPS 30", "FPS 40", "FPS 50", "FPS 60"]

  def self.get_interval_value fps_value
    target_fps_interval = nil
    if fps_value == "FPS 20"
      target_fps_interval  = 49.999998
    elsif fps_value == "FPS 30"
      target_fps_interval  = 33.333332
    elsif fps_value == "FPS 40"
      target_fps_interval  = 24.999999
    elsif fps_value == "FPS 50"
      target_fps_interval  = 19.999999199999998
    elsif fps_value == "FPS 60"
      target_fps_interval = 16.666666
    # elsif fps_value == "FPS 70"
    #   target_fps_interval = 14.285713714285713
    # elsif fps_value == "FPS 144"
    #   target_fps_interval = 0.6944444166666666
    end

    return target_fps_interval
  end


end