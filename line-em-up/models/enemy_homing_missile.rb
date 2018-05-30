require_relative 'projectile.rb'
class EnemyHomingMissile < Projectile
  attr_reader :x, :y, :time_alive, :mouse_start_x, :mouse_start_y, :health
  COOLDOWN_DELAY = 75
  MAX_SPEED      = 20
  STARTING_SPEED = 0.0
  INITIAL_DELAY  = 2
  SPEED_INCREASE_FACTOR = 0.9
  DAMAGE = 15
  AOE = 0
  
  MAX_CURSOR_FOLLOW = 4
  # ADVANCED_HIT_BOX_DETECTION = true
  ADVANCED_HIT_BOX_DETECTION = false

  def get_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile_reverse.png")
    Gosu::Image.new("#{MEDIA_DIRECTORY}/tiny_missile.png")
  end

  def initialize(scale, screen_width, screen_height, object, homing_object, angle_min, angle_max, angle_init, options = {})
    options[:relative_object] = object
    super(scale, screen_width, screen_height, object, homing_object.x, homing_object.y, angle_min, angle_max, angle_init, options)
    @health = 5
    # puts "CUSTOM DELAY: #{@custom_initial_delay}"
  end

  def destructable?
    true
  end

  def is_alive
    @health > 0
  end

  def drops
    [
      SmallExplosion.new(@scale, @screen_width, @screen_height, @x, @y, nil, {ttl: 2, third_scale: true}),
    ]
  end


  def take_damage damage
    @health -= damage
  end


  def update mouse_x = nil, mouse_y = nil
    if is_alive
      super(mouse_x, mouse_y)
    else
      false
    end
  end
end