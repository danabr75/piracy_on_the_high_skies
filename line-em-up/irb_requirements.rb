# pry -r ./irb_requirements.rb

require 'rubygems'
require 'gosu'
require 'opengl'
require 'glu'
require 'glut'
# require 'ashton'
include OpenGL
include GLUT
# include GLU
# OpenGL.load_lib()
# GLUT.load_lib()
# Ashton::ParticleEmitter
# test = Ashton::ParticleEmitter.new(1, 1, 4)

CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"
VENDOR_DIRECTORY   = File.expand_path('../', __FILE__) + "/../vendors/"
CONFIG_FILE = "#{CURRENT_DIRECTORY}/../config.txt"

# include OpenGL
# include GLUT
# OpenGL.load_lib()
# GLUT.load_lib()

# CURRENT_DIRECTORY = File.expand_path('../', __FILE__)

Dir["#{CURRENT_DIRECTORY}/models/*.rb"].each { |f| require f }
Dir["#{CURRENT_DIRECTORY}/lib/*.rb"].each { |f| require f }
Dir["#{VENDOR_DIRECTORY}/lib/*.rb"].each { |f| require f }


def populate_inventory
  @config_file_path = CONFIG_FILE
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '0'.to_s], 'DumbMissileLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '0'.to_s], 'DumbMissileLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '0'.to_s], 'DumbMissileLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '1'.to_s], 'LaserLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '1'.to_s], 'LaserLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '1'.to_s], 'LaserLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '2'.to_s], 'BulletLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '2'.to_s], 'BulletLauncher')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '2'.to_s], 'BulletLauncher')
  return true
end