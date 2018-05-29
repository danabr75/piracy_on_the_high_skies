# require_relative 'player.rb'
require_relative 'enemy_bullet.rb'
require_relative 'enemy_homing_missile.rb'
require_relative 'small_explosion.rb'
require_relative 'star.rb'
require_relative 'enemy_bomb.rb'

class Mothership < GeneralObject
  SPEED = 5
  MAX_ATTACK_SPEED = 3.0
  POINT_VALUE_BASE = 1000
  attr_accessor :cooldown_wait, :attack_speed, :health, :armor, :x, :y, :secondary_cooldown_wait, :tertiary_cooldown_wait

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/mothership.png")
  end

  def initialize(scale, screen_width, screen_height, options = {})
    super(scale, screen_width / 2, get_image.height, screen_width, screen_height, options)

    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @tertiary_cooldown_wait = 0
    @attack_speed = 0.5
    @health = 2500
    @armor = 0
    @current_speed = (SPEED * @scale).round + 1
  end

  # def draw
  #   # Will generate error if class name is not listed on ZOrder
  #   @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)
  #   # @image.draw(@xΩ - @image.width / 2, @y - @image.height / 2, get_draw_ordering)
  # end

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
        EnemyBullet.new(@scale, @screen_width, @screen_height, self, {side: 'left',  relative_object: self }),
        EnemyBullet.new(@scale, @screen_width, @screen_height, self, {side: 'right', relative_object: self }),
        EnemyBullet.new(@scale, @screen_width, @screen_height, self)
      ],
      cooldown: EnemyBullet::COOLDOWN_DELAY
    }
  end

  def secondary_attack player
    return {
      projectiles: [
        # relative_object not required yet for these
        EnemyHomingMissile.new(@scale, @screen_width, @screen_height, self, player, {side: 'left',  relative_object: self }),
        EnemyHomingMissile.new(@scale, @screen_width, @screen_height, self, player, {side: 'right', relative_object: self })
      ],
      cooldown: EnemyHomingMissile::COOLDOWN_DELAY
    }
  end


  def tertiary_attack player
    return {
      projectiles: [EnemyBomb.new(@scale, @screen_width, @screen_height, self, player.x, player.y)],
      cooldown: EnemyBomb::COOLDOWN_DELAY
    }
  end


  def drops
    [
      SmallExplosion.new(@scale, @screen_width, @screen_height, @x, @y, @image)
      # Star.new(@scale, @x, @y)
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
    @secondary_cooldown_wait -= 1 if @secondary_cooldown_wait > 0
    @tertiary_cooldown_wait -= 1 if @tertiary_cooldown_wait > 0
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