# pry -r ./irb_requirements.rb
# pry -r ./line-em-up/generators/irb_requirements.rb
# require 'ruby_parser'
# require 'ruby2c'
  # sexp_processor, ruby_parser, ruby2c
require 'rubygems'
require 'gosu'
# require 'opengl'
# require 'glu'
require 'glut'
require 'time'
require 'concurrent'
require 'parallel'
# require 'ashton'
# include OpenGL
# include GLUT
# # include GLU
# OpenGL.load_lib()
# GLUT.load_lib()
# Ashton::ParticleEmitter
# test = Ashton::ParticleEmitter.new(1, 1, 4)

CURRENT_DIRECTORY = File.expand_path('../', __FILE__)

require_relative "../lib/global_constants.rb"
include GlobalConstants
Dir["#{LIB_DIRECTORY}/*.rb"].each { |f| require f }
Dir["#{LIB_DIRECTORY}/**/*.rb"].each { |f| require f }
Dir["#{VENDOR_LIB_DIRECTORY}/*.rb"].each { |f| require f }
Dir["#{VENDOR_LIB_DIRECTORY}/**/*.rb"].each { |f| require f }
include GlobalVariables


Dir["#{MODEL_DIRECTORY}/*.rb"].each { |f| require f }
Dir["#{MODEL_DIRECTORY}/**/*.rb"].each { |f| require f }

Dir["#{GENERATORS_DIRECTORY}/*.rb"].each { |f| require f }


def populate_inventory
  @config_file_path = CONFIG_FILE
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '0'.to_s], 'HardpointObjects::GrapplingHookHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '0'.to_s], 'HardpointObjects::DumbMissileHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '0'.to_s], 'HardpointObjects::DumbMissileHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '1'.to_s], 'HardpointObjects::MinigunHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '1'.to_s], 'HardpointObjects::MinigunHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '1'.to_s], 'HardpointObjects::MinigunHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '0'.to_s, '2'.to_s], 'HardpointObjects::BulletHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '1'.to_s, '2'.to_s], 'HardpointObjects::BulletHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '2'.to_s, '2'.to_s], 'HardpointObjects::BulletHardpoint')
  ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', '3'.to_s, '0'.to_s], 'HardpointObjects::GrapplingHookHardpoint')
  return true
end



@tile_pixel_width  = 450 / GLBackground::VISIBLE_MAP_TILE_WIDTH.to_f

@tile_pixel_height = 450 / GLBackground::VISIBLE_MAP_TILE_HEIGHT.to_f

@map_tile_width =  250
@map_tile_height = 250

@map_pixel_width  = (@map_tile_width  * @tile_pixel_width ).to_i
@map_pixel_height = (@map_tile_height * @tile_pixel_height).to_i

GlobalVariables.set_inner_map(
  1, 1,
  1, 1,
  1, 1,
)

GlobalVariables.set_config(1, 1, 450, 450, 16.666, :basic, Faction.init_factions, 1, true)








