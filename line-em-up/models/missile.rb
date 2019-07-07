require_relative 'projectile.rb'

# require 'opengl'
# # require 'glu'
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

  MAX_TILE_TRAVEL = 6

  POST_DESTRUCTION_EFFECTS = true

  def get_post_destruction_effects
    # raise 'stop here'
    return [
      Graphics::Smoke.new(
        @current_map_pixel_x, @current_map_pixel_y, @width_scale,
        @height_scale, @screen_pixel_width, @screen_pixel_height,
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