# require_relative 'player.rb'
require_relative 'enemy_bullet.rb'
require_relative 'small_explosion.rb'
require_relative 'star.rb'

class EnemyPlayer < GeneralObject
  SPEED = 3
  MAX_ATTACK_SPEED = 3.0
  POINT_VALUE_BASE = 10
  attr_accessor :cooldown_wait, :attack_speed, :health, :armor, :x, :y

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/airship1_color1_reverse.png")
  end

  def initialize scale, screen_width, screen_height, x = nil, y = nil, options = {}
    super(scale, x || rand(screen_width), y || 0, screen_width, screen_height, options)
    @cooldown_wait = 0
    @attack_speed = 0.5
    @health = 15
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
      projectiles: [EnemyBullet.new(@scale, @screen_width, @screen_height, self)],
      cooldown: EnemyBullet::COOLDOWN_DELAY
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

  # def draw
  #   @image.draw(@x - get_width / 2, @y - get_height / 2, ZOrder::Enemy)
  # end

  # SPEED = 1
  def get_speed
    @current_speed
  end

  def update mouse_x = nil, mouse_y = nil, player = nil
    @cooldown_wait -= 1 if @cooldown_wait > 0
    if is_alive
      # Stay above the player
      if player.y < @y
          @y -= get_speed
      else
        if rand(2).even?
          @y += get_speed

          @y = @screen_height / 2 if @y > @screen_height / 2
        else
          @y -= get_speed

          @y = 0 + (get_height / 2) if @y < 0 + (get_height / 2)
        end
      end
      if rand(2).even?
        @x += get_speed
        @x = @screen_width if @x > @screen_width
      else
        @x -= get_speed
        @x = 0 + (get_width / 2) if @x < 0 + (get_width / 2)
      end


      @y < @screen_height + (get_height / 2)
    else
      false
    end
  end
  
end