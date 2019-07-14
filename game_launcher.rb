# Use Game launcher to get valid stack traces

require_relative 'line-em-up/lib/global_constants.rb'

include GlobalConstants


require "#{APP_DIRECTORY}/line-em-up/game_window.rb"

GameWindow.start()