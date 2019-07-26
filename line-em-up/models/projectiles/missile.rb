require_relative 'projectile.rb'

# require 'opengl'
# # require 'glu'
# require 'glut'
module Projectiles
  class Missile < Projectiles::Projectile
    COOLDOWN_DELAY = 3

    STARTING_SPEED = 0.0
    INITIAL_DELAY  = 6
    SPEED_INCREASE_FACTOR    = 1.02
    SPEED_INCREASE_INCREMENT = 0.05
    DAMAGE = 10
    AOE = 0
    MAX_SPEED      = 4

    HEALTH = 2
    
    MAX_CURSOR_FOLLOW = 4
    ADVANCED_HIT_BOX_DETECTION = true

    MAX_TILE_TRAVEL = 6

    BLOCK_PROJ_DRAW = true
    DRAW_CLASS_IMAGE = true
    USING_CLASS_IMAGE_ATTRIBUTES = true


    def get_post_destruction_effects overriding_map_pixel_x = nil, overriding_map_pixel_y = nil
      return [
        Graphics::Explosion.new(
          # point_map_pixel_x, point_map_pixel_y, @width_scale,
          overriding_map_pixel_x || @current_map_pixel_x, overriding_map_pixel_y || @current_map_pixel_y, @width_scale,
          @height_scale, @screen_pixel_width, @screen_pixel_height, @fps_scaler
          # {
          #   green: 35, blue: 13, decay_rate_multiplier: 15.0, shift_blue: true, shift_green: true,
          #   scale_multiplier: 0.25, scale_init_boost: 0.3
          # }
        )
      ]
    end

    def get_post_collided_effects overriding_map_pixel_x = nil, overriding_map_pixel_y = nil
      return [
        Graphics::Smoke.new(
          overriding_map_pixel_x || @current_map_pixel_x, overriding_map_pixel_y || @current_map_pixel_y, @width_scale,
          @height_scale, @screen_pixel_width, @screen_pixel_height, @fps_scaler,
          {
            green: 35, blue: 13, decay_rate_multiplier: 15.0, shift_blue: true, shift_green: true,
            scale_multiplier: 0.25, scale_init_boost: 0.3
          }
        )
      ]
    end

    def self.get_image
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile.png")
    end
    
    def self.get_init_sound
      Gosu::Sample.new("#{SOUND_DIRECTORY}/bullet.ogg")
    end

    def self.get_init_sound_path
      "#{SOUND_DIRECTORY}/bullet.ogg"
    end

    
  end
end