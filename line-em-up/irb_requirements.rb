# irb -r ./irb_requirements.rb

require 'rubygems'
require 'gosu'
require 'gl'
CURRENT_DIRECTORY = File.expand_path('../', __FILE__)

Dir["#{CURRENT_DIRECTORY}/models/*.rb"].each { |f| require f }
Dir["#{CURRENT_DIRECTORY}/lib/*.rb"].each { |f| require f }

