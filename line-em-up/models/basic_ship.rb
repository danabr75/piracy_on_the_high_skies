require_relative 'general_object.rb'
require_relative 'rocket_launcher_pickup.rb'
require_relative 'pilotable_ship.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

class BasicShip < PilotableShip
  SHIP_MEDIA_DIRECTORY = "#{MEDIA_DIRECTORY}/pilotable_ships/basic_ship"
  SPEED = 7
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive

  attr_accessor :bombs, :secondary_weapon, :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
  attr_accessor :special_attack, :main_weapon, :drawable_items_near_self, :broadside_mode, :front_hard_points, :broadside_hard_points
  MAX_HEALTH = 200

  # SECONDARY_WEAPONS = [RocketLauncherPickup::NAME] + %w[bomb]
  # Range goes clockwise around the 0-360 angle
  # MISSILE_LAUNCHER_MIN_ANGLE = 75
  # MISSILE_LAUNCHER_MAX_ANGLE = 105
  # MISSILE_LAUNCHER_INIT_ANGLE = 90

  # SPECIAL_POWER = 'laser'
  # SPECIAL_POWER_KILL_MAX = 50

  # FRONT_HARDPOINT_LOCATIONS = [{x_offset: 0, y_offset: -get_image.height}]
  # BROADSIDE_HARDPOINT_LOCATIONS = [{x_offset: get_image.width / 2, y_offset: -(get_image.height * 0.9)}, {x_offset: get_image.width, y_offset: -(get_image.height * 0.8)}, {x_offset: -(get_image.width / 2), y_offset: -(get_image.height * 0.8)}]
  # FRONT_HARDPOINT_LOCATIONS = [
  #   {
  #     when_frontside: {x_offset: lambda { |image| 0 }, y_offset: lambda { |image| -(image.height / 2) } },
  #     when_broadside: {y_offset: lambda { |image| 0 }, x_offset: lambda { |image| -(image.height / 2) } }
  #   }
  # ]
  # BROADSIDE_HARDPOINT_LOCATIONS = [
  #   {
  #     when_broadside: {x_offset: lambda { |image| image.width / 2 },     y_offset: lambda { |image| -(image.height / 2)} },
  #     when_frontside: {y_offset: lambda { |image| image.width / 2 },     x_offset: lambda { |image| -(image.height / 2)} }
  #   },
  #   {
  #     when_broadside: {x_offset: lambda { |image| image.width },         y_offset: lambda { |image| -(image.height / 2)} },
  #     when_frontside: {y_offset: lambda { |image| image.width },         x_offset: lambda { |image| -(image.height / 2)} }
  #   },
  #   {
  #     when_broadside: {x_offset: lambda { |image| -(image.width / 2) } , y_offset: lambda { |image| -(image.height / 2)} },
  #     when_frontside: {y_offset: lambda { |image| -(image.width / 2) } , x_offset: lambda { |image| -(image.height / 2)} }
  #   }
  # ]
  FRONT_HARDPOINT_LOCATIONS = [
    {
      x_offset: lambda { |image, scale| 0 }, y_offset: lambda { |image, scale| -((image.height * scale) / 2) }
    }
  ]
  BROADSIDE_HARDPOINT_LOCATIONS = [
    {
      y_offset: lambda { |image, scale| (image.width * scale) / 2 },     x_offset: lambda { |image, scale| ((image.height * scale) / 2)}
    },
    {
      y_offset: lambda { |image, scale| (image.width * scale) },         x_offset: lambda { |image, scale| ((image.height * scale) / 2)}
    },
    {y_offset: lambda { |image, scale| -((image.width * scale) / 2) } , x_offset: lambda { |image, scale| ((image.height * scale) / 2)} }
    # {y_offset: lambda { |image| 0 } , x_offset: lambda { |image| 0 } }
  ]


  # Rocket Launcher, Rocket launcher, yannon, Cannon, Bomb Launcher
  FRONT_HARD_POINTS_MAX = 1
  BROADSIDE_HARD_POINTS = 3

  # def self.get_broadside_image
  #   Gosu::Image.new("#{SHIP_MEDIA_DIRECTORY}/broadside.png")
  # end

  # def self.get_image
  #   Gosu::Image.new("#{SHIP_MEDIA_DIRECTORY}/default.png")
  # end

  # def self.get_right_image
  #   Gosu::Image.new("#{SHIP_MEDIA_DIRECTORY}/right.png")
  # end
  
  # def self.get_left_image
  #   Gosu::Image.new("#{SHIP_MEDIA_DIRECTORY}/left.png")
  # end
  # def get_image_path
  #   "#{SHIP_MEDIA_DIRECTORY}/default.png"
  # end



end