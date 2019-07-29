require_relative 'engine_hardpoint.rb'

module HardpointObjects
  class BasicRudderEngineHardpoint < HardpointObjects::EngineHardpoint
    ABSTRACT_CLASS = false
    HARDPOINT_NAME = "basic_rudder_engine"
    PROJECTILE_CLASS   = nil 
    FIRING_GROUP_NUMBER = nil # Passive

    PERMANENT_STEAM_USE       = 10.0
    TILES_PER_SECOND_MODIFIER = 1.05
    # TILES_PER_SECOND_MODIFIER = 2.35
    # TILES_PER_SECOND_MODIFIER = 4.0
    ROTATION_MODIFIER         = 1.45

    # Unimplemented
    BOOST_SPEED_MODIFIER  = 1.2
    BOOST_STEAM_USAGE     = 0.4
    BOOST_MASS_MODIFIER   = 1.1

    SHOW_HARDPOINT_BASE = false

    SLOT_TYPE = :engine
    OVERRIDING_HARDPOINT_ANGLE = nil

    def self.get_hardpoint_image
      # raise "OVERRIDE ME"
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end

    # def self.name
    #   "Basic Engine"
    # end

    def self.description
      "It's an Engine, duh."
    end

    def self.value
      30
    end
  end
end