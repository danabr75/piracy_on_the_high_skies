# A simple "Triangle Game" that allows you to move a Roguelike '@' around the
# window (and off of it). This is a working example on MacOS 10.12 as of Dec 16, 2017.
# This combines some of the Ruby2D tutorial code with keypress management
# that actually works.
# 
# Keys: hjkl: movement, q: quit
# 
# To run: ruby triangle-game.rb after installing the Simple2D library and Ruby2D Gem.
#
# Author: Douglas P. Fields, Jr.
# E-mail: symbolics@lisp.engineer
# Site: https://symbolics.lisp.engineer/
# Copyright 2017 Douglas P. Fields, Jr.
# License: The MIT License

# require 'gosu'

# Encoding: UTF-8

# The tutorial game over a landscape rendered with OpenGL.
# Basically shows how arbitrary OpenGL calls can be put into
# the block given to Window#gl, and that Gosu Images can be
# used as textures using the gl_tex_info call.

# require 'rubygems'
require 'gosu'

# CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
# MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"
# VENDOR_DIRECTORY   = File.expand_path('../', __FILE__) + "/../vendors"


# ONLY ENABLE FOR WINDOWS COMPILATION
# Place opengl lib in lib library
# Replace the meths list iteration with the following (added rescue blocks):
  # meths.each do |mn|
  #   define_singleton_method(mn) do |*args,&block|
  #     begin
  #       implementation.send(mn, *args, &block)
  #     rescue
  #     end
  #   end
  #   define_method(mn) do |*args,&block|
  #     begin
  #       implementation.send(mn, *args, &block)
  #     rescue
  #     end
  #   end
  #   private mn
  # end
# For WINDOWS - using local lip
# require_relative 'lib/opengl.rb'
# FOR Linux\OSX - using opengl gem
# # require 'opengl'

require_relative "lib/global_constants.rb"
include GlobalConstants
Dir["#{LIB_DIRECTORY  }/*.rb"].each { |f| require f }
Dir["#{MODEL_DIRECTORY}/*.rb"].each { |f| require f }
Dir["#{VENDOR_LIB_DIRECTORY}/*.rb"].each { |f| require f }
# Sub folders as well.
Dir["#{LIB_DIRECTORY  }/**/*.rb"].each { |f| require f }
Dir["#{MODEL_DIRECTORY}/**/*.rb"].each { |f| require f }
Dir["#{VENDOR_LIB_DIRECTORY}/**/*.rb"].each { |f| require f }

