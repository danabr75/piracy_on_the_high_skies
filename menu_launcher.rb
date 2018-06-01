require 'gosu'

CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"
CONFIG_FILE = "#{CURRENT_DIRECTORY}/config.txt"

Dir["#{CURRENT_DIRECTORY}/line-em-up/lib/*.rb"].each { |f| require f }
# Shouldn't need models
# Does need the GL BACKGROUND Model
require "#{CURRENT_DIRECTORY}/line-em-up/models/gl_background.rb"
# Dir["#{CURRENT_DIRECTORY}/line-em-up/models/*.rb"].each { |f| require f }

require "#{CURRENT_DIRECTORY}/line-em-up/game_window.rb"

# @menu = Menu.new(self) #instantiate the menu, passing the Window in the constructor

# @menu.add_item(Gosu::Image.new("#{MEDIA_DIRECTORY}question.png"), 100, 200, 1, lambda { self.close }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}question.png", false))
# @menu.add_item(Gosu::Image.new("#{MEDIA_DIRECTORY}question.png"), 100, 250, 1, lambda { puts "something" }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}question.png", false))


class Main < Gosu::Window
  def initialize
    @width, @height = ResolutionSetting::RESOLUTIONS[0].split('x').collect{|s| s.to_i}
    super(@width, @height, false)
    @cursor = Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/cursor.png", false)
    @gl_background = GLBackground.new
    # x = self.width / 2 - 100
    # y = self.height  / 2 - 100
    @center_ui_y = 0
    @center_ui_x = 0
    reset_center_font_ui_y
    lineHeight = 50
    @font = Gosu::Font.new(20)
    self.caption = "A menu with Gosu"
    # items = Array["exit", "additem", "item"]
    # actions = Array[lambda { self.close }, lambda {
    #   @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/item.png", false), x, y, 1, lambda { })
    #   y += lineHeight
    # }, lambda {}]
    @menu = Menu.new(self)
    # for i in (0..items.size - 1)
    #   @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/#{items[i]}.png", false), x, y, 1, actions[i], Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/#{items[i]}_hover.png", false))
    #   y += lineHeight
    # end
    exit_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/exit.png")
    # puts "WIDTH HERE: #{exit_image.width}"
    # 8
    @menu.add_item(exit_image, ((@width / 2) - (exit_image.width / 2)), get_center_font_ui_y, 1, lambda { self.close }, exit_image)
    window_height = Gosu.screen_height
    @resolution_menu = ResolutionSetting.new(window_height, @width, @height, get_center_font_ui_y, CONFIG_FILE)

    @difficulty = nil
    @difficulty_menu = DifficultySetting.new(@width, @height, get_center_font_ui_y, CONFIG_FILE)

    start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/start.png")
    @game_window_width, @game_window_height, @full_screen = [nil, nil, nil]
    @menu.add_item(start_image, (@width / 2) - (start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, difficulty: @difficulty}) }, start_image)
    debug_start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/debug_start.png")
    @menu.add_item(debug_start_image, (@width / 2) - (debug_start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty}) }, debug_start_image)
    # @font.draw("<", width + 15, get_center_font_ui_y, 1, 1.0, 1.0, 0xff_ffff00)
    # @font.draw("Resolution", width / 2, get_center_font_ui_y, 1, 1.0, 1.0, 0xff_ffff00)
    # @font.draw(">", width - 15, get_center_font_ui_y, 1, 1.0, 1.0, 0xff_ffff00)
    # @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/start.png", false), get_center_font_ui_x, get_center_font_ui_y, 1, lambda { self.close; GameWindow.start(nil, nil, {block_controls_until_button_up: true}) }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/start.png", false))
  end

  def dynamic_get_resolution_fs
    @fullscreen
  end

  def update
    @menu.update
    @resolution_menu.update(self.mouse_x, self.mouse_y)
    @difficulty_menu.update(self.mouse_x, self.mouse_y)
    
    @game_window_width, @game_window_height, @fullscreen = @resolution_menu.get_resolution
    @difficulty = @difficulty_menu.get_difficulty
    @gl_background.scroll
  end

  def draw
    @cursor.draw(self.mouse_x, self.mouse_y, 2)
    # @back.draw(0,0,0)
    reset_center_font_ui_y
    @menu.draw
    @resolution_menu.draw
    @difficulty_menu.draw
    @gl_background.draw(ZOrder::Background)
  end

  def button_down id
    if id == Gosu::MsLeft then
      @menu.clicked
      @resolution_menu.clicked(self.mouse_x, self.mouse_y)
      @difficulty_menu.clicked(self.mouse_x, self.mouse_y)
    end
  end

  def get_center_font_ui_y
    return_value = @center_ui_y
    @center_ui_y += 50 
    return return_value
  end

  def get_center_font_ui_x
    return @center_ui_x
  end

  def reset_center_font_ui_y
    @center_ui_y = self.height  / 2 - 100
    @center_ui_x = self.width / 2 - 100
  end
end

Main.new.show
