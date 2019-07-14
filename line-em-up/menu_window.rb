require 'gosu'

require_relative 'lib/global_constants.rb'
require_relative 'lib/resolution_setting.rb'
require_relative 'lib/difficulty_setting.rb'
require_relative 'lib/z_order.rb'
require_relative 'lib/z_order.rb'
require_relative 'models/menu.rb'
require_relative 'game_window.rb'

include GlobalConstants

require "#{VENDOR_LIB_DIRECTORY}/luit.rb"


class MenuWindow < Gosu::Window
  include GlobalConstants
  # CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  # CONFIG_FILE = "#{CONFIG_FILE}/../../config.txt"
  def initialize config_path = nil
    @window = self
    config_path = CONFIG_FILE if config_path.nil?
    # @width, @height = ResolutionSetting::SELECTION[0].split('x').collect{|s| s.to_i}
    @width, @height = [600, 600]
    @height_scale = 1
    super(@width, @height, false)
    @cursor = Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/cursor.png", false)
    @center_ui_y = 0
    @center_ui_x = 0
    reset_center_font_ui_y
    # lineHeight = 50   * @height_scale
    @font_height = 20 * @height_scale
    @font = Gosu::Font.new(@font_height)
    self.caption = "Piracy on the High Skies Launcher"
    # items = Array["exit", "additem", "item"]
    # actions = Array[lambda { self.close }, lambda {
    #   @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/item.png", false), x, y, 1, lambda { })
    #   y += lineHeight
    # }, lambda {}]
    # @menu = Menu.new(self)
    @menu = Menu.new(@window, @width / 2, 0, ZOrder::UI, @height_scale)
    @menu.add_item(
      :resume, "Play Piracy on the High Skies!",
      0, 0,
      lambda {|window, menu, id| self.close; GameWindow.start(); },
      nil,
      {is_button: true}
    )
    @menu.add_item(
      :exit, "Exit",
      0, 0,
      lambda {|window, menu, id| window.close; },
      nil,
      {is_button: true}
    )

    @center_ui_y += @menu.current_height


    window_height = Gosu.screen_height
    @resolution_menu = ResolutionSetting.new(@window, window_height, @width, @height, get_center_font_ui_y, config_path)

    @difficulty = nil
    @difficulty_menu = DifficultySetting.new(@window, window_height, @width, @height, get_center_font_ui_y, config_path)

    @fps_menu = FpsSetting.new(@window, window_height, @width, @height, get_center_font_ui_y, config_path)

    @menu.enable
    @font_texts = [
      "Controls:",
      "ESC: Show Menu",
      "W: accelerate",
      "D: Rotate Clockwise",
      "A: Rotate CounterClockwise",
      "S: Brake",
      "X: Reverse",
      "M: Hide Minimap",
      "Spacebar: Group 0 Offensives (pending)",
      "Mouse Left-click: Group 1 Offensives (Common Projectiles, Missiles, etc)",
      "Mouse Right-click: Group 2 Offensives (Utilities, Grappling Hooks)",
      "P: Pause"
    ]
  end

  def onClick element_id
    if @menu.active
      @menu.onClick(element_id)
    end
  end

  def dynamic_get_resolution_fs
    @fullscreen
  end

  def update
    @menu.update
    @resolution_menu.update(self.mouse_x, self.mouse_y)
    @difficulty_menu.update(self.mouse_x, self.mouse_y)
    @fps_menu.update(self.mouse_x, self.mouse_y)

    @game_window_width, @game_window_height, @fullscreen = @resolution_menu.get_values
    @difficulty = @difficulty_menu.get_values
    # @gl_background.scroll
  end

  def draw
    @cursor.draw(self.mouse_x, self.mouse_y, 2)
    # @back.draw(0,0,0)
    reset_center_font_ui_y
    @menu.draw
    @center_ui_y += @menu.current_height
    @resolution_menu.draw
    get_center_font_ui_y
    @difficulty_menu.draw
    get_center_font_ui_y
    @fps_menu.draw
    get_center_font_ui_y
    
    # text = "Controls:"
    # @font.draw(text, @width / 2 - @font.text_width(text) / 2, get_center_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    @font_texts.each do |text|
      @font.draw(text, @width / 2  - @font.text_width(text) / 2, get_center_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
    # @gl_background.draw(ZOrder::Background)
  end

  def button_down id
    if id == Gosu::MsLeft
      # @menu.clicked
      @resolution_menu.clicked(self.mouse_x, self.mouse_y)
      @difficulty_menu.clicked(self.mouse_x, self.mouse_y)
      @fps_menu.clicked(self.mouse_x, self.mouse_y)
    end
  end

  def get_center_font_ui_y
    return_value = @center_ui_y
    @center_ui_y += @font_height 
    return return_value
  end

  def get_center_font_ui_x
    return @center_ui_x
  end

  def reset_center_font_ui_y
    @center_ui_y = -(self.height  / 2) + self.height  / 1.5
    @center_ui_x = self.width / 2
  end

  def self.start options = {}
    MenuWindow.new().show
  end
end