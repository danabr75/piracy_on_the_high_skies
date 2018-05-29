require_relative 'projectile.rb'
class Missile < Projectile
  attr_reader :x, :y, :time_alive, :mouse_start_x, :mouse_start_y
  COOLDOWN_DELAY = 30
  MAX_SPEED      = 20
  STARTING_SPEED = 0.0
  INITIAL_DELAY  = 2
  SPEED_INCREASE_FACTOR = 0.5
  DAMAGE = 50
  AOE = 0
  
  MAX_CURSOR_FOLLOW = 4
  ADVANCED_HIT_BOX_DETECTION = true

  # def hit_objects(object_groups)
  #   puts "HERE: #{self.class.get_damage}"
  #   super(object_groups)
  # end

  # def initialize(scale, screen_width, screen_height, object, end_point_x, end_point_y, angle_min, angle_max, angle_init, options)
  #   super(scale, screen_width, screen_height, object, end_point_x, end_point_y, angle_min, angle_max, angle_init, options)
  #   # puts "MYYYY MISSILE ANGLE: #{@angle}"
  # end

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/missile.png")
  end

  # def initialize(object, mouse_x = nil, mouse_y = nil, options = {})
  #   @image = get_image

  #   if LEFT == options[:side]
  #     @x = object.get_x - (object.get_width / 2)
  #     @y = object.get_y# - player.get_height
  #   elsif RIGHT == options[:side]
  #     @x = (object.get_x + object.get_width / 2) - 4
  #     @y = object.get_y# - player.get_height
  #   else
  #     @x = object.get_x
  #     @y = object.get_y
  #   end
  #   @time_alive = 0
  #   @mouse_start_x = mouse_x
  #   @mouse_start_y = mouse_y
  # end
  
  # def update mouse_x = nil, mouse_y = nil, player = nil
  #   new_speed = 0
  #   if @time_alive > self.class.get_initial_delay
  #     new_speed = self.class.get_starting_speed + (self.class.get_speed_increase_factor > 0 ? @time_alive * self.class.get_speed_increase_factor : 0)
  #     new_speed = self.class.get_max_speed if new_speed > self.class.get_max_speed
  #     new_speed = new_speed * @scale
  #   end



  #   vx = 0
  #   vy = 0
  # if new_speed != 0
  #   vx = ((new_speed / 3) * 1) * Math.cos(@angle * Math::PI / 180)

  #   vy = ((new_speed / 3) * 1) * Math.sin(@angle * Math::PI / 180)
  #   vy = vy * -1
  # end

  #   @x = @x + vx
  #   @y = @y + vy

  #   super(mouse_x, mouse_y)
  # end
end