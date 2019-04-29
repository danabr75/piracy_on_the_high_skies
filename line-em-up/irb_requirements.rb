# pry -r ./irb_requirements.rb

require 'rubygems'
require 'gosu'
require 'opengl'
require 'glut'

CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"
CONFIG_FILE = "#{CURRENT_DIRECTORY}/../config.txt"

# include OpenGL
# include GLUT
# OpenGL.load_lib()
# GLUT.load_lib()

# CURRENT_DIRECTORY = File.expand_path('../', __FILE__)

Dir["#{CURRENT_DIRECTORY}/models/*.rb"].each { |f| require f }
Dir["#{CURRENT_DIRECTORY}/lib/*.rb"].each { |f| require f }

