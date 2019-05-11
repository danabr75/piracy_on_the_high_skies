require 'gosu'
require 'luit'


VENDOR_DIRECTORY   = File.expand_path('../', __FILE__) + "/../vendors"
require "#{VENDOR_DIRECTORY}/lib/luit.rb"
CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"
Dir["#{CURRENT_DIRECTORY}/lib/*.rb"].each { |f| require f }
Dir["#{CURRENT_DIRECTORY}/models/*.rb"].each { |f| require f }
require 'opengl'

class LoadoutWindow < Gosu::Window
  # CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"

  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  puts "TEMP SAVE PATH: #{CURRENT_DIRECTORY}/../save.txt"
  SAVE_FILE = "#{CURRENT_DIRECTORY}/../save.txt"
  CONFIG_FILE = "#{CURRENT_DIRECTORY}/../config.txt"


  def self.start width = nil, height = nil, fullscreen = false, options = {}
    # begin
    # window = GameWindow.new.show
      LoadoutWindow.new(width, height, fullscreen, options).show
    # rescue Exception => e
    #   puts "Exception caught in GameWindow"
    #   puts e.message
    #   puts e.backtrace
    #   raise e
    # end
  end

  attr_accessor :width, :height, :block_all_controls
  # attr_accessor :mouse_x, :mouse_y
  def initialize width = nil, height = nil, fullscreen = false, options = {}
    # @mouse_y = 0
    # @mouse_x = 0
    @window = self
    LUIT.config({window: @window, z: 25})
    config_path = options[:config_path] || CONFIG_FILE
    @width, @height = ResolutionSetting::SELECTION[0].split('x').collect{|s| s.to_i}
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
    @menu = Menu.new(@window)
    # for i in (0..items.size - 1)
    #   @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/#{items[i]}.png", false), x, y, 1, actions[i], Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/#{items[i]}_hover.png", false))
    #   y += lineHeight
    # end
    # exit_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/exit.png")
    # puts "WIDTH HERE: #{exit_image.width}"
    # 8
    # @menu.add_item(exit_image, ((@width / 2) - (exit_image.width / 2)), get_center_font_ui_y, 1, lambda { self.close }, exit_image)
    fullscreen_window_height = Gosu.screen_height
    # @resolution_menu = ResolutionSetting.new(@window, window_height, @width, @height, get_center_font_ui_y, config_path)

    @difficulty = nil
    @ship_menu = ShipSetting.new(@window, fullscreen_window_height, @width, @height, get_center_font_ui_y, config_path)
    @ship_loadout_menu = ShipLoadoutSetting.new(@window, fullscreen_window_height, @width, @height, get_center_font_ui_y, config_path, @ship_menu.value)
    increase_center_font_ui_y(@ship_loadout_menu.get_image.height + @ship_loadout_menu.get_large_image.height)
    # puts "KLASS HERE : #{klass.get_image_assets_path(klass::SHIP_MEDIA_DIRECTORY)}"

    # start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/start.png")
    @game_window_width, @game_window_height, @full_screen = [nil, nil, nil]



    # debug_start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/debug_start.png")
    # @menu.add_item(debug_start_image, (@width / 2) - (debug_start_image.width / 2), get_center_font_ui_y, ZOrder::UI, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty}) }, debug_start_image)

    # Increase y for padding
    # get_center_font_ui_y
    # increase_center_font_ui_y(@ship_menu.get_image.height)

    # back_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/back_to_menu.png")
    # @menu.add_item(back_image, (@width / 2) - (back_image.width / 2), get_center_font_ui_y, ZOrder::UI, lambda { self.close; Main.new.show }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/back_to_menu.png", false))

    # @button_id_mapping = self.class.get_id_button_mapping
    # @menu.add_item(start_image, (@width / 2) - (start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, difficulty: @difficulty}) }, start_image)
    # loadout_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/loadout.png")
    # @menu.add_item(loadout_image, (@width / 2) - (loadout_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; LoadoutWindow.start() }, loadout_image)
    # debug_start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/debug_start.png")
    # @menu.add_item(debug_start_image, (@width / 2) - (debug_start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty}) }, debug_start_image)
    @button_id_mapping = self.class.get_id_button_mapping
    @back_button = LUIT::Button.new(self, :back, (@width / 2), @height, "Back To Menu", 0, 1)
  end

  def dynamic_get_resolution_fs
    @fullscreen
  end

  def update
    @menu.update
    @ship_value = @ship_menu.update(self.mouse_x, self.mouse_y)
    @ship_loadout_menu.update(self.mouse_x, self.mouse_y, @ship_value)


    @back_button.update(-(@back_button.w / 2), -(@back_button.h))

    # @resolution_menu.update(self.mouse_x, self.mouse_y)
    # @difficulty_menu.update(self.mouse_x, self.mouse_y)
    
    # @game_window_width, @game_window_height, @fullscreen = @resolution_menu.get_resolution
    # @difficulty = @difficulty_menu.get_difficulty
    @gl_background.scroll
  end

  def draw
    @cursor.draw(self.mouse_x, self.mouse_y, 100)
    @back_button.draw(-(@back_button.w / 2), -(@back_button.h))
    # @back.draw(0,0,0)
    reset_center_font_ui_y
    @menu.draw
    @ship_menu.draw
    @ship_loadout_menu.draw
    # @resolution_menu.draw
    # @difficulty_menu.draw
    @gl_background.draw(ZOrder::Background)
  end

  def button_down id
    if id == Gosu::MsLeft then
      @menu.clicked
      # @resolution_menu.clicked(self.mouse_x, self.mouse_y)
      @ship_menu.clicked(self.mouse_x, self.mouse_y)
      @ship_loadout_menu.clicked(self.mouse_x, self.mouse_y)
    end
  end

  def increase_center_font_ui_y amount
    @center_ui_y += amount 
  end

  def get_center_font_ui_y
    increase_center_font_ui_y(50)
  end

  def get_center_font_ui_x
    return @center_ui_x
  end

  def reset_center_font_ui_y
    @center_ui_y = -(self.height  / 2) + self.height  / 2
    @center_ui_x = self.width / 2
  end

  def self.get_id_button_mapping
    {
      back: lambda { |window| window.close; Main.new.show }
    }
  end

  # required for LUIT objects, passes id of element
  def onClick element_id
    puts "LOADOUT WINDOW ONCLICK"
    button_clicked_exists = @button_id_mapping.key?(element_id)
    if button_clicked_exists
      @button_id_mapping[element_id].call(self)
    else
      puts "Clicked button that is not mapped: #{element_id}"
    end
  end
end


LoadoutWindow.new.show if __FILE__ == $0