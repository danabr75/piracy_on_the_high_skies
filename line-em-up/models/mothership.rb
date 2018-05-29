require_relative 'player.rb'
require_relative 'enemy_bullet.rb'
require_relative 'enemy_homing_missile.rb'
require_relative 'small_explosion.rb'
require_relative 'star.rb'
require_relative 'enemy_bomb.rb'

class Mothership < GeneralObject
  Speed = 5
  MAX_ATTACK_SPEED = 3.0
  POINT_VALUE_BASE = 1000
  attr_accessor :cooldown_wait, :attack_speed, :health, :armor, :x, :y, :secondary_cooldown_wait, :tertiary_cooldown_wait

  def initialize(scale, width, height, x = nil, y = nil)
    @scale = scale
    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/starfighterv4.png").first
    # @image = Gosu::Image.new(image, :tileable => true)
    # @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/starfighterv4.png")
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/mothership.png")
    # @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_boat_reverse.png")
    # @beep = Gosu::Sample.new("#{MEDIA_DIRECTORY}/beep.wav")
    @x = width / 2
    @y = 0 + @image.height
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @tertiary_cooldown_wait = 0
    @attack_speed = 0.5
    @health = 500
    @armor = 0
    @image_width  = @image.width  * @scale
    @image_height = @image.height * @scale
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4
    @current_speed = (rand(5) * @scale).round + 1
  end

  def draw
    # Will generate error if class name is not listed on ZOrder
    @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)
    # @image.draw(@xΩ - @image.width / 2, @y - @image.height / 2, get_draw_ordering)
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
      projectiles: [
        EnemyBullet.new(@scale, width, height, self, nil, nil, {side: 'left'}),
        EnemyBullet.new(@scale, width, height, self, nil, nil, {side: 'right'}),
        EnemyBullet.new(@scale, width, height, self, nil, nil)
      ],
      cooldown: EnemyBullet::COOLDOWN_DELAY
    }
  end

  def secondary_attack width, height, player
    return {
      projectiles: [
        EnemyHomingMissile.new(@scale, width, height, self, nil, nil, player, {side: 'left'}),
        EnemyHomingMissile.new(@scale, width, height, self, nil, nil, player, {side: 'right'})
      ],
      cooldown: EnemyHomingMissile::COOLDOWN_DELAY
    }
  end


  def tertiary_attack width, height, player
    return {
      projectiles: [EnemyBomb.new(@scale, width, height, self, player.x, player.y)],
      cooldown: EnemyBomb::COOLDOWN_DELAY
    }
  end


  def drops
    [
      SmallExplosion.new(@scale, @x, @y, @image)
      # Star.new(@scale, @x, @y)
    ]
  end

  def get_draw_ordering
    ZOrder::Enemy
  end

  # SPEED = 1
  # def get_speed
    
  # end

  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
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

          @y = height / 2 if @y > height / 2
        else
          @y -= @current_speed

          @y = 0 + (get_height / 2) if @y < 0 + (get_height / 2)
        end
      end
      if rand(2).even?
        @x += @current_speed
        @x = width if @x > width
      else
        @x -= @current_speed
        @x = 0 + (get_width / 2) if @x < 0 + (get_width / 2)
      end

      @y < height + (get_height / 2)
    else
      false
    end
  end
  
end