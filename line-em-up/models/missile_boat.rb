require_relative 'player.rb'
require_relative 'enemy_bullet.rb'
require_relative 'enemy_homing_missile.rb'
require_relative 'small_explosion.rb'
require_relative 'star.rb'

class MissileBoat < Player
  Speed = 5
  MAX_ATTACK_SPEED = 3.0
  POINT_VALUE_BASE = 50
  attr_accessor :cooldown_wait, :attack_speed, :health, :armor, :x, :y

  def initialize(scale, width, height, x = nil, y = nil)
    @scale = scale
    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/starfighterv4.png").first
    # @image = Gosu::Image.new(image, :tileable => true)
    # @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/starfighterv4.png")
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_boat_reverse.png")
    # @beep = Gosu::Sample.new("#{MEDIA_DIRECTORY}/beep.wav")
    @x = x || rand(width)
    @y = y || 0
    @cooldown_wait = 0
    @attack_speed = 0.5
    @health = 10
    @armor = 0
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

  def attack width, height, player
    return {
      projectiles: [EnemyHomingMissile.new(@scale, width, height, self, nil, nil, player)],
      cooldown: EnemyHomingMissile::COOLDOWN_DELAY
    }
  end


  def drops
    [
      SmallExplosion.new(@scale, @x, @y, @image),
      Star.new(@scale, @x, @y)
    ]
  end

  def get_draw_ordering
    ZOrder::Enemy
  end

  # SPEED = 1
  def get_speed
    (rand(5) * @scale).round
  end

  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    # @y += 3
    if is_alive
      # Stay above the player
      if player.is_alive && player.y < @y
          @y -= get_speed
      else
        if rand(2).even?
          @y += get_speed

          @y = height / 2 if @y > height / 2
        else
          @y -= get_speed

          @y = 0 + (get_height / 2) if @y < 0 + (get_height / 2)
        end
      end
      if rand(2).even?
        @x += get_speed
        @x = width if @x > width
      else
        @x -= get_speed
        @x = 0 + (get_width / 2) if @x < 0 + (get_width / 2)
      end

      @y < height + (get_height / 2)
    else
      false
    end
  end
  
end