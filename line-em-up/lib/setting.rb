require_relative "config_setting.rb"

class Setting
  SELECTION = []
  NAME = "OverrideMe"

  attr_accessor :x, :y, :font, :max_width, :max_height, :selection, :value, :window
  def initialize window, fullscreen_height, max_width, max_height, current_height, config_file_path
    @window = window
    @selection = self.class::SELECTION
    # puts "INNITING #{config_file_path}"
    @font = Gosu::Font.new(20)
    # @x = width
    @y = current_height
    @max_width = max_width
    @max_height = max_height
    @next_x = 15
    @prev_x = @max_width - 15 - @font.text_width('>')
    @config_file_path = config_file_path
    @name = self.class::NAME
    @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
    @fullscreen_height = fullscreen_height
    @button_id_mapping = self.class.get_id_button_mapping
  end

  def self.get_id_button_mapping
    {
      next: lambda { |setting| setting.next_clicked }
    }
  end

  def get_values
    # puts "GETTING DIFFICULTY: #{@value}"
    if @value
      @value
    end
  end

  def draw
    @font.draw("<", @next_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)
    @font.draw(">", @prev_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
  end

  def update mouse_x, mouse_y
    return @value
  end

  # required for LUIT objects, passes id of element
  def onClick element_id
    puts "ONCLICK mappuing"
    puts @button_id_mapping
    button_clicked_exists = @button_id_mapping.key?(element_id)
    if button_clicked_exists
      @button_id_mapping[element_id].call(self)
    else
      puts "Clicked button that is not mapped: #{element_id}"
    end
  end

  def previous_clicked
    index = @selection.index(@value)
    value = @value
    if index == 0
      value = @selection[@selection.count - 1]
    else
      value = @selection[index - 1]
    end
    ConfigSetting.set_setting(@config_file_path, @name, value)
    @value = value
  end

  def next_clicked
    index = @selection.index(@value)
    value = @value
    if index == @selection.count - 1
      value = @selection[0]
    else
      value = @selection[index + 1]
    end
    ConfigSetting.set_setting(@config_file_path, @name, value)
    @value = value
  end

  # Deprecating, using Liut
  def clicked mx, my
    if is_mouse_hovering_next(mx, my)
      previous_clicked
    elsif is_mouse_hovering_prev(mx, my)
      next_clicked
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

end