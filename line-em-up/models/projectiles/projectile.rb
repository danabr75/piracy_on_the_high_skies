require_relative '../screen_map_fixed_object.rb'
# require "#{LIB_DIRECTORY}/z_order.rb"
require_relative '../../lib/z_order.rb'

module Projectiles
  class Projectile < ScreenMapFixedObject
    attr_accessor :x, :y, :time_alive, :vector_x, :vector_y, :angle, :radian
    attr_reader :health
    # WARNING THESE CONSTANTS DON'T GET OVERRIDDEN BY SUBCLASSES. NEED GETTER METHODS
    # COOLDOWN_DELAY = 50
    STARTING_SPEED = 0.1
    MAX_SPEED      = 1
    MIN_SPEED      = nil
    INITIAL_DELAY  = nil
    SPEED_INCREASE_FACTOR    = nil
    SPEED_INCREASE_INCREMENT = nil
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
    POST_COLLISION_EFFECTS = false

    # BLOCK_IMAGE_DRAW = false

    def self.pre_load_setup(height_scale)
      # puts "RIGHT HERE22 - #{self.name}"
      @image = get_image
      @init_sound = get_init_sound
      @init_sound_path = get_init_sound_path

      # the follwing would be useful for collisions
      @image_width  = @image.width  * (height_scale)
      @image_height = @image.height * (height_scale)
      @image_size   = @image_width  * @image_height / 2
      @image_radius = (@image_width  + @image_height) / 4

      @image_width_half  = @image_width  / 2.0
      @image_height_half = @image_height / 2.0

      if IMAGE_SCALER
        @image_width  = @image_width  / IMAGE_SCALER
        @image_height = @image_height / IMAGE_SCALER
        @image_size   = @image_size   / IMAGE_SCALER
        @image_radius = @image_radius / IMAGE_SCALER

        @image_width_half  = @image_width_half  / IMAGE_SCALER
        @image_height_half = @image_height_half / IMAGE_SCALER
      end
    end

    def get_post_destruction_effects
      raise 'override me!'
    end

    def get_post_collided_effects
      raise 'override me!'
    end


    # def self.get_post_destruction_effects
    #   raise 'override me!'
    # end

    def self.get_image
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
    end

    def get_image
      self.class.get_image
    end

    def draw_gl
    end

    # attr_reader :inited

    # destination_map_pixel_x, destination_map_pixel_y params will become destination_angle
    def initialize(current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, z_projectile, options = {})
      # puts "PROJETIL PARALMS"
      # puts "current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options"
      # puts "#{[current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options]}"
      # validate_not_nil([current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y], self.class.name, __callee__)
      options[:no_image] = true
      super(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options)

      @hit_objects_class_filter = self.class::HIT_OBJECT_CLASS_FILTER

      @owner = owner


      @air_to_ground = options[:air_to_ground] ? options[:air_to_ground] : false
      @ground_to_air = options[:ground_to_air] ? options[:ground_to_air] : false
      if @air_to_ground || @ground_to_air
        @z = ZOrder::GroundProjectile
        @ground_distance_to_travel     = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, end_point.x, end_point.y) - (@average_tile_size / 2.0)
        @max_ground_distance_to_travel = @ground_distance_to_travel + (@average_tile_size / 2.0)
        @distance_traveled_so_far = 0

        @was_collidable = false
        # puts "INIT TEST HERE"
        # puts @ground_distance_to_travel
        # puts @max_ground_distance_to_travel
        # puts @distance_traveled_so_far
      else
        @z = z_projectile
      end


      if self.class::MAX_TILE_TRAVEL
        @max_distance = self.class::MAX_TILE_TRAVEL * @average_tile_size
      end
      @start_current_map_pixel_x = @current_map_pixel_x
      @start_current_map_pixel_y = @current_map_pixel_y
      # puts "START PROJ LOCATION: #{@start_current_map_pixel_x} - #{@start_current_map_pixel_y}"

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

      angle_min = self.class.angle_1to360(angle_min) if angle_min
      angle_max = self.class.angle_1to360(angle_max) if angle_max

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
      # @inited = true
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

    # no longer actively used, but keep updated with async_update
    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
      graphical_effects = []
      # puts "PROJ SPEED: #{@speed}"
      if self.is_alive
        # puts "DISTANCE TRAVLED HERE: #{[@start_current_map_pixel_x, @start_current_map_pixel_y]}   against  #{[]}"
        @distance_traveled_so_far = Gosu.distance(@start_current_map_pixel_x, @start_current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y)

        if @air_to_ground
          if @was_collidable && @distance_traveled_so_far >= @max_ground_distance_to_travel
            @health = 0
          else
            @was_collidable = true
          end
        elsif @ground_to_air
          if @was_collidable && @distance_traveled_so_far >= @max_ground_distance_to_travel
            @health = 0
          else
            @was_collidable = true
          end
        end

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
        # puts "TEST HERE: #{self.class::SPEED_INCREASE_INCREMENT}"
        if self.class::INITIAL_DELAY.nil? || self.class::INITIAL_DELAY && (@time_alive > (@custom_initial_delay || self.class::INITIAL_DELAY))
          # puts "(self.class::MAX_SPEED && @speed < self.class::MAX_SPEED) || (self.class::MIN_SPEED && @speed > self.class::MIN_SPEED)"
          # puts "(self.class::MAX_SPEED && #{@speed < self.class::MAX_SPEED}) || (#{self.class::MIN_SPEED} && @speed > self.class::MIN_SPEED)"
          if (self.class::MAX_SPEED && @speed < self.class::MAX_SPEED) || (self.class::MIN_SPEED && @speed > self.class::MIN_SPEED)
            if self.class::SPEED_INCREASE_FACTOR #&& speed_factor > 0.0
              @speed = @speed * (self.class::SPEED_INCREASE_FACTOR)
              # puts "NEW SPEED: #{@speed}"
            end
            
            if !self.class::SPEED_INCREASE_INCREMENT.nil? #&& speed_increment > 0.0
              # puts "cannonval: #{self.class::SPEED_INCREASE_INCREMENT}"
              @speed = @speed + (self.class::SPEED_INCREASE_INCREMENT * @height_scale)
            else
              # puts "cannonval2: #{self.class::SPEED_INCREASE_INCREMENT}"
            end

            @speed = self.class::MAX_SPEED if @speed > self.class::MAX_SPEED
            @speed = self.class::MIN_SPEED if self.class::MIN_SPEED && @speed < self.class::MIN_SPEED
          end

          # puts "SPEED HERE: #{@speed}"
          factor_in_scale_speed = @speed * @height_scale

          movement(factor_in_scale_speed, @angle, true) if factor_in_scale_speed != 0
        else
          @speed = self.class.get_max_speed if @speed.nil?
          factor_in_scale_speed = @speed * @height_scale
          movement(factor_in_scale_speed, @angle, true) if factor_in_scale_speed != 0
        end
        # puts "test123"

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
      # puts "GET DATA"
      test = {
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
        current_map_pixel_x: @current_map_pixel_x.round(2),
        current_map_pixel_y: @current_map_pixel_y.round(2),
        current_map_tile_x: @current_map_tile_x,
        current_map_tile_y: @current_map_tile_y,
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
        klass: self.class.name,
        initial_delay: self.class::INITIAL_DELAY,
        speed_increase_factor: self.class::SPEED_INCREASE_FACTOR,
        speed_increment: self.class::SPEED_INCREASE_INCREMENT,
        max_speed: self.class::MAX_SPEED,
        max_time_alive: self.class::MAX_TIME_ALIVE,
        post_destruction_effects: self.class::POST_DESTRUCTION_EFFECTS,
        start_current_map_pixel_x: @start_current_map_pixel_x,
        start_current_map_pixel_y: @start_current_map_pixel_y,
        air_to_ground: @air_to_ground,
        ground_to_air: @ground_to_air,
        distance_traveled_so_far: @distance_traveled_so_far,
        ground_distance_to_travel: @ground_distance_to_travel,
        max_ground_distance_to_travel: @max_ground_distance_to_travel,
        was_collidable: @was_collidable
      }
      # puts test.inspect
      return test
    end

    def set_data data
      # puts "SETTING DATA" 
      # puts data.inspect
