require_relative 'player.rb'
require_relative 'enemy_bullet.rb'
require_relative 'semi_guided_missile.rb'
require_relative 'small_explosion.rb'
require_relative 'star.rb'
require_relative 'general_object.rb'

class Mite < GeneralObject
  SPEED = 25
  MAX_ATTACK_SPEED = 0.8
  POINT_VALUE_BASE = 5
  # MISSILE_LAUNCHER_MIN_ANGLE = 255
  # MISSILE_LAUNCHER_MAX_ANGLE = 285
  # MISSILE_LAUNCHER_INIT_ANGLE = 270
  attr_accessor :cooldown_wait, :attack_speed, :health, :armor, :x, :y

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/mite.png")
  end

  def initialize(scale, x, y, screen_width, screen_height, x_direction, options = {})
    # initialize(scale, x, y, screen_width, screen_height, options = {})
    super(scale, x, y, screen_width, screen_height, options)
    @cooldown_wait = 0
    @attack_speed = 1
    @health = 2
    @armor = 0
    @current_speed = self.class.get_max_speed * @scale
    @x_direction = x_direction
  end

  def get_points
    return POINT_VALUE_BASE
  end

  def is_alive
    @health > 0
  end


  def take_damage damage
    @health -= damage
  end

  def attack player
    return {
      projectiles: [
        SemiGuidedMissile.new(@scale, @screen_width, @screen_height, self, player)
      ],
      cooldown: SemiGuidedMissile::COOLDOWN_DELAY * MAX_ATTACK_SPEED
    }
  end


  def drops
    value = [SmallExplosion.new(@scale, @screen_width, @screen_height, @x, @y, nil, {third_scale: true})]
    value << Star.new(@scale, @screen_width, @screen_height, @x, @y) if rand(2) == 0
    return value
  end

  def get_draw_ordering
    ZOrder::Enemy
  end

  def update mouse_x = nil, mouse_y = nil, player = nil
    @cooldown_wait -= 1 if @cooldown_wait > 0
    if is_alive
      @x = @x + (@current_speed * @x_direction)

      if @x_direction > 0
        @x < @screen_width
      else
        @x > 0
      end
    else
      false
    end
  end
end