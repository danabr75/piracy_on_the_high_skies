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

  FRONT_HARDPOINT_LOCATIONS = [
    {
      slot_type: :generic, 
      x_offset: lambda { |image, scale| ((image.width * scale) / 7) },  y_offset: lambda { |image, scale| -((image.height * scale) / 2.5) },
    },
    {
      slot_type: :generic, 
      x_offset: lambda { |image, scale| -((image.width * scale) / 7) },  y_offset: lambda { |image, scale| -((image.height * scale) / 2.5) },
    }
  ]
  RIGHT_BROADSIDE_HARDPOINT_LOCATIONS = [
    # Bottom One
    {
      slot_type: :offensive, 
      x_offset: lambda { |image, scale| ((image.width * scale) / 5)}, y_offset: lambda { |image, scale| (image.height * scale) / 4 }   
    },
    # Middle One
    {
      slot_type: :offensive, 
      x_offset: lambda { |image, scale| ((image.width * scale) / 4)}, y_offset: lambda { |image, scale| 0 } 
    },
    # Top One
    {
      slot_type: :offensive, 
      x_offset: lambda { |image, scale| ((image.width * scale) / 5)}, y_offset: lambda { |image, scale| -((image.height * scale) / 4) }
    }
    # {y_offset: lambda { |image| 0 } , x_offset: lambda { |image| 0 } }
  ]

  LEFT_BROADSIDE_HARDPOINT_LOCATIONS = [
    # Bottom One
    {
      slot_type: :offensive, 
      x_offset: lambda { |image, scale| -((image.width * scale) / 5)}, y_offset: lambda { |image, scale| -(image.height * scale) / 4 }   
    },
    # Middle One
    {
      slot_type: :offensive, 
      x_offset: lambda { |image, scale| -((image.width * scale) / 4)}, y_offset: lambda { |image, scale| 0 } 
    },
    # Top One
    {
      slot_type: :offensive, 
      x_offset: lambda { |image, scale| -((image.width * scale) / 5)}, y_offset: lambda { |image, scale| ((image.height * scale) / 4) }
    }
    # {y_offset: lambda { |image| 0 } , x_offset: lambda { |image| 0 } }
  ]




  # Rocket Launcher, Rocket launcher, yannon, Cannon, Bomb Launcher
  # FRONT_HARD_POINTS_MAX = 1
  # BROADSIDE_HARD_POINTS = 3
end