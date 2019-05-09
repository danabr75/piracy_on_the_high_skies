require_relative "config_setting.rb"

class Setting
  SELECTION = []
  NAME = "OverrideMe"

  attr_accessor :x, :y, :font, :max_width, :max_height, :selection
  def initialize fullscreen_height, max_width, max_height, height, config_file_path
    @selection = self.class::SELECTION
    # puts "INNITING #{config_file_path}"
    @font = Gosu::Font.new(20)
    # @x = width
    @y = height
    @max_width = max_width
    @max_height = max_height
    @next_x = 15
    @prev_x = @max_width - 15 - @font.text_width('>')
    @config_file_path = config_file_path
    @name = self.class::NAME
    @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
    @fullscreen_height = fullscreen_height
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
  end

  def clicked mx, my
    puts "CLICKED!!!!"
    if is_mouse_hovering_next(mx, my)
      puts "NEXT!!"
      puts "Value: #{@value}"
      puts "@selection: #{@selection}"
      index = @selection.index(@value)
      puts "INDEX: #{index}"
      value = @value
      if index == 0
        value = @selection[@selection.count - 1]
      else
        value = @selection[index - 1]
      end
      ConfigSetting.set_setting(@config_file_path, @name, value)
      @value = value
    elsif is_mouse_hovering_prev(mx, my)
      puts "NEXT!!"
      puts "Value: #{@value}"
      puts "@selection: #{@selection}"
      index = @selection.index(@value)
      puts "INDEX: #{index}"
      value = @value
      if index == @selection.count - 1
        value = @selection[0]
      else
        puts "INDEX: #{index}"
        puts "@selection[index + 1]: #{@selection[index + 1]}"
        value = @selection[index + 1]
      end
      ConfigSetting.set_setting(@config_file_path, @name, value)
      @value = value
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