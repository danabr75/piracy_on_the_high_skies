require_relative 'setting.rb'
# require_relative "config_settings.rb"

class DifficultySetting < Setting
  DIFFICULTIES = ["easy", "medium", "hard"]
  attr_accessor :x, :y, :font, :max_width, :max_height


  def initialize max_width, max_height, height, config_file_path
    # puts "INNITING #{config_file_path}"
    @font = Gosu::Font.new(20)
    # @x = width
    @y = height
    @max_width = max_width
    @max_height = max_height
    @next_x = 15
    @prev_x = @max_width - 15 - @font.text_width('>')
    @config_file_path = config_file_path
    @name = 'difficulty'
    @value = ConfigSetting.get_setting(@config_file_path, @name, DIFFICULTIES[0])
  end

  def get_difficulty
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
    if is_mouse_hovering_next(mx, my)
      puts "NEXT!!"
      index = DIFFICULTIES.index(@value)
      value = @value
      if index == 0
        value = DIFFICULTIES[DIFFICULTIES.count - 1]
      else
        value = DIFFICULTIES[index - 1]
      end
      ConfigSetting.set_setting(@config_file_path, @name, value)
      @value = value
    elsif is_mouse_hovering_prev(mx, my)
      puts "PREVV!!!!"
      index = DIFFICULTIES.index(@value)
      value = @value
      if index == DIFFICULTIES.count - 1
        value = DIFFICULTIES[0]
      else
        value = DIFFICULTIES[index + 1]
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