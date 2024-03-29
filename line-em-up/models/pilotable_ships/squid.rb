require_relative '../general_object.rb'
# require_relative 'rocket_launcher_pickup.rb'
require_relative 'pilotable_ship.rb'
require 'gosu'

# # require 'opengl'
require 'glut'


# include OpenGL
# include GLUT
module PilotableShips
  class Scout < PilotableShips::PilotableShip
    ABSTRACT_CLASS = false
    STORE_RARITY = 1 # lower is more frequent. Higher is more rare.. I think..
    ITEM_MEDIA_DIRECTORY = "#{MEDIA_DIRECTORY}/pilotable_ships/squid"
    # SPEED = 7
    # MAX_ATTACK_SPEED = 3.0
    attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :rockets, :score, :time_alive

    attr_accessor :bombs, :secondary_weapon, :grapple_hook_cooldown_wait, :damage_reduction, :kill_count
    attr_accessor :special_attack, :main_weapon, :drawable_items_near_self, :front_hard_points, :broadside_hard_points
    # MAX_HEALTH = 200


    # New stuff, older stuff above
    attr_reader :mass, :speed
    # MAss isn't mass
    MASS  = 100.0
    MOMENTUM_RATE = 0.4
    # NOT LITERALY TPS
    TILES_PER_SECOND = 0.35
    ROTATION_SPEED = 0.7
    # HEALTH = 100
    HEALTH = 400

    ALLOWED_ARMOR_TYPES = [:light_armor]


    HARDPOINT_LOCATIONS = [
      {
        angle_offset: 0,
        slot_type: :offensive, 
        x_offset: lambda { |image, scale| 0 },  y_offset: lambda { |image, scale| -((image.height * scale) / 2.5) },
      },
    # ]
    # # LEFT SIDE
    # PORT_HARDPOINT_LOCATIONS = [
      # Bottom One - CONFIRMED
      # Middle One
      {
        angle_offset: 90,
        slot_type: :offensive, 
        x_offset: lambda { |image, scale| ((image.width * scale) / 2.5)}, y_offset: lambda { |image, scale| 0 } 
      },
      # Top One
      {
        angle_offset: 90,
        slot_type: :offensive, 
        x_offset: lambda { |image, scale| ((image.width * scale) / 3.1)}, y_offset: lambda { |image, scale| -((image.height * scale) / 4.0) }
      },
      # {y_offset: lambda { |image| 0 } , x_offset: lambda { |image| 0 } }
    # ]
    # # RIGHT SIDE
    # STARBOARD_HARDPOINT_LOCATIONS = [
      # TOP One - confirmed
      {
        angle_offset: -90,
        slot_type: :offensive, 
        x_offset: lambda { |image, scale| -((image.width * scale) / 3.1)}, y_offset: lambda { |image, scale| -(image.height * scale) / 4.0 }   
      },
      # Middle One
      {
        angle_offset: -90,
        slot_type: :offensive, 
        x_offset: lambda { |image, scale| -((image.width * scale) / 2.5)}, y_offset: lambda { |image, scale| 0 } 
      },
      # bottom One
      {
        angle_offset: -90, # Not sure if this offest is necessary for the engine - Yes! To calculate image rotation
        slot_type: :engine, 
        x_offset: lambda { |image, scale| -((image.width * scale) / 1.8)}, y_offset: lambda { |image, scale| ((image.height * scale) / 10.0) }
      },
      {
        angle_offset: 90, # Not sure if this offest is necessary for the engine - Yes! To calculate image rotation
        slot_type: :engine, 
        x_offset: lambda { |image, scale| ((image.width * scale) / 1.8)}, y_offset: lambda { |image, scale| ((image.height * scale) / 10.0) }
      },
      {
        angle_offset: -90, # Not sure if this offest is necessary for the engine - Yes! To calculate image rotation
        slot_type: :engine, 
        x_offset: lambda { |image, scale| -((image.width * scale) / 1.8)}, y_offset: lambda { |image, scale| -((image.height * scale) / 10.0) }
      },
      {
        angle_offset: 90, # Not sure if this offest is necessary for the engine - Yes! To calculate image rotation
        slot_type: :engine, 
        x_offset: lambda { |image, scale| ((image.width * scale) / 1.8)}, y_offset: lambda { |image, scale| -((image.height * scale) / 10.0) }
      },
      {
        angle_offset: 0, # Not sure if this offest is necessary for the engine - Yes! To calculate image rotation
        slot_type: :steam_core, 
        x_offset: lambda { |image, scale| 0}, y_offset: lambda { |image, scale| -(66 * scale) }
      },
      {
        angle_offset: 0, # Not sure if this offest is necessary for the engine - Yes! To calculate image rotation
        slot_type: :armor, 
        x_offset: lambda { |image, scale| 0}, y_offset: lambda { |image, scale| (66 * scale) }
      }
      # {y_offset: lambda { |image| 0 } , x_offset: lambda { |image| 0 } }
    ]


    # def self.display_name
    #   "Bumble Bee"
    # end

    def self.get_hardpoint_image
      "BasicShip1: OVERRIDE ME"
      Gosu::Image.new("#{ITEM_MEDIA_DIRECTORY}/icon.png")
    end

    def self.description
      "A General Purpose Airship. Good on speed and health."
    end

    def self.value
      5000
    end

    # Rocket Launcher, Rocket launcher, yannon, Cannon, Bomb Launcher
    # FRONT_HARD_POINTS_MAX = 1
    # BROADSIDE_HARD_POINTS = 3
  end
end
