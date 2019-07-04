require_relative 'projectile.rb'
require 'gosu'
# # require 'opengl'
# # require 'glu'

# # require 'opengl'
require 'glut'


# include OpenGL
# include GLUT

# For opengl-bindings
# OpenGL.load_lib()

# GLUT.load_lib()


class Bullet < Projectile
  COOLDOWN_DELAY = 2
  MAX_SPEED      = 3
  STARTING_SPEED = 3
  INITIAL_DELAY  = 0.0
  SPEED_INCREASE_FACTOR = 2
  DAMAGE = 1
  AOE = 0
  
  # MAX_CURSOR_FOLLOW = 4
  # ADVANCED_HIT_BOX_DETECTION = true

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
  end

  def self.get_init_sound
    Gosu::Sample.new("#{SOUND_DIRECTORY}/bullet.ogg")
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