# DATA HERE:
# {"id"=>"a6d82162-894d-413d-919d-f6c0f2bc03a1", "graphical_effects"=>[], "sounds"=>[], "change_map_pixel_x"=>-1.2543415592118417, "change_map_pixel_y"=>-11.934262744420266, "health_change"=>-1, "time_alive"=>100, "change_map_tile_x"=>-0.39996632579804725, "change_map_tile_y"=>18047.9794329952, "is_alive"=>true, "change_x"=>-4.604579138824885e+32, "change_y"=>-3.1788695486682216e+32}

      @health              += data[:health_change]      if data.key?(:health_change)
      # puts "NEW HEALTH: #{@health}"

      @current_map_pixel_x = (@current_map_pixel_x + data[:change_map_pixel_x]).round(4) if data.key?(:change_map_pixel_x)
      @current_map_pixel_y = (@current_map_pixel_y + data[:change_map_pixel_y]).round(4) if data.key?(:change_map_pixel_y)

      @current_map_tile_x += data[:change_map_tile_x]   if data.key?(:change_map_tile_x)
      @current_map_tile_y += data[:change_map_tile_y]   if data.key?(:change_map_tile_y)
      @current_image_angle += data[:change_image_angle] if data.key?(:change_image_angle)
      @speed               += data[:change_speed]       if data.key?(:change_speed)
      @x                   = (@x - data[:change_x]).round(4)           if data.key?(:change_x)
      @x                   = data[:x]                   if data.key?(:x)
      @y                   = (@y - data[:change_y]).round(4)           if data.key?(:change_y)
      @y                   = data[:y]                   if data.key?(:y)
      @time_alive          = data[:time_alive]         if data.key?(:time_alive)
      @play_init_sound     = data[:play_init_sound]    if data.key?(:play_init_sound)
      @is_on_screen        = data[:is_on_screen]     if data.key?(:is_on_screen)
      @is_alive            = data[:is_alive]         if data.key?(:is_alive)
      @air_to_ground       = data[:air_to_ground]    if data.key?(:air_to_ground)
      @ground_to_air       = data[:ground_to_air]    if data.key?(:ground_to_air)
      @distance_traveled_so_far = data[:distance_traveled_so_far] if data.key?(:distance_traveled_so_far)
      @was_collidable      = data[:was_collidable] if data.key?(:was_collidable)

      # puts "SET DATA ON PROJ, new x and y #{@x} - #{@y}"
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
      # There were issues that converted these to strings, but I think they're fixed now.. could remove these
      data[:current_map_pixel_x] = data[:current_map_pixel_x].to_i if data[:current_map_pixel_x].class == String
      data[:current_map_pixel_y] = data[:current_map_pixel_y].to_i if data[:current_map_pixel_y].class == String
      data[:x] = data[:x].to_i if data[:x].class == String
      data[:y] = data[:y].to_i if data[:y].class == String

      # raise "ISSIUE HERE: #{data.inspect}"
      results[:id] = data[:id]
      results[:graphical_effects] ||= []
      results[:sounds] ||= []
      # puts "PROJ SPEED: #{data[:speed]}"


      results[:distance_traveled_so_far] = Gosu.distance(data[:current_map_pixel_x], data[:current_map_pixel_y], data[:start_current_map_pixel_x], data[:start_current_map_pixel_y])

      if data[:air_to_ground]
        if data[:was_collidable] && data[:distance_traveled_so_far] >= data[:max_ground_distance_to_travel]
          results[:health] = 0
        else
          results[:was_collidable] = true
        end
      elsif data[:ground_to_air]
        if data[:was_collidable] && data[:distance_traveled_so_far] >= data[:max_ground_distance_to_travel]
          results[:health] = 0
        else
          results[:was_collidable] = true
        end
      end

      if data[:refresh_angle_on_updates] && data[:end_image_angle] && data[:time_alive] > 10
        if data[:current_image_angle] != data[:end_image_angle]
          data[:current_image_angle] = data[:current_image_angle] + data[:image_angle_incrementor]
          # if it's negative
          if data[:image_angle_incrementor] < 0
            data[:current_image_angle] = data[:end_image_angle] if data[:current_image_angle] < data[:end_image_angle] 
          # it's positive
          elsif data[:image_angle_incrementor] > 0
            data[:current_image_angle] = data[:end_image_angle] if data[:current_image_angle] > data[:end_image_angle] 
          end
        end
      end

      if data[:initial_delay] && (data[:time_alive] > (data[:custom_initial_delay] || data[:initial_delay]))
        speed_factor = data[:speed_increase_factor]
        if data[:speed] < data[:max_speed]
          if speed_factor && speed_factor > 0.0
            data[:speed] = data[:speed] + (data[:time_alive] * speed_factor)
          end
          # speed_increment = get_speed_increase_increment
          if data[:speed_increment] && data[:speed_increment] > 0.0
            data[:speed] = data[:speed] + data[:speed_increment]
          end

          data[:speed] = data[:max_speed] if data[:speed] > data[:max_speed]
        end

        factor_in_scale_speed = data[:speed] * data[:height_scale]
        results[:change_map_pixel_x], results[:change_map_pixel_y] = async_movement(data[:current_map_pixel_x], data[:current_map_pixel_y], factor_in_scale_speed, data[:angle], data[:height_scale]) if factor_in_scale_speed != 0
      else
        data[:speed] = data[:max_speed] if data[:speed].nil?
        factor_in_scale_speed = data[:speed] * data[:height_scale]
        results[:change_map_pixel_x], results[:change_map_pixel_y] = async_movement(data[:current_map_pixel_x], data[:current_map_pixel_y], factor_in_scale_speed, data[:angle], data[:height_scale]) if factor_in_scale_speed != 0
      end

      results[:health_change] = -data[:health] if data[:max_time_alive] && data[:time_alive] >= data[:max_time_alive]


      results.merge(super(data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results))

      if data[:max_distance] && data[:max_distance] < results[:distance_traveled_so_far]
        # puts "should have gotten here."
        results[:health_change] = -data[:health]
      end

      if data[:play_init_sound] && data[:init_sound_path] && data[:is_on_screen]
        results[:sounds] << data[:init_sound_path]
        results[:play_init_sound] = false
      end

      if !async_is_alive(data[:health], results[:health_change])
        if data[:post_destruction_effects]
          get_post_destruction_effects.each do |effect|
            results[:graphical_effects] << effect
          end
        end
      end

      return results
    end





    def draw viewable_pixel_offset_x, viewable_pixel_offset_y
      draw_rot(viewable_pixel_offset_x, viewable_pixel_offset_y)
      # limiting angle extreme by 2
      # if @is_on_screen && !self.class::BLOCK_IMAGE_DRAW
      #   @image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, @z, -@current_image_angle, 0.5, 0.5, @height_scale_with_image_scaler, @height_scale_with_image_scaler)
      # end
      # if @is_on_screen && self.class::DRAW_CLASS_IMAGE
      #   self.class.image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, @z, -@current_image_angle, 0.5, 0.5, @height_scale_with_image_scaler, @height_scale_with_image_scaler)
      # end
    end

    def get_draw_ordering
      @z
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

    def get_radius
      if self.class::USING_CLASS_IMAGE_ATTRIBUTES
        return self.class.image_radius
      else
        super
      end
    end

    # require 'benchmark'

    def hit_objects air_object_groups, ground_object_groups#, options = {}
      # puts "PROJ hit objects"
      graphical_effects = []
      # testing here
      # return {graphical_effects: graphical_effects}
      if @air_to_ground
        if @distance_traveled_so_far < @ground_distance_to_travel
          return {graphical_effects: graphical_effects} 
        elsif @was_collidable && @distance_traveled_so_far >= @max_ground_distance_to_travel
          return {graphical_effects: graphical_effects}
        end
        
        object_groups = ground_object_groups
      elsif @ground_to_air
        if @distance_traveled_so_far < @ground_distance_to_travel
          return {graphical_effects: graphical_effects} 
        elsif @was_collidable && @distance_traveled_so_far >= @max_ground_distance_to_travel
          return {graphical_effects: graphical_effects}
        end
        object_groups = air_object_groups
      else
        object_groups = air_object_groups
      end

      hit_object    = false
      actual_hit_object = nil
      # is_thread = options[:is_thread] || false
      if @health > 0
        object_groups.each do |group|
          # break if @health == 0
          break if hit_object
          group.each do |object_id, object|
            # break if @health == 0
            next if object.nil?
            next if object_id == @id
            next if object_id == @owner.id
            next if object.owner && object.owner.id == @owner.id
            next if !@hit_objects_class_filter.include?(object.class::CLASS_TYPE) if @hit_objects_class_filter
            break if hit_object
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
              trigger_object_collision(object) 
            end
            actual_hit_object = object if hit_object
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

        if self.class::POST_DESTRUCTION_EFFECTS
          self.get_post_destruction_effects.each do |effect|
            graphical_effects << effect
          end
        end
        if actual_hit_object.class::POST_COLLISION_EFFECTS
          actual_hit_object.get_post_collided_effects(@current_map_pixel_x, @current_map_pixel_y).each do |effect|
            graphical_effects << effect
          end
        end
      end

      @health = self.take_damage(@health) if hit_object
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
      object.take_damage(get_damage, @owner)
    end

    def get_damage
      self.class::DAMAGE * @damage_increase
    end

    # def self.get_damage
    #   self::DAMAGE
    # end
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
    # def self.get_speed_increase_factor
    #   self::SPEED_INCREASE_FACTOR
    # end
    # def self.get_speed_increase_increment
    #   self::SPEED_INCREASE_INCREMENT
    # end
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
end