require_relative 'general_object.rb'
require_relative 'rocket_launcher_pickup.rb'
require_relative 'pilotable_ship.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

class MiteShip < PilotableShip
  SHIP_MEDIA_DIRECTORY = "#{MEDIA_DIRECTORY}/pilotable_ships/mite_ship"
  SPEED = 8
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive

  attr_accessor :bombs, :secondary_weapon, :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
  attr_accessor :special_attack, :main_weapon, :drawable_items_near_self, :broadside_mode, :front_hard_points, :broadside_hard_points
  MAX_HEALTH = 100

  # SECONDARY_WEAPONS = [RocketLauncherPickup::NAME] + %w[bomb]
  # Range goes clockwise around the 0-360 angle
  # MISSILE_LAUNCHER_MIN_ANGLE = 75
  # MISSILE_LAUNCHER_MAX_ANGLE = 105
  # MISSILE_LAUNCHER_INIT_ANGLE = 90

  # SPECIAL_POWER = 'laser'
  # SPECIAL_POWER_KILL_MAX = 50

  # FRONT_HARDPOINT_LOCATIONS = [{x_offset: 0, y_offset: -get_image.height}]
  # BROADSIDE_HARDPOINT_LOCATIONS = [{x_offset: get_image.width / 2, y_offset: -(get_image.height * 0.9)}, {x_offset: get_image.width, y_offset: -(get_image.height * 0.8)}, {x_offset: -(get_image.width / 2), y_offset: -(get_image.height * 0.8)}]
  FRONT_HARDPOINT_LOCATIONS = [{x_offset: lambda { |image| 0 }, y_offset: lambda { |image| -(image.height / 2) } }]
  BROADSIDE_HARDPOINT_LOCATIONS = [
    {x_offset: lambda { |image| image.width / 2 },     y_offset: lambda { |image| -(image.height / 2)} },
    {x_offset: lambda { |image| -(image.width / 2) } , y_offset: lambda { |image| -(image.height / 2)} }
  ]


  # Rocket Launcher, Rocket launcher, yannon, Cannon, Bomb Launcher
  # FRONT_HARD_POINTS_MAX = 1
  # BROADSIDE_HARD_POINTS = 2

  # def self.get_broadside_image
  #   Gosu::Image.new("#{MEDIA_DIRECTORY}/mite.png")
  # end

  # def self.get_image
  #   Gosu::Image.new("#{MEDIA_DIRECTORY}/mite.png")
  # end

  
  # def get_image_path
  #   "#{MEDIA_DIRECTORY}/spaceship.png"
  # end



end