class GameWindow < Gosu::Window

  RESOLUTIONS = [[640, 480], [800, 600], [960, 720], [1024, 768], [1280, 960], [1400, 1050], [1440, 1080], [1600, 1200], [1856, 1392], [1920, 1440], [2048, 1536]]
  DEFAULT_WIDTH, DEFAULT_HEIGHT = 640, 480

  attr_accessor :block_all_controls, :add_messages

  def initialize options = {}
    @messages = []
    @add_messages = []
    @block_all_controls = options[:block_all_controls] || false


    @config_path = self.class::CONFIG_FILE

    @current_save_path = self.class::CURRENT_SAVE_FILE

    @backup_save_path  = self.class::BACKUP_SAVE_FILE

    
    init_current_save_file if !File.file?(@current_save_path)

    value = ConfigSetting.get_setting(@config_path, 'resolution', ResolutionSetting::SELECTION[0])
    # puts "VALUE: #{value}"
    if value == 'fullscreen'
      @width  = Gosu::screen_width
      @height = Gosu::screen_height
      fullscreen = true
    else
      raise "DID NOT GET A RESOLUTION FROM CONFIG" if value.nil?
      width, height = value.split('x')
      # puts "WIDTH and height; #{width}  - #{height}"
      @width, @height = [width.to_i, height.to_i]
      fullscreen = false
    end

    default_width, default_height = ResolutionSetting::SELECTION[0].split('x')

    # Need to just pull from config file.. and then do scaling.
    # index = GameWindow.find_index_of_current_resolution(self.width, self.height)
    if @width == default_width && @height == @default_height
      @width_scale = 1.0
      @height_scale = 1.0
      @average_scale = 1.0
      @resolution_scale = 1.0
    else
      @width_scale =  @width / default_width.to_f
      @height_scale = @height / default_height.to_f
      @average_scale = (@width_scale + @height_scale) / 2.0

      @resolution_scale = @width.to_f / (@height.to_f)
    end
    puts "Loading in projectile pre_load_setup"
    Projectiles::Projectile.descendants.each{|d| d.pre_load_setup(@height_scale) if d.respond_to?(:pre_load_setup)}

    @default_fps_interval = 16.666666
    fps_value = ConfigSetting.get_setting(@config_path, "Frames Per Second", FpsSetting::SELECTION[-1])
    @target_fps_interval = FpsSetting.get_interval_value(fps_value)

    @fps_scaler = (@target_fps_interval) / (@default_fps_interval)
    super(@width, @height, {update_interval: @target_fps_interval, fullscreen: fullscreen})
    self.caption = "Piracy on the High Skies!"


    graphics_value = ConfigSetting.get_setting(@config_path, "Graphics Setting", GraphicsSetting::SELECTION[0])
    @graphics_setting = GraphicsSetting.get_interval_value(graphics_value)
    @factions = Faction.init_factions(@height_scale)
    GlobalVariables.set_config(@width_scale, @height_scale, @width, @height,
      @fps_scaler, @graphics_setting, @factions, @resolution_scale, false
    )

    # TEST HERE
    GlobalVariables.set_inner_map(
      1, 1,
      1, 1,
      1, 1,
    )


    @inner_map = InnerMap.new(self, nil, @fps_scaler, @resolution_scale, @width_scale, @height_scale, @average_scale, @width, @height)
    @inner_map.disable
    @outer_map = OuterMapObjects::OuterMap.new(self, @width, @height, @height_scale, @current_save_path, @config_path)
    @outer_map.disable
    @in_game_menu = InGameMenu.new(self, @width, @height, @width_scale, @height_scale, @config_path, @current_save_path, @backup_save_path)
    @in_game_menu.enable
    @key_pressed_map = {}
    # @messages << MessageFlash.new("Game Launched")
  end

  def save_game
    puts "save_game here"
    FileUtils.cp(@current_save_path, @backup_save_path)
  end

  def init_current_save_file
    # if !File.file?(save_file_path)
    raw_ship_class = "PilotableShips::Pillbug"
    ship_class     = PilotableShips::Pillbug
      ConfigSetting.set_setting(@current_save_path, "current_ship_index", "0")
      ConfigSetting.set_mapped_setting(@current_save_path, ["player_fleet", "0", "klass"], raw_ship_class)


    preferred_weapon, preferred_engine, preferred_power = Array.new(3) {nil}
    current_engine_count = 0
    if rand(3) == 0
      preferred_weapon = ["HardpointObjects::CannonHardpoint"]
      preferred_engine = ["HardpointObjects::BasicEngineHardpoint", nil]
      preferred_power  = ["HardpointObjects::BasicSteamCoreHardpoint"]
    elsif rand(3) == 0
      preferred_weapon = ["HardpointObjects::BulletHardpoint", "HardpointObjects::DumbMissileHardpoint"]
      preferred_engine = ["HardpointObjects::BasicEngineHardpoint", nil]
      preferred_power  = ["HardpointObjects::BasicSteamCoreHardpoint"]
    else
      preferred_weapon = ["HardpointObjects::BulletHardpoint", "HardpointObjects::MinigunHardpoint"]
      preferred_engine = ["HardpointObjects::BasicEngineHardpoint", nil]
      preferred_power  = ["HardpointObjects::BasicSteamCoreHardpoint"]
    end
    ship_data = {}
    ship_class::HARDPOINT_LOCATIONS.each_with_index do |data, index|
      item = nil
      if data[:slot_type] == :generic
        if rand(2) == 0
          item = preferred_weapon[rand(preferred_weapon.count)]
        else
          item = preferred_engine[rand(preferred_engine.count)]
          current_engine_count += 1 if item
        end
      elsif data[:slot_type] == :offensive
        item = preferred_weapon[rand(preferred_weapon.count)]
      elsif data[:slot_type] == :engine
        if current_engine_count == 0
          item = preferred_engine.reject{|v| v.nil?}.first
          current_engine_count += 1
        else
          item = preferred_engine[rand(preferred_engine.count)]
        end
      elsif data[:slot_type] == :steam_core
        item = preferred_power[rand(preferred_power.count)]
      end
      if item
        ship_data[index.to_s] = item
      end
    end

    ship_data.each do |key, value|
      ConfigSetting.set_mapped_setting(@current_save_path, ["player_fleet", "0", "hardpoint_locations", key], value)
    end
    ConfigSetting.set_setting(@current_save_path, "Credits", "5000000")
  end

  # @current_save_path = self.class::CURRENT_SAVE_FILE
  # @backup_save_path  = self.class::BACKUP_SAVE_FILE
  def delete_current_save_file
    File.delete(@current_save_path) if File.file?(@current_save_path)
  end

  def load_save
    puts "load_game here"
    # GC.start
    delete_current_save_file
    # GC.start
    FileUtils.cp(@backup_save_path, @current_save_path)
    @factions = Faction.init_factions(@height_scale)
    GlobalVariables.set_config(@width_scale, @height_scale, @width, @height,
      @fps_scaler, @graphics_setting, @factions, @resolution_scale, false
    )
    
    @inner_map = InnerMap.new(self, nil, @fps_scaler, @resolution_scale, @width_scale, @height_scale, @average_scale, @width, @height)
    @inner_map.disable
    @outer_map = OuterMapObjects::OuterMap.new(self, @width, @height, @height_scale, @current_save_path, @config_path)
    @outer_map.disable
    @in_game_menu = InGameMenu.new(self, @width, @height, @width_scale, @height_scale, @config_path, @current_save_path, @backup_save_path)
    @in_game_menu.enable



    GC.start
  end

  def start_new
    puts "STArt new"
    # GC.start
    delete_current_save_file
    # GC.start
    init_current_save_file
    @factions = Faction.init_factions(@height_scale)
    GlobalVariables.set_config(@width_scale, @height_scale, @width, @height,
      @fps_scaler, @graphics_setting, @factions, @resolution_scale, false
    )

    @inner_map = InnerMap.new(self, nil, @fps_scaler, @resolution_scale, @width_scale, @height_scale, @average_scale, @width, @height)
    @inner_map.disable
    @outer_map = OuterMapObjects::OuterMap.new(self, @width, @height, @height_scale, @current_save_path, @config_path)
    @outer_map.disable
    @in_game_menu = InGameMenu.new(self, @width, @height, @width_scale, @height_scale, @config_path, @current_save_path, @backup_save_path)
    @in_game_menu.enable

    GC.start
  end

  def activate_inner_map map_name
    puts "ACTIVATING INNER MAP"
    # require 'gosu'
    # GC.start
    @inner_map.load_map(map_name) #= InnerMap.new(self, map_name, @fps_scaler, @resolution_scale, @width_scale, @height_scale, @average_scale, @width, @height)
    # GC.start
    @outer_map.disable
    # GC.start
    @in_game_menu.disable
    # GC.start
    @inner_map.enable
    GC.start
  end

  def activate_outer_map
    puts "ACTIVATING OUTER MAP"
    # GC.start
    @outer_map.enable
    # GC.start
    @in_game_menu.disable
    # GC.start
    @outer_map.enable
    GC.start
  end

  def activate_main_menu
    # @outer_map.disable if @outer_map
    # GC.start
    @outer_map.disable
    # GC.start
    # @inner_map.disable if @inner_map
    @inner_map.disable
    # GC.start
    # GC.starta
    @in_game_menu.enable
    GC.start
  end

  # def key_id_combo_lock_3 id, id2, id3
  #   ids = [id, id2, id3]
  #   # return false if ids.include?(nil)
  #   master_id = ids.reject{|v| v.nil?}.join('-')
  #   if @key_pressed_map.key?(master_id)
  #     return false
  #   else
  #     @key_pressed_map[master_id] = true
  #     ids.each do |local_id|
  #       @key_pressed_map[local_id] = {id: master_id}
  #     end
  #     return true
  #   end
  # end

  def key_id_lock id
    if @key_pressed_map.key?(id)
      return false
    else
      @key_pressed_map[id] = true
      return true
    end
  end

  def key_id_release id
    value = @key_pressed_map.delete(id)
    # if value.is_a?(Hash)
    #   @key_pressed_map.delete(value[:id])
  end

  # def menus_active
  #   @menus.collect{|menu| menu.active }.include?(true)
  # end

  # def menus_disable
  #   @menus.each{|menu| menu.disable }
  # end




  def self.start options = {}
    GameWindow.new(options).show
  end

