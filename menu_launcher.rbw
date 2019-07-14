require_relative 'line-em-up/lib/global_constants.rb'

include GlobalConstants


require "#{APP_DIRECTORY}/line-em-up/menu_window.rb"

MenuWindow.start()