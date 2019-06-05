require_relative 'mite.rb'

class HorizontalSwarm
  # SPEED = 5
  # MAX_ATTACK_SPEED = 3.0
  # POINT_VALUE_BASE = 50
  # MISSILE_LAUNCHER_MIN_ANGLE = 255
  # MISSILE_LAUNCHER_MAX_ANGLE = 285
  # MISSILE_LAUNCHER_INIT_ANGLE = 270
  # attr_accessor :cooldown_wait, :attack_speed, :health, :armor, :x, :y
  # SWARM_COUNT = 10
  SWARM_COUNT = 10

  # def get_image
  #   Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_boat_reverse.png")
  # end

  def self.trigger_swarm(scale, screen_pixel_width, screen_pixel_height, y = nil, options = {})
    # super(scale, x || rand(screen_pixel_width), y || 0, screen_pixel_width, screen_pixel_height, options)
    # @cooldown_wait = 0
    # @attack_speed = 0.5
    # @current_speed = (rand(5) * @scale).round + 1
    swarm = []
    x_padding = 40 * scale
    base_x_padding = 40 * scale
    y_padding = 40 * scale

    y = y || rand(screen_pixel_height / 3) + screen_height / 8

    if rand(2) == 0
      x_direction = 1
    else
      x_direction = -1
    end

    (0..(SWARM_COUNT - 1)).each do |i|
      if i.even?
        new_y = y
      else
        new_y = y - y_padding
      end
      if x_direction > 0
        new_x = 0 - x_padding
      else
        new_x = screen_width + x_padding
      end
      x_padding = x_padding + base_x_padding
      swarm << Mite.new(scale, new_x, new_y, screen_pixel_width, screen_pixel_height, x_direction, options)
    end
    return swarm
  end

  # def get_points
  #   return POINT_VALUE_BASE
  # end


  # def take_damage damage
  #   @health -= damage
  # end

  # def attack player
  #   x_padding_1 = 5 * @scale
  #   x_padding_2 = -(5 * @scale)
  #   return {
  #     projectiles: [
  #       SemiGuidedMissile.new(@scale, @screen_pixel_width, @screen_pixel_height, self, player, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {custom_initial_delay: 2}),
  #       SemiGuidedMissile.new(@scale, @screen_pixel_width, @screen_pixel_height, self, player, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {custom_initial_delay: 12, x_homing_padding: x_padding_1}),
  #       SemiGuidedMissile.new(@scale, @screen_pixel_width, @screen_pixel_height, self, player, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {custom_initial_delay: 18, x_homing_padding: x_padding_2})
  #     ],
  #     cooldown: SemiGuidedMissile::COOLDOWN_DELAY
  #   }
  # end


  # def drops
  #   [
  #     SmallExplosion.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y, @image),
  #     Star.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y)
  #   ]
  # end

  # def get_draw_ordering
  #   ZOrder::Enemy
  # end

  # SPEED = 1
  # def get_speed
    
  # end

  # def update mouse_x = nil, mouse_y = nil, player = nil
  #   @cooldown_wait -= 1 if @cooldown_wait > 0
  #   if is_alive
  #     # Stay above the player
  #     if player.is_alive && player.y < @y
  #         @y -= @current_speed
  #     else
  #       if rand(2).even?
  #         @y += @current_speed

  #         @y = @screen_pixel_height / 2 if @y > @screen_pixel_height / 2
  #       else
  #         @y -= @current_speed

  #         @y = 0 + (get_height / 2) if @y < 0 + (get_height / 2)
  #       end
  #     end
  #     if rand(2).even?
  #       @x += @current_speed
  #       @x = @screen_pixel_width if @x > @screen_pixel_width
  #     else
  #       @x -= @current_speed
  #       @x = 0 + (get_width / 2) if @x < 0 + (get_width / 2)
  #     end

  #     @y < @screen_pixel_height + (get_height / 2)
  #   else
  #     false
  #   end
  # end
  
end