require_relative 'general_object.rb'

class DumbProjectile < GeneralObject
  attr_accessor :x, :y, :time_alive
  # WARNING THESE CONSTANTS DON'T GET OVERRIDDEN BY SUBCLASSES. NEED GETTER METHODS
  COOLDOWN_DELAY = 50
  STARTING_SPEED = 3.0
  INITIAL_DELAY  = 0
  SPEED_INCREASE_FACTOR = 0.0
  DAMAGE = 5
  AOE = 0
  MAX_CURSOR_FOLLOW = 5 # Do we need this if we have a max speed?
  ADVANCED_HIT_BOX_DETECTION = false


  def get_image
    puts "override get_image!"
    Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def initialize(scale, screen_width, screen_height, object, options = {})
    options[:relative_object] = object
    super(scale, object.x, object.y, screen_width, screen_height, options)
    @current_speed = self.class.get_max_speed * @scale
  end


  def update mouse_x = nil, mouse_y = nil, player = nil
    @y -= @current_speed
    @y > 0 && @y < @screen_height
  end


  def get_draw_ordering
    ZOrder::Projectile
  end

  def destructable?
    false
  end

  def hit_object(object)
    return hit_objects([[object]])
  end

  def hit_objects(object_groups)
    drops = []
    points = 0
    hit_object = false
    killed = 0
    object_groups.each do |group|
      group.each do |object|
        next if object.nil?
        break if hit_object
        if object.health <= 0
          next
        end
        hit_object = Gosu.distance(@x, @y, object.x, object.y) < self.get_radius + object.get_radius
        if hit_object
          if object.respond_to?(:health) && object.respond_to?(:take_damage)
            object.take_damage(self.class.get_damage)
          end

          if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)

            object.drops.each do |drop|
              drops << drop
            end
          end

          if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:get_points)
            killed += 1
            points = points + object.get_points
          end
        end
      end
    end
    @y = @off_screen if hit_object
    return {drops: drops, point_value: points, killed: killed}
  end

  protected
  def self.get_damage
    self::DAMAGE
  end
  def self.get_aoe
    self::AOE
  end
  def self.get_cooldown_delay
    self::COOLDOWN_DELAY
  end
  def self.get_starting_speed
    self::STARTING_SPEED
  end
  def self.get_starting_speed
    self::STARTING_SPEED
  end
  def self.get_initial_delay
    self::INITIAL_DELAY
  end
  def self.get_speed_increase_factor
    self::SPEED_INCREASE_FACTOR
  end
  def self.get_max_cursor_follow
    self::MAX_CURSOR_FOLLOW
  end
  def self.get_advanced_hit_box_detection
    self::ADVANCED_HIT_BOX_DETECTION
  end
end