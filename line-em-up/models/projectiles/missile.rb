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
    MAX_SPEED      = 5

    HEALTH = 2
    
    MAX_CURSOR_FOLLOW = 4
    ADVANCED_HIT_BOX_DETECTION = true

    MAX_TILE_TRAVEL = 6

    POST_DESTRUCTION_EFFECTS = true
    POST_COLLISION_EFFECTS   = true

    # def self.get_post_destruction_effects # Give parameters
    #   # raise 'stop here'
    #   return [
    #     Graphics::Explosion.new(
    #       @current_map_pixel_x, @current_map_pixel_y, @width_scale,
    #       @height_scale, @screen_pixel_width, @screen_pixel_height, @fps_scaler,
    #       {
    #         green: 35, blue: 13, decay_rate_multiplier: 15.0, shift_blue: true, shift_green: true,
    #         scale_multiplier: 0.25, scale_init_boost: 0.3
    #       }
    #     )
    #   ]
    # end

    def get_post_destruction_effects overriding_map_pixel_x = nil, overriding_map_pixel_y = nil
      # raise 'stop here'
      # radius = @image_height_half
      # angle_correction = 5

      # # puts "ANGLE HERE: #{@angle}"
      # step = (Math::PI/180 * (360 -  @angle + 90 + angle_correction)) + 90.0 + 45.0
      # point_map_pixel_x = Math.cos(step) * radius + @current_map_pixel_x
      # point_map_pixel_y = Math.sin(step) * radius + @current_map_pixel_y
      # test1 = @current_map_pixel_x + (@current_map_pixel_x - point_map_pixel_x)
      # test2 = @current_map_pixel_y + (@current_map_pixel_y - point_map_pixel_y)

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

    # def get_image
    #   Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile.png")
    # end

    def drops
      [
        # Add back in once SE has been updated to display on map, not on screen.
        # SmallExplosion.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y, nil, {ttl: 2, third_scale: true}),
      ]
    end

    
    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
      # puts "MISSILE: #{@health}"
      return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
    end


  end
end