# UNUSED CURRENTLY
class Main < Gosu::Window
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  CONFIG_FILE = "#{CURRENT_DIRECTORY}/../../config.txt"
  require "#{CURRENT_DIRECTORY}/../game_window.rb"
  # require "#{CURRENT_DIRECTORY}/../loadout_window.rb"

  # block_controls_until_button_up: true
  attr_accessor :block_all_controls, :config_path
  def initialize config_path = nil, options = {}
    @block_all_controls = !options[:block_controls_until_button_up].nil? && options[:block_controls_until_button_up] == true ? true : false
    puts "MAIN HERE: block? #{@block_all_controls}"
    @config_file_path = config_path
    @config_file_path = CONFIG_FILE if config_path.nil?
    puts "MAIN CONFIG INITL: #{@config_file_path} - #{config_path} - #{CONFIG_FILE}"


    # @width, @height = ResolutionSetting::SELECTION[0].split('x').collect{|s| s.to_i}
    value = ConfigSetting.get_setting(@config_file_path, 'resolution', ResolutionSetting::SELECTION[0])
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
    @resolution_menu = ResolutionSetting.new(@window, window_height, @width, @height, get_center_font_ui_y, @config_file_path)

    @difficulty = nil
    @difficulty_menu = DifficultySetting.new(@window, window_height, @width, @height, get_center_font_ui_y, @config_file_path)
    @menu = Menu.new(self, @width / 2, get_center_font_ui_y, ZOrder::UI, @scale)
    # Just move everything else above the menu
    # increase_center_font_ui_y(@menu.current_height)

    # start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/start.png")
    # @game_window_width, @game_window_height, @full_screen = [nil, nil, nil]
    # @menu.add_item(start_image, (@width / 2) - (start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, difficulty: @difficulty}) }, start_image)

    button_key = :start_game
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, ZOrder::UI, "Start", 0, 1),
      0,
      0,
      lambda {|window, id|
        if !@block_all_controls
          self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, difficulty: @difficulty})
        end
      },
      # lambda {|window, id| self.close },
      nil,
      {is_button: true, key: button_key}
    )




    # loadout_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/loadout.png")
    # @menu.add_item(loadout_image, (@width / 2) - (loadout_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; LoadoutWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true}) }, loadout_image)
    button_key = :loadout
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, ZOrder::UI, "Loadout", 0, 1),
      0,
      0,
      lambda {|window, id|
        if !@block_all_controls
          self.close; LoadoutWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true})
        end
      },
      nil,
      {is_button: true, key: button_key}
    )

    # debug_start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/debug_start.png")
    # @menu.add_item(debug_start_image, (@width / 2) - (debug_start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty}) }, debug_start_image)

    # button_key = :debug_start
    # @menu.add_item(
    #   LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, "Debug Start", 0, 1),
    #   0,
    #   0,
    #   lambda {|window, id|
    #     if !@block_all_controls
    #       self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty})
    #     end
    #   },
    #   nil,
    #   {is_button: true, key: button_key}
    # )
    button_key = :debug_start # too lazy to rename
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, ZOrder::UI, "Populate Inventory", 0, 1),
      0,
      0,
      lambda {|window, id|
        if !@block_all_controls
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '0'.to_s], 'DumbMissileLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '0'.to_s], 'DumbMissileLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '0'.to_s], 'DumbMissileLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '1'.to_s], 'LaserLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '1'.to_s], 'LaserLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '1'.to_s], 'LaserLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '2'.to_s], 'BulletLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '2'.to_s], 'BulletLauncher')
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '2'.to_s], 'BulletLauncher')
        end
      },
      nil,
      {is_button: true, key: button_key}
    )

    button_key = :exit
    @menu.add_item(
      LUIT::Button.new(@menu.local_window, button_key, @menu.x, @menu.y + @menu.current_height, ZOrder::UI, "Exit", 0, 1),
      0,
      0,
      lambda {|window, id|
        puts "WINDOW: #{window.class}"
        puts "SELF blcok?: #{self.block_all_controls}"
        puts "EXIT BUTTON: @block_all_controls: #{@block_all_controls}"
        if !@block_all_controls
          self.close
        end
      },
      nil,
      {is_button: true, key: button_key}
    )

    @movement_x, @movement_y = [0.0, 0.0]


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
    # @movement_x += 0.0
    @movement_y += 1.0
    @movement_x, @movement_y = @gl_background.scroll(1, @movement_x, @movement_y)
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

  def button_up id
    @block_all_controls = false
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