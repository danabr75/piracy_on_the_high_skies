require_relative 'screen_map_fixed_object.rb'
# require "#{LIB_DIRECTORY}/z_order.rb"

class Projectile < ScreenMapFixedObject
  attr_accessor :x, :y, :time_alive, :vector_x, :vector_y, :angle, :radian
  # WARNING THESE CONSTANTS DON'T GET OVERRIDDEN BY SUBCLASSES. NEED GETTER METHODS
  # COOLDOWN_DELAY = 50
  STARTING_SPEED = 0.1
  MAX_SPEED      = 1
  INITIAL_DELAY  = 0
  SPEED_INCREASE_FACTOR = 0.0
  SPEED_INCREASE_INCREMENT = 0.0
  DAMAGE = 5
  AOE = 0
  MAX_CURSOR_FOLLOW = 5 # Do we need this if we have a max speed?
  ADVANCED_HIT_BOX_DETECTION = false

  IMAGE_SCALER = 2.0

  DRAW_ORDER = ZOrder::Projectile

  HEALTH = 1

  MAX_TIME_ALIVE = 300

  # IMPLEMENT THIS
  MAX_TILE_TRAVEL = 4

  CLASS_TYPE = :projectile
  # CLASS_TYPEs that are in play right now :ship, :building, :projectile
  HIT_OBJECT_CLASS_FILTER = nil

  def self.get_image
    return Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def get_image
    self.class.get_image
  end

  def draw_gl
  end

  # destination_map_pixel_x, destination_map_pixel_y params will become destination_angle
  def initialize(current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options = {})
    # puts "PROJETIL PARALMS"
    # puts "current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options"
    # puts "#{[current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options]}"
    # validate_not_nil([current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y], self.class.name, __callee__)
    super(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options)

    @hit_objects_class_filter = self.class::HIT_OBJECT_CLASS_FILTER

    @owner = owner

    if self.class::MAX_TILE_TRAVEL
      @max_distance = self.class::MAX_TILE_TRAVEL * @average_tile_size
    end
    @start_current_map_pixel_x = @current_map_pixel_x
    @start_current_map_pixel_y = @current_map_pixel_y

    @angle = self.class.angle_1to360(destination_angle)
    # puts "CALC ANGLE: #{@angle} INIT ANGLE: #{angle_init}"

    @radian = calc_radian(start_point, end_point)

    @health = self.class::HEALTH

    @refresh_angle_on_updates = options[:refresh_angle_on_updates] || false

    @speed = self.class.get_starting_speed

    if @angle < 0.0
      @angle = 360.0 - @angle.abs
    end
    if @angle > 360.0
      @angle = @angle - 360.0
    end

    angle_min = self.class.angle_1to360(angle_min)
    angle_max = self.class.angle_1to360(angle_max)

    if angle_min.nil? && angle_max.nil?
      # do nothing
    else
      if is_angle_between_two_angles?(@angle, angle_min, angle_max)
        # Do nothing, we're good
      else
        value = nearest_angle(@angle, angle_min, angle_max)
        @angle = value
      end
    end

    # Angle init is always mandatory, why have 'else'?
    if @refresh_angle_on_updates && angle_init 
      # @end_image_angle = @angle + 90
      # @current_image_angle = angle_init + 90
      # How useful is this..... imlpement when needed
      # just going with the usual
      @current_image_angle = @end_image_angle = @angle
    else
      @current_image_angle = @end_image_angle = @angle
    end

    # if it's min, incrementer is negative, else pos
    # value = nearest_angle(@angle, angle_min, angle_max)
    # if value == angle_min
    # THIS NEEDS TP BE UPDATED... wrong rotation
    if @refresh_angle_on_updates
      if @angle == angle_min
        @image_angle_incrementor = -0.2
      else
        @image_angle_incrementor = 0.2
      end
    end

    @init_sound = self.class.get_init_sound
    @play_init_sound = true
    # @i ||= 1
    # @i += 1
    # @i = -50 if @i > 50
    # @init_sound.play_pan(-5000,@effects_volume, 1, false) if @init_sound

  end

  def self.get_init_sound
    return nil
  end

  def update mouse_x, mouse_y, player




    # puts "PROJ SPEED: #{@speed}"
    if @refresh_angle_on_updates && @end_image_angle && @time_alive > 10
      if @current_image_angle != @end_image_angle
        @current_image_angle = @current_image_angle + @image_angle_incrementor
        # if it's negative
        if @image_angle_incrementor < 0
          @current_image_angle = @end_image_angle if @current_image_angle < @end_image_angle 
        # it's positive
        elsif @image_angle_incrementor > 0
          @current_image_angle = @end_image_angle if @current_image_angle > @end_image_angle 
        end
      end
    end

    # new_speed = 0
    if self.class.get_initial_delay && (@time_alive > (@custom_initial_delay || self.class.get_initial_delay))
      speed_factor = self.class.get_speed_increase_factor
      if @speed < self.class.get_max_speed
        if speed_factor && speed_factor > 0.0
          @speed = @speed + (@time_alive * speed_factor)
        end
        speed_increment = self.class.get_speed_increase_increment
        if speed_increment && speed_increment > 0.0
          @speed = @speed + speed_increment
        end

        @speed = self.class.get_max_speed if @speed > self.class.get_max_speed
      end

      # puts "SPEED HERE: #{@speed}"
      factor_in_scale_speed = @speed * @average_scale

      movement(factor_in_scale_speed, @angle) if factor_in_scale_speed != 0
    else
      @speed = self.class.get_max_speed if @speed.nil?
      factor_in_scale_speed = @speed * @average_scale
      movement(factor_in_scale_speed, @angle) if factor_in_scale_speed != 0
    end

    @health = 0 if self.class::MAX_TIME_ALIVE && @time_alive >= self.class::MAX_TIME_ALIVE

    result = super(mouse_x, mouse_y, player)
    @init_sound.play(@effects_volume, 1, false) if @play_init_sound && @init_sound && is_on_screen?
    @play_init_sound = false

    if @max_distance && @max_distance < Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, @start_current_map_pixel_x, @start_current_map_pixel_y)
      # puts "TEST ++ = FOUND MAX DISTANCE"
      @health = 0
    end

    return result
  end

  def draw viewable_pixel_offset_x, viewable_pixel_offset_y
    # limiting angle extreme by 2
    if is_on_screen?
      @image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, DRAW_ORDER, -@current_image_angle, 0.5, 0.5, @height_scale / self.class::IMAGE_SCALER, @height_scale / self.class::IMAGE_SCALER)
    end
  end

  def get_draw_ordering
    ZOrder::Projectile
  end

  def destructable?
    false
  end

  def hit_object(object)
    raise "WHY? STOP USING ME"
    # return hit_objects([[object]])
    # puts "PROJECTILE hit object: #{test}"
    # return test
  end

  # require 'benchmark'

  def hit_objects(object_groups)
    drops = []
    points = 0
    hit_object = false
    killed = 0
    object_groups.each do |group|
      group.each do |object|
        next if object.nil?
        # Don't hit yourself
        next if object.id == @id
        # Don't hit the ship that launched it
        next if object.id == @owner.id
        next if !@hit_objects_class_filter.include?(object.class::CLASS_TYPE) if @hit_objects_class_filter
        break if hit_object
        # don't hit a dead object
        if object.health <= 0
          next
        end
        # if Gosu.distance(@x, @y, object.x, object.y) < (self.get_size / 2)
        # maybe add advanced collision in when support multi-threads
        if false && self.class.get_advanced_hit_box_detection
          # Disabling advanced hit detection for now
          self_object = [[(@x - get_width / 2), (@y - get_height / 2)], [(@x + get_width / 2), (@y + get_height / 2)]]
          other_object = [[(object.x - object.get_width / 2), (object.y - object.get_height / 2)], [(object.x + object.get_width / 2), (object.y + object.get_height / 2)]]
          hit_object = rec_intersection(self_object, other_object)
        else
          # puts "HIT OBJECT DETECTION: proj-size: #{(self.get_size / 2)}"
          # puts "HIT OBJECT DETECTION:  obj-size: #{(self.get_size / 2)}"
          raise "OBJECT #{object.class.name} IN COLLISION DIDN'T HAVE COORD X" if @debug && !object.respond_to?(:current_map_pixel_x)
          raise "OBJECT #{object.class.name} IN COLLISION DIDN'T HAVE COORD Y" if @debug && !object.respond_to?(:current_map_pixel_y)
          raise "OBJECT #{object.class.name} IN COLLISION COORD X WAS NIL" if @debug && object.current_map_pixel_x.nil?
          raise "OBJECT #{object.class.name} IN COLLISION COORD Y WAS NIL" if @debug && object.current_map_pixel_y.nil?
          if @debug
            if self.get_radius.nil?
              raise "NO RADIUS FOUND FOR #{self.class.name}. Does it have an Image assigned? Is image nil? #{self.get_image.nil?} and is image nil? #{object.image.nil?}"
            end
            if object.get_radius.nil?
              raise "NO RADIUS FOUND FOR #{object.class.name}. Does it have an Image assigned? Is get image nil? #{object.get_image.nil?} and is image nil? #{object.image.nil?}"
            end
          end
          hit_object = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, object.current_map_pixel_x, object.current_map_pixel_y) < self.get_radius + object.get_radius
        end
        if hit_object && self.class.get_aoe <= 0
          result = trigger_object_collision(object) 
          drops = drops + result[:drops] if result[:drops].any?
        end
      end
    end
    if hit_object && self.class.get_aoe > 0
      object_groups.each do |group|
        group.each do |object|
          next if object.nil?
          result = trigger_aoe_object_collision(object)
          drops = drops + result[:drops] if result[:drops].any?
        end
      end
    end

    # Drop projectile explosions
    if hit_object
      if self.respond_to?(:drops)
        self.drops.each do |drop|
          drops << drop
        end
      end
    end

    @health = 0 if hit_object
    # puts "COLLICION RETURNING DROPS: #{drops}" if drops.any?
    return {drops: drops, point_value: points, killed: killed}
  end

  protected

  def trigger_aoe_object_collision object
    value = {drops: []}
    if Gosu.distance(@x, @y, object.x, object.y) < self.class.get_aoe * @average_scale
      if object.respond_to?(:health) && object.respond_to?(:take_damage)
        object.take_damage(self.class.get_damage * @damage_increase)
      end

      if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)
        object.drops.each do |drop|
          value[:drops] << drop
        end
      end
    end
    return value
  end

  def trigger_object_collision(object)
    value = {drops: []}
    if object.respond_to?(:health) && object.respond_to?(:take_damage)
      object.take_damage(self.class.get_damage * @damage_increase)
    end

    if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)
      object.drops.each do |drop|
        value[:drops] << drop
      end
    end
    # puts "RETURNING VALUE: #{value}"
    return value
  end


  def self.get_damage
    self::DAMAGE
  end
  def self.get_aoe
    self::AOE
  end
  # def self.get_cooldown_delay
  #   self::COOLDOWN_DELAY
  # end
  def self.get_starting_speed
    self::STARTING_SPEED
  end
  def self.get_initial_delay
    self::INITIAL_DELAY
  end
  def self.get_speed_increase_factor
    self::SPEED_INCREASE_FACTOR
  end
  def self.get_speed_increase_increment
    self::SPEED_INCREASE_INCREMENT
  end
  # need to re-implement this
  def self.get_max_cursor_follow
    self::MAX_CURSOR_FOLLOW
  end
  def self.get_advanced_hit_box_detection
    self::ADVANCED_HIT_BOX_DETECTION
  end


  # rect1[0][0] and rect2[0][0] are the two leftmost x-coordinates of the rectangles,
  # Rectangles are represented as a pair of coordinate-pairs: the
  # bottom-left and top-right coordinates (given in `[x, y]` notation).
  def rec_intersection(rect1, rect2)

    x_min = [rect1[0][0], rect2[0][0]].max
    x_max = [rect1[1][0], rect2[1][0]].min

    y_min = [rect1[0][1], rect2[0][1]].max
    y_max = [rect1[1][1], rect2[1][1]].min

    return nil if ((x_max < x_min) || (y_max < y_min))
    return [[x_min, y_min], [x_max, y_max]]
  end

    # puts rec_intersection(
    #       [[0, 0], [2, 1]],
    #       [[1, 0], [3, 1]]
    #     ) == [[1, 0], [2, 1]]

    # puts rec_intersection(
    #       [[1, 1], [2, 2]],
    #       [[0, 0], [5, 5]]
    #     ) == [[1, 1], [2, 2]]


    # puts rec_intersection(
    #       [[1, 1], [2, 2]],
    #       [[4, 4], [5, 5]]
    #     ) == nil

    # puts rec_intersection(
    #       [[1, 1], [5, 4]],
    #       [[2, 2], [3, 5]]
    #     ) == [[2, 2], [3, 4]]

  # private

  def point_is_between_the_ys_of_the_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
    (a_point_on_polygon.y <= point.y && point.y < trailing_point_on_polygon.y) || 
    (trailing_point_on_polygon.y <= point.y && point.y < a_point_on_polygon.y)
  end

  def ray_crosses_through_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
    (point.x < (trailing_point_on_polygon.x - a_point_on_polygon.x) * (point.y - a_point_on_polygon.y) / 
               (trailing_point_on_polygon.y - a_point_on_polygon.y) + a_point_on_polygon.x)
  end

  # def is_on_screen?
  #   # @image.draw(@x - get_width / 2, @y - get_height / 2, ZOrder::Player)
  #   @y > (0 - get_height) && @y < (HEIGHT + get_height) && @x > (0 - get_width) && @x < (WIDTH + get_width)
  # end

  def calc_angle(point1, point2)
    bearing = (180/Math::PI)*Math.atan2(point1.y-point2.y, point2.x-point1.x)
    return bearing
  end

  def calc_radian(point1, point2)
    rdn = Math.atan2(point1.y-point2.y, point2.x-point1.x)
    return rdn
  end

end