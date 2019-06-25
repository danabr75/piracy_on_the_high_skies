require_relative 'hardpoint_object'

module HardpointObjects
  class EngineHardpoint < HardpointObjects::HardpointObject
    ABSTRACT_CLASS = true
    HARDPOINT_NAME = "replace_me"  
    PROJECTILE_CLASS   = nil 
    FIRING_GROUP_NUMBER = nil # Passive

    ACCELERATION   = nil
    ROTATION_BOOST = nil
    MASS_BOOST     = nil

    PERMANENT_STEAM_USE   = nil
    STEAM_USAGE_INCREMENT = nil
    BOOST_SPEED_MODIFIER  = nil
    BOOST_STEAM_USAGE     = nil


    def self.get_hardpoint_image
      raise "OVERRIDE ME"
      # Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end

    def self.name
      raise "OVERRIDE ME"
    end

    def self.description
      raise "OVERRIDE ME"
    end

    def self.value
      raise "OVERRIDE ME"
    end
  end
end