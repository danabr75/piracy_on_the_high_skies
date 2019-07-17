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
  class Cannon < Projectiles::Projectile
    # COOLDOWN_DELAY = 40
    MAX_SPEED      = 5
    MIN_SPEED      = 0.8
    STARTING_SPEED = 5
    INITIAL_DELAY  = nil
    # SPEED_INCREASE_INCREMENT = -0.5
    SPEED_INCREASE_FACTOR    = 0.9

    MAX_TILE_TRAVEL = 1.2
    DAMAGE = 20
    AOE = 0

    IMAGE_SCALER = 4.0
    
    # MAX_CURSOR_FOLLOW = 4
    # ADVANCED_HIT_BOX_DETECTION = true

    # POST_DESTRUCTION_EFFECTS = true
    # def get_post_destruction_effects overriding_map_pixel_x = nil, overriding_map_pixel_y = nil
    #   return [
    #     Graphics::SmallExplosion.new(
    #       # point_map_pixel_x, point_map_pixel_y, @width_scale,
    #       overriding_map_pixel_x || @current_map_pixel_x, overriding_map_pixel_y || @current_map_pixel_y, @width_scale,
    #       @height_scale, @screen_pixel_width, @screen_pixel_height, @fps_scaler
    #     )
    #   ]
    # end

    def get_damage
      return (self.class::DAMAGE * @damage_increase / MAX_SPEED) * @speed
    end

    def get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/cannon_ball.png")
    end

    def self.get_init_sound
      Gosu::Sample.new("#{SOUND_DIRECTORY}/bullet.ogg")
    end

    def self.get_init_sound_path
      "#{SOUND_DIRECTORY}/bullet.ogg"
    end

    # def drops
    #   [
    #     # Add back in once SE has been updated to display on map, not on screen.
    #     # SmallExplosion.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y, nil, {ttl: 2, third_scale: true}),
    #   ]
    # end

    
    # def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
    #   # puts "MISSILE: #{@health}"
    #   return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
    # end


  end
end
