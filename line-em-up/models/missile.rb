require_relative 'projectile.rb'

require 'opengl'
# require 'glu'
# require 'glut'

class Missile < Projectile
  COOLDOWN_DELAY = 3
  MAX_SPEED      = 1

  STARTING_SPEED = 0.0
  INITIAL_DELAY  = 3
  SPEED_INCREASE_FACTOR = 0.002
  DAMAGE = 10
  AOE = 0
  MAX_SPEED      = 10
  
  MAX_CURSOR_FOLLOW = 4
  ADVANCED_HIT_BOX_DETECTION = true

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile.png")
  end

  def drops
    [
      # Add back in once SE has been updated to display on map, not on screen.
      # SmallExplosion.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y, nil, {ttl: 2, third_scale: true}),
    ]
  end

  
  def update mouse_x, mouse_y, player
    # puts "MISSILE: #{@health}"
    return super(mouse_x, mouse_y, player)
  end


end