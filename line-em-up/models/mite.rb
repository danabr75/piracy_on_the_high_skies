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
    @switched_directions = false
    @damage_factor = options[:damage_increase] || 0.3
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
        SemiGuidedMissile.new(@scale, @screen_width, @screen_height, self, player, nil, nil, nil, {damage_increase: @damage_factor})
      ],
      cooldown: SemiGuidedMissile::COOLDOWN_DELAY * MAX_ATTACK_SPEED
    }
  end


  def drops
    value = [SmallExplosion.new(@scale, @screen_width, @screen_height, @x, @y, nil, {ttl: 2, third_scale: true})]
    value << Star.new(@scale, @screen_width, @screen_height, @x, @y) if rand(2) == 0
    return value
  end

  def get_draw_ordering
    ZOrder::Enemy
  end

  # def exec_gl
  #   raise "HERE"
  # end

  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    @cooldown_wait -= 1 if @cooldown_wait > 0
    @time_alive += 1
    if is_alive
      @x = @x + (@current_speed * @x_direction)
      @y = @y + (Math.sin(@x / 50) * 5 * @scale)# * 20 * @scale

      if @switched_directions
        # puts "CASE 1"
        if @x_direction > 0
          # puts "CASE 1.3"
          @x < @screen_width
        else
          # puts 'CASE 1.6'
          @x > 0
        end
      else
        if @x_direction < 0 && @x < 0 - @screen_width / 2
          # puts "CASE 2: "
          @switched_directions = true
          @x_direction = @x_direction * -1
        elsif @x_direction > 0 && @x > @screen_width + @screen_width / 2
          # puts "CASE 3"
          @switched_directions = true
          @x_direction = @x_direction * -1
        end
        # puts "CASE 4"
        return true
      end
    else
      # puts "CASE 5"
      false
    end
  end
end