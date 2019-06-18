require_relative 'launcher.rb'
require_relative 'bullet.rb'
class GrapplingHookLauncher < Launcher
  HARDPOINT_NAME = "grappling_hook_launcher"
  LAUNCHER_MIN_ANGLE = -60
  LAUNCHER_MAX_ANGLE = 60
  PROJECTILE_CLASS = GrapplingHook
  FIRING_GROUP_NUMBER = 3
  COOLDOWN_DELAY = 240
  ACTIVE_PROJECTILE_LIMIT = 1

  def initialize(options = {})
    @hp_reference = options[:hp_reference]
    @image_hardpoint_empty = Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
    super(options)
  end

  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
  end


  def draw angle, x, y, z
    if @cooldown_wait <= 0.0 && (self.class::ACTIVE_PROJECTILE_LIMIT.nil? || @projectiles.count < self.class::ACTIVE_PROJECTILE_LIMIT)
      @image_hardpoint.draw_rot(x, y, z, angle, 0.5, 0.5, @width_scale, @height_scale)
    else
      @image_hardpoint_empty.draw_rot(x, y, z, angle, 0.5, 0.5, @width_scale, @height_scale)
    end
  end


  def self.name
    "Grappling Hook Launcher"
  end

  def self.description
    "This is a grappling hook. Allows boarding enemy ships."
  end

end