require_relative 'hardpoint_object'

module HardpointObjects
  class ArmorHardpoint < HardpointObjects::HardpointObject
    ABSTRACT_CLASS = true
    HARDPOINT_NAME = "replace_me"  
    PROJECTILE_CLASS   = nil 
    FIRING_GROUP_NUMBER = nil # Passive

    PERMANENT_STEAM_USE       = nil
    TILES_PER_SECOND_MODIFIER = nil
    ROTATION_MODIFIER         = nil

    SHOW_HARDPOINT = false

    SHOW_HARDPOINT_BASE = false

    SLOT_TYPE = :armor

    def self.get_hardpoint_image
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

