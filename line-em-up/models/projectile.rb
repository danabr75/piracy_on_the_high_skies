require_relative 'general_object.rb'

class Projectile < GeneralObject
  attr_accessor :x, :y, :time_alive, :vector_x, :vector_y, :angle, :radian
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

  def initialize(scale, screen_width, screen_height, object, end_point_x, end_point_y, options = {})
    options[:relative_object] = object
    super(scale, nil, nil, screen_width, screen_height, options)

    start_point = OpenStruct.new(:x => @x - screen_width / 2, :y => @y - screen_height / 2)
    # start_point = GeoPoint.new(@x - WIDTH / 2, @y - HEIGHT / 2)
    # end_point   =   OpenStruct.new(:x => @mouse_start_x, :y => @mouse_start_y)
    end_point   = OpenStruct.new(:x => end_point_x - screen_width / 2, :y => end_point_y - screen_height / 2)
    # end_point = GeoPoint.new(@mouse_start_x - WIDTH / 2, @mouse_start_y - HEIGHT / 2)
    @angle = calc_angle(start_point, end_point)
    @radian = calc_radian(start_point, end_point)


    if @angle < 0
      @angle = 360 - @angle.abs
    end
  end

  def get_draw_ordering
    ZOrder::Projectile
  end

  def destructable?
    false
  end

  def hit_object(object)
    return hit_objects([[object]])
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
        break if hit_object
        # don't hit a dead object
        if object.health <= 0
          next
        end
        # if Gosu.distance(@x, @y, object.x, object.y) < (self.get_size / 2)
        if self.class.get_advanced_hit_box_detection
          self_object = [[(@x - get_width / 2), (@y - get_height / 2)], [(@x + get_width / 2), (@y + get_height / 2)]]
          other_object = [[(object.x - object.get_width / 2), (object.y - object.get_height / 2)], [(object.x + object.get_width / 2), (object.y + object.get_height / 2)]]
          hit_object = rec_intersection(self_object, other_object)
        else
          # puts "HIT OBJECT DETECTION: proj-size: #{(self.get_size / 2)}"
          # puts "HIT OBJECT DETECTION:  obj-size: #{(self.get_size / 2)}"
          hit_object = Gosu.distance(@x, @y, object.x, object.y) < self.get_radius + object.get_radius
        end
        if hit_object
          # puts "HIT OBJECT"
          # hit_object = true
          if self.class.get_aoe <= 0
            # puts "shout be here"
            # puts "1: #{object.respond_to?(:health)}"
            # puts "2: #{object.respond_to?(:take_damage)}"
            if object.respond_to?(:health) && object.respond_to?(:take_damage)
              # puts "OBJECT TALING DAMAGE: #{self.class.get_damage}"
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
    end
    if hit_object && self.class.get_aoe > 0
      object_groups.each do |group|
        group.each do |object|
          next if object.nil?
          if Gosu.distance(@x, @y, object.x, object.y) < self.class.get_aoe * @scale
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