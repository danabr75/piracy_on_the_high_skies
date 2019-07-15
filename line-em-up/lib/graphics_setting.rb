require_relative 'setting.rb'
# require_relative "config_settings.rb"

class GraphicsSetting < Setting
  SELECTION = ["basic (2D)", "advanced (3D)"]
  NAME = "Graphics Setting"

  def self.get_interval_value value
    return_value = nil
    if value == "basic (2D)"
      return_value  = :basic
    elsif value == "advanced (3D)"
      return_value = :advanced
    end

    return return_value
  end
end