# When fullscreen, try to match window with screen resolution
# .screen_height ⇒ Integer
# The height (in pixels) of the user's primary screen.
# .screen_width ⇒ Integer
# The width (in pixels) of the user's primary screen.

  def self.fullscreen(window)
    window.fullscreen = !window.fullscreen?
  end

  def self.resize(window, width, height, fullscreen)
    window = GameWindow.new(width, height).show
    window.fullscreen = fullscreen
  end

  # def self.find_index_of_current_resolution width, height
  #   current_index = nil
  #   counter = 0
  #   RESOLUTIONS.each do |resolution|
  #     break if current_index && current_index > 0
  #     current_index = counter if resolution[0] == width && resolution[1] == height
  #     counter += 1
  #   end
  #   return current_index
  # end

  # def self.up_resolution(window)
  #   # # puts "UP RESLUTION"
  #   # index = find_index_of_current_resolution(window.width, window.height)
  #   # # puts "FOUND INDEX: #{index}"
  #   # if index == RESOLUTIONS.count - 1
  #   #   # Max resolution, do nothing
  #   # else
  #   #   # window.width = RESOLUTIONS[index + 1][0]
  #   #   # window.height = RESOLUTIONS[index + 1][1]
  #   #   width = RESOLUTIONS[index + 1][0]
  #   #   height = RESOLUTIONS[index + 1][1]
  #   #   # puts "UPPING TO #{width} x #{height}"
  #   #   window = GameWindow.new(width, height, {block_resize: true}).show
  #   # end
  # end

  # def self.down_resolution(window)
  #   # index = find_index_of_current_resolution(window.width, window.height)
  #   # if index == 0
  #   #   # Min resolution, do nothing
  #   # else
  #   #   # window.width = RESOLUTIONS[index - 1][0]
  #   #   # window.height = RESOLUTIONS[index - 1][1]
  #   #   width = RESOLUTIONS[index - 1][0]
  #   #   height = RESOLUTIONS[index - 1][1]
  #   #   window = GameWindow.new(width, height, {block_resize: true}).show
  #   # end
  # end

  def button_up id
    @inner_map.button_up(id)      if @inner_map && @inner_map.active
    @inner_map.key_id_release(id) if @inner_map && @inner_map.active

    @outer_map.button_up(id)      if @outer_map && @outer_map.active
    @outer_map.key_id_release(id) if @outer_map && @outer_map.active

    # if id == Gosu::KB_MINUS
    #   # @can_resize = true
    # end
    # if id == Gosu::KB_EQUALS
    #   # @can_resize = true
    # end
    # if id == Gosu::MS_RIGHT
    #   @player.deactivate_group_3
    # end
    # if id == Gosu::MS_LEFT
    #   @player.deactivate_group_2
    # end
    # if id == Gosu::KB_SPACE
    #   @player.deactivate_group_1
    # end

    # if id == Gosu::KB_LEFT_SHIFT
    #   @player.disable_boost
    # end
    key_id_release(id)
    @block_all_controls = false
  end

  def get_center_font_ui_y
    return_value = @center_ui_y
    @center_ui_y += 10 * @average_scale
    return return_value
  end

  def get_center_font_ui_x
    return @center_ui_x
  end

  def update
    @add_messages.reject! {|m| @messages << m; true }
    @messages.reject! { |message| !message.update(mouse_x, mouse_y, nil, nil) }
    # puts "@outer_map && @outer_map.active: #{@outer_map && @outer_map.active}"
    # puts "@in_game_menu: #{@in_game_menu.active}"
    if !@block_all_controls
      if @inner_map && @inner_map.active
        # puts "UPDATING INNER MAP"
        exiting_map = @inner_map.update(self.mouse_x, self.mouse_y)
        if exiting_map
          # puts "EXITING MAP HERE"
          @inner_map.disable
          @outer_map.enable
        end

      elsif @outer_map && @outer_map.active
        # puts "OUTER MAP UPDATE"
        map_name = @outer_map.update(self.mouse_x, self.mouse_y)
        if map_name
          @outer_map.post_activated_inner_map
          activate_inner_map(map_name)
        end
      elsif @in_game_menu.active
        in_game_activating_outer_map = @in_game_menu.update(self.mouse_x, self.mouse_y)
        if in_game_activating_outer_map
          @in_game_menu.disable
          activate_outer_map
        end
      end
    end
  end

  def draw
    @messages.each_with_index do |message, index|
      message.draw(index)
    end
    if @inner_map && @inner_map.active
      # puts "DRAWING INNER MAP"
      @inner_map.draw
    elsif @outer_map && @outer_map.active
      # puts "OUTER MAP DRAW"
      @outer_map.draw
    elsif @in_game_menu.active
      @in_game_menu.draw
    end
  end

  def get_font_ui_y
    return_value = @ui_y
    @ui_y += 15 
    return return_value
  end
  def reset_font_ui_y
    @ui_y = 10
  end
end

GameWindow.new.show if __FILE__ == $0
