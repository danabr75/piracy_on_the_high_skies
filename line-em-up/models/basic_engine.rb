require_relative 'engine.rb'

class BasicEngine < Engine
  ABSTRACT_CLASS = false
  HARDPOINT_NAME = "basic_engine"
  PROJECTILE_CLASS   = nil 
  FIRING_GROUP_NUMBER = nil # Passive

  ACCELERATION   = 1.2
  ROTATION_BOOST = 0.5

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