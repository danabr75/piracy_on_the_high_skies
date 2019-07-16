require_relative 'screen_map_fixed_object.rb'
# require "#{LIB_DIRECTORY}/z_order.rb"
require_relative '../lib/z_order.rb'

class Projectile < ScreenMapFixedObject
  attr_accessor :x, :y, :time_alive, :vector_x, :vector_y, :angle, :radian
  attr_reader :health
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

  HEALTH = 1

  MAX_TIME_ALIVE = 300

  # IMPLEMENT THIS
  MAX_TILE_TRAVEL = 4

  CLASS_TYPE = :projectile
  # CLASS_TYPEs that are in play right now :ship, :building, :projectile
  HIT_OBJECT_CLASS_FILTER = nil


  POST_DESTRUCTION_EFFECTS = false

  def get_post_destruction_effects
    raise 'override me!'
  end

  def self.get_post_destruction_effects
    raise 'override me!'
  end

  def self.get_image
    return Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def get_image
    self.class.get_image
  end

  def draw_gl
  end

  # destination_map_pixel_x, destination_map_pixel_y params will become destination_angle
  def initialize(current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, z_projectile, options = {})
    # puts "PROJETIL PARALMS"
    # puts "current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options"
    # puts "#{[current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options]}"
    # validate_not_nil([current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y], self.class.name, __callee__)
    super(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options)

    @hit_objects_class_filter = self.class::HIT_OBJECT_CLASS_FILTER

    @owner = owner

    @z = z_projectile

    if self.class::MAX_TILE_TRAVEL
      @max_distance = self.class::MAX_TILE_TRAVEL * @average_tile_size
    end
    @start_current_map_pixel_x = @current_map_pixel_x
    @start_current_map_pixel_y = @current_map_pixel_y

    @angle = self.class.angle_1to360(destination_angle)
    # puts "CALC ANGLE: #{@angle} INIT ANGLE: #{angle_init}"

    @radian = calc_radian(start_point, end_point)

    @health = self.class::HEALTH

    # @test_hit_max_distance = false

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
    @init_sound_path = self.class.get_init_sound_path
    @play_init_sound = true
    # @i ||= 1
    # @i += 1
    # @i = -50 if @i > 50
    # @init_sound.play_pan(-5000,@effects_volume, 1, false) if @init_sound

  end

  def self.get_init_sound
    return nil
  end
  def self.get_init_sound_path
    nil
  end

  def update_with_args args
    # mouse_x = args[0]
    # mouse_y = args[1]
    # player_map_pixel_x  = args[2]
    # player_map_pixel_y  = args[3]
    return update(args[0], args[1], args[2], args[3])
  end

  def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
    graphical_effects = []
    # puts "PROJ SPEED: #{@speed}"
    if self.is_alive
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
        factor_in_scale_speed = @speed * @height_scale

        movement(factor_in_scale_speed, @angle, true) if factor_in_scale_speed != 0
      else
        @speed = self.class.get_max_speed if @speed.nil?
        factor_in_scale_speed = @speed * @height_scale
        movement(factor_in_scale_speed, @angle, true) if factor_in_scale_speed != 0
      end

      @health = self.take_damage(@health) if self.class::MAX_TIME_ALIVE && @time_alive >= self.class::MAX_TIME_ALIVE

      is_alive = super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
      @init_sound.play(@effects_volume, 1, false) if @play_init_sound && @init_sound && is_on_screen?
      @play_init_sound = false

      if @max_distance && @max_distance < Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, @start_current_map_pixel_x, @start_current_map_pixel_y)
        @health = self.take_damage(@health)
      end

      if !is_alive
        if self.class::POST_DESTRUCTION_EFFECTS
          # puts "AADDING GRAPHICAL EEFFECTS"
          self.get_post_destruction_effects.each do |effect|
            # puts "COUNT 1 herer"
            graphical_effects << effect
          end
        end
      end
    end
    # puts "PROJK UPDATE IS ALIVE: #{@health > 0} - #{@health}" if self.class.name == 'GrapplingHook'
    return {is_alive: is_alive, graphical_effects: graphical_effects}
  end

  def get_data 
    return {
      time_alive: @time_alive,
      # last_updated_at: @last_updated_at,
      refresh_angle_on_updates: @refresh_angle_on_updates,
      end_image_angle: @end_image_angle,
      custom_initial_delay: @custom_initial_delay,
      speed: @speed,
      average_scale: @average_scale,
      height_scale:  @height_scale,
      angle: @angle,
      health: @health,
      current_map_pixel_x: @current_map_pixel_x,
      current_map_pixel_y: @current_map_pixel_y,
      current_map_tile_x: @current_map_pixel_x,
      current_map_tile_y: @current_map_pixel_y,
      current_image_angle: @current_image_angle,
      image_angle_incrementor: @image_angle_incrementor,
      x: @x,
      y: @y,
      tile_pixel_width: @tile_pixel_width,
      tile_pixel_height: @tile_pixel_height,
      max_distance: @max_distance,
      play_init_sound: @play_init_sound,
      init_sound_path: @init_sound_path,
      screen_pixel_width: @screen_pixel_width,
      screen_pixel_height: @screen_pixel_height,
      id: @id,
      klass: self.class,
      initial_delay: self.class::INITIAL_DELAY,
      speed_increase_factor: self.class::SPEED_INCREASE_FACTOR,
      max_speed: self.class::MAX_SPEED,
      max_time_alive: self.class::MAX_TIME_ALIVE,
      post_destruction_effects: self.class::POST_DESTRUCTION_EFFECTS,
      start_current_map_pixel_x: @start_current_map_pixel_x,
      start_current_map_pixel_y: @start_current_map_pixel_y

    }
  end

  def set_data data
    @health              += data['change_health']      if data.key?('change_health')

    @current_map_pixel_x += data['change_map_pixel_x'] if data.key?('change_map_pixel_x')
    @current_map_pixel_y += data['change_map_pixel_y'] if data.key?('change_map_pixel_y')

    @current_map_tile_x += data['change_map_tile_x']   if data.key?('change_map_tile_x')
    @current_map_tile_y += data['change_map_tile_y']   if data.key?('change_map_tile_y')
    @current_image_angle += data['change_image_angle'] if data.key?('change_image_angle')
    @speed               += data['change_speed']       if data.key?('change_speed')
    @x                   += data['change_x']           if data.key?('change_x')
    @y                   += data['change_y']           if data.key?('change_y')
    @time_alive          =  data['time_alive']         if data.key?('time_alive')
    @play_init_sound     =  data['play_init_sound']    if data.key?('play_init_sound')
  end

  # return {
    # sounds: [], graphical_effects: [], is_alive: ...,
    # change_health: -2,
    # change_map_pixel_x: ..
    # change_map_pixel_y: ..
    # change_image_angle: ..
    # change_speed: ..
    # change_x: ..
    # change_y: ..
  # }
  def self.async_update data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results = {}
    # raise "ISSIUE HERE: #{data}"
    results['id'] = data['id']
    results['graphical_effects'] ||= []
    results['sounds'] ||= []
    # puts "PROJ SPEED: #{data['speed']}"
    if data['refresh_angle_on_updates'] && data['end_image_angle'] && data['time_alive'] > 10
      if data['current_image_angle'] != data['end_image_angle']
        data['current_image_angle'] = data['current_image_angle'] + data['image_angle_incrementor']
        # if it's negative
        if data['image_angle_incrementor'] < 0
          data['current_image_angle'] = data['end_image_angle'] if data['current_image_angle'] < data['end_image_angle'] 
        # it's positive
        elsif data['image_angle_incrementor'] > 0
          data['current_image_angle'] = data['end_image_angle'] if data['current_image_angle'] > data['end_image_angle'] 
        end
      end
    end

    if data['initial_delay'] && (data['time_alive'] > (data['custom_initial_delay'] || data['initial_delay']))
      speed_factor = data['speed_increase_factor']
      if data['speed'] < data['max_speed']
        if speed_factor && speed_factor > 0.0
          data['speed'] = data['speed'] + (data['time_alive'] * speed_factor)
        end
        speed_increment = get_speed_increase_increment
        if speed_increment && speed_increment > 0.0
          data['speed'] = data['speed'] + speed_increment
        end

        data['speed'] = data['max_speed'] if data['speed'] > data['max_speed']
      end

      factor_in_scale_speed = data['speed'] * data['height_scale']
      results['change_map_pixel_x'], results['change_map_pixel_y'] = async_movement(data['current_map_pixel_x'], data['current_map_pixel_y'], factor_in_scale_speed, data['angle'], data['height_scale']) if factor_in_scale_speed != 0
    else
      data['speed'] = data['max_speed'] if data['speed'].nil?
      factor_in_scale_speed = data['speed'] * data['height_scale']
      results['change_map_pixel_x'], results['change_map_pixel_y'] = async_movement(data['current_map_pixel_x'], data['current_map_pixel_y'], factor_in_scale_speed, data['angle'], data['height_scale']) if factor_in_scale_speed != 0
    end

    results['health_change'] = 0 - data['health'] if data['max_time_alive'] && data['time_alive'] >= data['max_time_alive']

    if data['max_distance'] && data['max_distance'] < Gosu.distance(data['current_map_pixel_x'], data['current_map_pixel_y'], data['start_current_map_pixel_x'], data['start_current_map_pixel_y'])
      results['health_change'] = 0 - data['health']
    end

    results.merge(super(data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results))

    if data['play_init_sound'] && data['init_sound_path'] && async_is_on_screen?(data['x'], data['y'], data['screen_pixel_width'], data['screen_pixel_height'])
      results['sounds'] << data['init_sound_path']
      results['play_init_sound'] = false
    end


    if !async_is_alive(data['health'], results['change_health'])
      if data['post_destruction_effects']
        get_post_destruction_effects.each do |effect|
          results['graphical_effects'] << effect
        end
      end
    end

    return results
  end





  def draw viewable_pixel_offset_x, viewable_pixel_offset_y
    # limiting angle extreme by 2
    if is_on_screen?
      @image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, @z, -@current_image_angle, 0.5, 0.5, @height_scale_with_image_scaler, @height_scale_with_image_scaler)
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

  def hit_objects(object_groups, options)
    # puts "PROJ hit objects"
    hit_object = false
    graphical_effects = []
    is_thread = options[:is_thread] || false
    if @health > 0
      object_groups.each do |group|
        # puts "PROJECTILE HIT OBJECTS #{@test_hit_max_distance}"
        puts "INTERNAL SERVER ERROR: projectile was dead by time it was found" if @health == 0
        break if @health == 0
        break if hit_object
        group.each do |object_id, object|
          # Thread.exit if @health == 0 && is_thread
          break if @health == 0
          next if object.nil?
          # Don't hit yourself
          # puts "NEXT IF OBJCT ID == ID"
          # puts "#{object.id} - #{@id}"
          # puts 'enxting' if object.id == @id
          next if object_id == @id
          # Don't hit the ship that launched it
          next if object_id == @owner.id
          # if object has an owner?
          next if object.owner && object.owner.id == @owner.id
          next if !@hit_objects_class_filter.include?(object.class::CLASS_TYPE) if @hit_objects_class_filter
          break if hit_object
          # don't hit a dead object
          if object.health <= 0
            next
          end
          # maybe add advanced collision in when support multi-threads
          # Not sure if this 100% works.
          if object.class::ENABLE_RECTANGLE_HIT_BOX_DETECTION
            self_object = [
              [(@current_map_pixel_x - @image_width_half), (@current_map_pixel_y - @image_height_half)],
              [(@current_map_pixel_x + @image_width_half), (@current_map_pixel_y + @image_height_half)]
            ]
            other_object = [
              [(object.current_map_pixel_x - @image_width_half), (object.current_map_pixel_y - @image_height_half)],
              [(object.current_map_pixel_x + @image_width_half), (object.current_map_pixel_y + @image_height_half)]
            ]
            hit_object = rec_intersection(self_object, other_object)
          elsif object.class::ENABLE_POLYGON_HIT_BOX_DETECTION
            hit_object = is_point_inside_polygon(OpenStruct.new(x: @current_map_pixel_x, y: @current_map_pixel_y), object.get_map_pixel_polygon_points)
          else
            hit_object = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, object.current_map_pixel_x, object.current_map_pixel_y) < self.get_radius + object.get_radius
          end
          if hit_object && self.class.get_aoe <= 0
            # puts "HIT GRAPPLEHOOK HERE" if object.class.name == "GrapplingHook"
            trigger_object_collision(object) 
            # puts "GRAPPLE HEALTH WAS: #{object.health}" if object.class.name == "GrapplingHook"
            # drops = drops + result[:drops] if result[:drops].any?
          end
        end
      end
    else
      # puts "PROJECTILE HAD NO HEALTH: #{@health} - #{@test_hit_max_distance} - #{self.health}"
    end
    if hit_object && self.class.get_aoe > 0
      object_groups.each do |group|
        group.each do |object|
          next if object.nil?
          trigger_aoe_object_collision(object)
          # drops = drops + result[:drops] if result[:drops].any?
        end
      end
    end

    # Drop projectile explosions
    if hit_object
      # puts "HIT OBJECT"
      # puts "#{self.class.name} HIT OBJECT"
      # if self.respond_to?(:drops)
      #   self.drops.each do |drop|
      #     drops << drop
      #   end
      # end

      if self.class::POST_DESTRUCTION_EFFECTS
        # puts "AADDING GRAPHICAL EEFFECTS"
        self.get_post_destruction_effects.each do |effect|
          # puts "COUNT 1 herer"
          graphical_effects << effect
        end
      end
    end

    # @health = 0 if hit_object
    @health = self.take_damage(@health) if hit_object
    # puts "COLLICION RETURNING DROPS: #{drops}" if drops.any?
    # return {is_alive: @health > 0, graphical_effects: graphical_effects}
    return {graphical_effects: graphical_effects}
  end

  protected

  def trigger_aoe_object_collision object
    raise "CURRENTLY UNSUPPORTED"
    # value = {drops: []}
    # if Gosu.distance(@x, @y, object.x, object.y) < self.class.get_aoe * @height_scale
    #   if object.respond_to?(:health) && object.respond_to?(:take_damage)
    #     object.take_damage(self.class.get_damage * @damage_increase)
    #   end

    #   # if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)
    #   #   object.drops.each do |drop|
    #   #     value[:drops] << drop
    #   #   end
    #   # end
    # end
    return value
  end

  def trigger_object_collision(object)
    object.take_damage(self.class.get_damage * @damage_increase)
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
    return true #[[x_min, y_min], [x_max, y_max]]
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