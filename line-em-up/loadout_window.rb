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

CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"

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
# require 'opengl'


# require_relative 'media'
# Dir["/path/to/directory/*.rb"].each {|file| require file }
# 
# exit if Object.const_defined?(:Ocra) #allow ocra to create an exe without executing the entire script



# RESOLUTIONS = [[640, 480], [800, 600], [960, 720], [1024, 768]]
# WIDTH, HEIGHT = 1080, 720

class LoadoutWindow < Gosu::Window
  attr_accessor :width, :height, :block_all_controls
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

  def initialize width = nil, height = nil, fullscreen = false, options = {}
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
    @menu = Menu.new(self)
    # for i in (0..items.size - 1)
    #   @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/#{items[i]}.png", false), x, y, 1, actions[i], Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/#{items[i]}_hover.png", false))
    #   y += lineHeight
    # end
    exit_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/exit.png")
    # puts "WIDTH HERE: #{exit_image.width}"
    # 8
    # @menu.add_item(exit_image, ((@width / 2) - (exit_image.width / 2)), get_center_font_ui_y, 1, lambda { self.close }, exit_image)
    window_height = Gosu.screen_height
    @resolution_menu = ResolutionSetting.new(window_height, @width, @height, get_center_font_ui_y, config_path)

    @difficulty = nil
    # @difficulty_menu = DifficultySetting.new(@width, @height, get_center_font_ui_y, config_path)

    # start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/start.png")
    @game_window_width, @game_window_height, @full_screen = [nil, nil, nil]
    @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/back_to_menu.png", false), get_center_font_ui_x, get_center_font_ui_y, ZOrder::UI, lambda { self.close; Main.new.show }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/back_to_menu.png", false))

    # @menu.add_item(start_image, (@width / 2) - (start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, difficulty: @difficulty}) }, start_image)
    # loadout_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/menu/loadout.png")
    # @menu.add_item(loadout_image, (@width / 2) - (loadout_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; LoadoutWindow.start() }, loadout_image)
    # debug_start_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/debug_start.png")
    # @menu.add_item(debug_start_image, (@width / 2) - (debug_start_image.width / 2), get_center_font_ui_y, 1, lambda {self.close; GameWindow.start(@game_window_width, @game_window_height, dynamic_get_resolution_fs, {block_controls_until_button_up: true, debug: true, difficulty: @difficulty}) }, debug_start_image)
  end

  def dynamic_get_resolution_fs
    @fullscreen
  end

  def update
    @menu.update
    # @resolution_menu.update(self.mouse_x, self.mouse_y)
    # @difficulty_menu.update(self.mouse_x, self.mouse_y)
    
    # @game_window_width, @game_window_height, @fullscreen = @resolution_menu.get_resolution
    # @difficulty = @difficulty_menu.get_difficulty
    @gl_background.scroll
  end

  def draw
    @cursor.draw(self.mouse_x, self.mouse_y, 2)
    # @back.draw(0,0,0)
    reset_center_font_ui_y
    @menu.draw
    # @resolution_menu.draw
    # @difficulty_menu.draw
    @gl_background.draw(ZOrder::Background)
  end

  def button_down id
    if id == Gosu::MsLeft then
      @menu.clicked
      # @resolution_menu.clicked(self.mouse_x, self.mouse_y)
      # @difficulty_menu.clicked(self.mouse_x, self.mouse_y)
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