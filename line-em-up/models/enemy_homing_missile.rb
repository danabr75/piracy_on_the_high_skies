require_relative 'projectile.rb'
class EnemyHomingMissile < Projectile
  attr_reader :x, :y, :time_alive, :mouse_start_x, :mouse_start_y, :health
  COOLDOWN_DELAY = 75
  MAX_SPEED      = 18
  STARTING_SPEED = 0.0
  INITIAL_DELAY  = 2
  SPEED_INCREASE_FACTOR = 0.5
  DAMAGE = 15
  AOE = 0
  
  MAX_CURSOR_FOLLOW = 4
  # ADVANCED_HIT_BOX_DETECTION = true
  ADVANCED_HIT_BOX_DETECTION = false

  def get_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile_reverse.png")
    Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile.png")
  end

  def initialize(scale, screen_width, screen_height, object, homing_object, options = {})
    options[:relative_object] = object
    super(scale, screen_width, screen_height, object, homing_object.x, homing_object.y, options)
    @health = 5
    # puts "ENEMY MISSILE ANGLE: #{@angle}"
  end

  def destructable?
    true
  end

  def is_alive
    @health > 0
  end


  def take_damage damage
    @health -= damage
  end


  def update mouse_x = nil, mouse_y = nil, player = nil
    new_speed = 0
    if @time_alive > self.class.get_initial_delay
      new_speed = self.class.get_starting_speed + (self.class.get_speed_increase_factor > 0 ? @time_alive * self.class.get_speed_increase_factor : 0)
      new_speed = self.class.get_max_speed if new_speed > self.class.get_max_speed
      new_speed = new_speed * @scale
    end



    vx = 0
    vy = 0
      # vx = MAX_SPEED * Math.cos(@angle * Math::PI / 180)

      # vy = MAX_SPEED * Math.sin(@angle * Math::PI / 180)

      # vy = vy * -1
    if new_speed != 0
      vx = ((new_speed / 3) * 1) * Math.cos(@angle * Math::PI / 180)

      vy = ((new_speed / 3) * 1) * Math.sin(@angle * Math::PI / 180)
      vy = vy * -1
      # Because our y is inverted
      # vy = vy - ((new_speed / 3) * 2)
    end

    @x = @x + vx
    @y = @y + vy

    super(mouse_x, mouse_y)
  end
end