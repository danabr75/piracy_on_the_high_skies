require_relative 'engine_hardpoint.rb'

module HardpointObjects
  class BasicEngineHardpoint < HardpointObjects::EngineHardpoint
    ABSTRACT_CLASS = false
    HARDPOINT_NAME = "basic_engine"
    PROJECTILE_CLASS   = nil 
    FIRING_GROUP_NUMBER = nil # Passive

    PERMANENT_STEAM_USE       = 25.0
    TILES_PER_SECOND_MODIFIER = 1.25
    # TILES_PER_SECOND_MODIFIER = 2.35
    # TILES_PER_SECOND_MODIFIER = 4.0
    ROTATION_MODIFIER         = 1.1

    # Unimplemented
    BOOST_SPEED_MODIFIER  = 1.2
    BOOST_STEAM_USAGE     = 0.4
    BOOST_MASS_MODIFIER   = 1.1

    SHOW_HARDPOINT_BASE = false

    SLOT_TYPE = :engine

    def self.get_hardpoint_image
      # raise "OVERRIDE ME"
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end

    def self.name
      "Basic Engine"
    end

    def self.description
      "It's an Engine, duh."
    end

    def self.value
      30
    end
  end
end