require_relative 'launcher.rb'

class Engine < Launcher
  ABSTRACT_CLASS = true
  HARDPOINT_NAME = "replace_me"  
  PROJECTILE_CLASS   = nil 
  FIRING_GROUP_NUMBER = nil # Passive

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