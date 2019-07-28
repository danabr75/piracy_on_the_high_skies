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

module Projectiles
  class Bullet < Projectiles::Projectile
    # COOLDOWN_DELAY = 2
    MAX_SPEED      = 3
    STARTING_SPEED = 3
    INITIAL_DELAY  = 0.0
    SPEED_INCREASE_FACTOR = 2
    DAMAGE = 1
    AOE = 0

    IMAGE_SCALER = 4.0

    BLOCK_IMAGE_DRAW = true
    DRAW_CLASS_IMAGE = true
    USING_CLASS_IMAGE_ATTRIBUTES = true

    def self.get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
    end

    def self.get_init_sound
      Gosu::Sample.new("#{SOUND_DIRECTORY}/bullet.ogg")
    end

    def self.get_init_sound_path
      "#{SOUND_DIRECTORY}/bullet.ogg"
    end

  end
end
