require 'gosu'

current_directory = File.expand_path('../', __FILE__)
MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/line-em-up/media"
config_file = "#{current_directory}/config.txt"
vendor_directory   = File.expand_path('../', __FILE__) + "/vendors"
require "#{vendor_directory}/lib/luit.rb"


Dir["#{current_directory}/line-em-up/lib/*.rb"].each { |f| require f }
# Shouldn't need models
# Does need the GL BACKGROUND Model
require "#{current_directory}/line-em-up/models/gl_background.rb"
# Dir["#{CURRENT_DIRECTORY}/line-em-up/models/*.rb"].each { |f| require f }

require "#{current_directory}/line-em-up/game_window.rb"
require "#{current_directory}/line-em-up/loadout_window.rb"

# @menu = Menu.new(self) #instantiate the menu, passing the Window in the constructor

# @menu.add_item(Gosu::Image.new("#{MEDIA_DIRECTORY}question.png"), 100, 200, 1, lambda { self.close }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}question.png", false))
# @menu.add_item(Gosu::Image.new("#{MEDIA_DIRECTORY}question.png"), 100, 250, 1, lambda { puts "something" }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}question.png", false))

Main.new(config_file).show
