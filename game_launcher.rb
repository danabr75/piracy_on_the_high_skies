# Use Game launcher to get valid stack traces

require 'gosu'

require_relative 'line-em-up/lib/global_constants.rb'

include GlobalConstants

# CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
# MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/line-em-up/media"
# MODEL_DIRECTORY   = File.expand_path('../', __FILE__) + "/line-em-up/models"
# CONFIG_FILE = "#{APP_DIRECTORY}/config.txt"

# Dir["#{LIB_DIRECTORY}/*.rb"].each { |f| require f }
# Dir["#{LIB_DIRECTORY}/*.rb"].each { |f| require f }
# # Shouldn't need models
# # Does need the GL BACKGROUND Model
# require "#{CURRENT_DIRECTORY}/line-em-up/models/gl_background.rb"
# Dir["#{CURRENT_DIRECTORY}/line-em-up/models/*.rb"].each { |f| require f }

require "#{APP_DIRECTORY}/line-em-up/game_window.rb"

# @menu = Menu.new(self) #instantiate the menu, passing the Window in the constructor

# @menu.add_item(Gosu::Image.new("#{MEDIA_DIRECTORY}question.png"), 100, 200, 1, lambda { self.close }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}question.png", false))
# @menu.add_item(Gosu::Image.new("#{MEDIA_DIRECTORY}question.png"), 100, 250, 1, lambda { puts "something" }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}question.png", false))

# Main.new(CONFIG_FILE).show

GameWindow.start()