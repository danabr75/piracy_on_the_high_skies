
class Main < Gosu::Window
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  CONFIG_FILE = "#{CURRENT_DIRECTORY}/../../config.txt"
  require "#{CURRENT_DIRECTORY}/../game_window.rb"
  require "#{CURRENT_DIRECTORY}/../loadout_window.rb"


  def initialize config_path = nil
    config_path = CONFIG_FILE if config_path.nil?


    # @width, @height = ResolutionSetting::SELECTION[0].split('x').collect{|s| s.to_i}
    value = ConfigSetting.get_setting(config_path, 'resolution', ResolutionSetting::SELECTION[0])
    raise "DID NOT GET A RESOLUTION FROM CONFIG" if value.nil?
    width, height = value.split('x')
    @width, @height = [width.to_i, height.to_i]

    default_width, default_height = ResolutionSetting::SELECTION[0].split('x')
    # default_width, default_height = default_value.split('x')
    default_width, default_height = [default_width.to_i, default_height.to_i]


    # Need to just pull from config file.. and then do scaling.
    # index = GameWindow.find_index_of_current_resolution(self.width, self.height)
    if @width == default_width && @height == @default_height
      @scale = 1
    else
      # original_width, original_height = RESOLUTIONS[0]
      width_scale = @width / default_width.to_f
      height_scale = @height / default_height.to_f
      @scale = (width_scale + height_scale) / 2
    end


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

    # exit_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/exit.png")


    # @menu.add_item(exit_image, @, @menu.y_offset, 1, lambda { self.close }, exit_image)


    window_height = Gosu.screen_height
    @window = self
    @resolution_menu = ResolutionSetting.new(@window, window_height, @width, @height, get_center_font_ui_y, config_path)

    @difficulty = nil
    @difficulty_menu = DifficultySetting.new(@window, window_height, @width, @height, get_center_font_ui_y, config_path)
    @menu = Menu.new(self, @width / 2, get_center_font_ui_y, ZOrder::UI, @scale)
    # Just move everything else above the menu
    # increase_center_font_ui_y(@menu.current_height)

    # start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/start.png")
    # @game_window_width, @game_window_height, @full_screen = [nil, nil, nil]
    # @menu.add_item(start_image, (@width / 2) - (start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, difficulty: @difficulty}) }, start_image)

    button_key = :start_game
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, "Start", 0, 1),
      0,
      0,
      lambda {|window, id| self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, difficulty: @difficulty}) },
      # lambda {|window, id| self.close },
      nil,
      {is_button: true, key: button_key}
    )




    # loadout_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/loadout.png")
    # @menu.add_item(loadout_image, (@width / 2) - (loadout_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; LoadoutWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true}) }, loadout_image)
    button_key = :loadout
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, "Loadout", 0, 1),
      0,
      0,
      lambda {|window, id| self.close; LoadoutWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true}) },
      nil,
      {is_button: true, key: button_key}
    )

    # debug_start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/debug_start.png")
    # @menu.add_item(debug_start_image, (@width / 2) - (debug_start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty}) }, debug_start_image)

    button_key = :debug_start
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, "Debug Start", 0, 1),
      0,
      0,
      lambda {|window, id| self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty}) },
      nil,
      {is_button: true, key: button_key}
    )
    button_key = :exit
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, "Exit", 0, 1),
      0,
      0,
      lambda {|window, id| self.close },
      nil,
      {is_button: true, key: button_key}
    )




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
    
    @game_window_width, @game_window_height, @fullscreen = @resolution_menu.get_values
    @difficulty = @difficulty_menu.get_values
    @gl_background.scroll
  end

  def draw
    @cursor.draw(self.mouse_x, self.mouse_y, ZOrder::Cursor)
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

  def increase_center_font_ui_y amount
    @center_ui_y += amount 
  end

  def get_center_font_ui_y
    increase_center_font_ui_y(50)
  end


  # def get_center_font_ui_y
  #   return_value = @center_ui_y
  #   @center_ui_y += 50 
  #   return return_value
  # end

  def get_center_font_ui_x
    return @center_ui_x
  end

  def reset_center_font_ui_y
    @center_ui_y = -(self.height  / 2) + self.height  / 1.5
    @center_ui_x = self.width / 2
  end
end