require_relative 'player.rb'
require_relative 'enemy_bullet.rb'
require_relative 'enemy_homing_missile.rb'
require_relative 'small_explosion.rb'
require_relative 'star.rb'

class MissileBoat < GeneralObject
  SPEED = 5
  MAX_ATTACK_SPEED = 3.0
  POINT_VALUE_BASE = 50
  attr_accessor :cooldown_wait, :attack_speed, :health, :armor, :x, :y

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_boat_reverse.png")
  end

  def initialize(scale, screen_width, screen_height, x = nil, y = nil, options = {})
    super(scale, x || rand(screen_width), y || 0, screen_width, screen_height, options)
    @cooldown_wait = 0
    @attack_speed = 0.5
    @health = 10
    @armor = 0
    @current_speed = (rand(5) * @scale).round + 1
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
      projectiles: [EnemyHomingMissile.new(@scale, @screen_width, @screen_height, self, player)],
      cooldown: EnemyHomingMissile::COOLDOWN_DELAY
    }
  end


  def drops
    [
      SmallExplosion.new(@scale, @screen_width, @screen_height, @x, @y, @image),
      Star.new(@scale, @screen_width, @screen_height, @x, @y)
    ]
  end

  def get_draw_ordering
    ZOrder::Enemy
  end

  # SPEED = 1
  # def get_speed
    
  # end

  def update mouse_x = nil, mouse_y = nil, player = nil
    @cooldown_wait -= 1 if @cooldown_wait > 0
    if is_alive
      # Stay above the player
      if player.is_alive && player.y < @y
          @y -= @current_speed
      else
        if rand(2).even?
          @y += @current_speed

          @y = @screen_height / 2 if @y > @screen_height / 2
        else
          @y -= @current_speed

          @y = 0 + (get_height / 2) if @y < 0 + (get_height / 2)
        end
      end
      if rand(2).even?
        @x += @current_speed
        @x = @screen_width if @x > @screen_width
      else
        @x -= @current_speed
        @x = 0 + (get_width / 2) if @x < 0 + (get_width / 2)
      end

      @y < @screen_height + (get_height / 2)
    else
      false
    end
  end
  
end