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
    Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile_reverse.png")
  end

  def initialize(scale, screen_width, screen_height, object, homing_object, options = {})
    options[:relative_object] = object
    super(scale, screen_width, screen_height, object, homing_object.x, homing_object.y, options)
    # @scale = scale
    # @image = get_image
    # @time_alive = 0
    @health = 5
    # # @mouse_start_x = mouse_x
    # # @mouse_start_y = mouse_y

    # if LEFT == options[:side]
    #   @x = object.x - (object.get_width / 2)
    #   @y = object.y
    # elsif RIGHT == options[:side]
    #   @x = (object.x + object.get_width / 2) - 4
    #   @y = object.y
    # else
    #   @x = object.x
    #   @y = object.y
    # end

    # if homing_object && homing_object.is_alive

    #   start_point = OpenStruct.new(:x => @x - width / 2, :y => @y - height / 2)
    #   # start_point = GeoPoint.new(@x - WIDTH / 2, @y - HEIGHT / 2)
    #   # end_point   =   OpenStruct.new(:x => @mouse_start_x, :y => @mouse_start_y)
    #   end_point   = OpenStruct.new(:x => homing_object.x - width / 2, :y => homing_object.y - height / 2)
    #   # end_point = GeoPoint.new(@mouse_start_x - WIDTH / 2, @mouse_start_y - HEIGHT / 2)
    #   @angle = calc_angle(start_point, end_point)
    #   @radian = calc_radian(start_point, end_point)


    #   if @angle < 0
    #     @angle = 360 - @angle.abs
    #   end
    # else
    #   @angle = 280.0
    # end
    # @image_width  = @image.width  * @scale
    # @image_height = @image.height * @scale
    # @image_size   = @image_width  * @image_height / 2
    # @image_radius = (@image_width  + @image_height) / 4
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
    if is_alive
      new_speed = 0
      if @time_alive > self.class.get_initial_delay
        new_speed = self.class.get_starting_speed + (self.class.get_speed_increase_factor > 0 ? @time_alive * self.class.get_speed_increase_factor : 0)
        new_speed = self.class.get_max_speed if new_speed > self.class.get_max_speed
        new_speed = new_speed * @scale
      end

      vx = 0
      vy = 0
      if new_speed > 0
        vx = ((new_speed / 3)) * Math.cos(@angle * Math::PI / 180)

        vy = ((new_speed / 3)) * Math.sin(@angle * Math::PI / 180)
        vy = vy * -1
        # Because our y is inverted
        vy = vy - ((new_speed / 3) * 2)
      end

      @x = @x + vx
      @y = @y - vy

      super(mouse_x, mouse_y)
    else
      false
    end
  end
end