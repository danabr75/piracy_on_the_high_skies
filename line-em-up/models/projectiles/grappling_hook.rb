require_relative 'projectile.rb'
require 'gosu'
# # require 'opengl'
# # require 'glu'

# # require 'opengl'
require 'glut'


# include OpenGL
# include GLUT

# For opengl-bindings
# OpenGL.load_lib()

# GLUT.load_lib()

module Projectiles
  class GrapplingHook < Projectile
    MAX_SPEED      = 3
    STARTING_SPEED = 3
    INITIAL_DELAY  = false
    SPEED_INCREASE_FACTOR = 2
    DAMAGE = 0
    AOE = 0
    MAX_TILE_LENGTH = 2.2
    MAX_TILE_TRAVEL = nil
    BREAKING_POINT_TILE_LENGTH = 15
    HIT_OBJECT_CLASS_FILTER = [:ship, :building]
    # BOARDING_TILE_DISTANCE = 0.5
    PULL_STRENGTH = 1.0
    MAX_TIME_ALIVE = nil
    # seperate from normal alive max. Only dies when not grappled to something
    GRAPPLE_MAX_TIME_ALIVE = 1200
    HEALTH = 5

    # MAX_CURSOR_FOLLOW = 4
    # ADVANCED_HIT_BOX_DETECTION = true
    attr_reader :dissengage
    attr_reader :attached_target

    # Might not be necessary to override
    def initialize(current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, z_projectile, options = {})
      super(current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, z_projectile, options)
      # @image_radius = @image_radius  * 16.0
      # @image_width  = @image_width * 4.0
      # @image_height = @image_height * 4.0
      # @image_size   = @image_size * 4.0
      # @image_radius = @image_radius * 4.0
      # @image_width_half  = @image_width_half * 4.0
      # @image_height_half = @image_height_half * 4.0

      # @image_radius = @image_radius * 4.0

      @chain_image = get_chain_image
      if @image
        @chain_image_width  = @chain_image.width  * (@width_scale)
        @chain_image_height = @chain_image.height * (@height_scale)
        @chain_image_size   = @chain_image_width  * @chain_image_height / 2
        @chain_image_radius = (@chain_image_width  + @chain_image_height) / 4
      end
      @player_reference = nil
      @hp_reference     = options[:hp_reference]
      @dissengage = false
      @returning_to_player  = false
      @attached_target = nil
      @boarding_tile_distance = nil# self.class::BOARDING_TILE_DISTANCE * @average_tile_size
      @pull_strength = self.class::PULL_STRENGTH * @average_scale
      @breaking_point_tile_length = self.class::BREAKING_POINT_TILE_LENGTH * @average_tile_size
      @z_projectile = z_projectile
    end

    def detach_hook
      @dissengage = true
    end
    def self.get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/grappling_hook.png")
    end
    def get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/grappling_hook.png")
    end
    def get_chain_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/grappling_hook_launcher/chain.png")
    end
    def self.get_chain_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/grappling_hook_launcher/chain.png")
    end

    def drops
      [
        # Add back in once SE has been updated to display on map, not on screen.
        # SmallExplosion.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y, nil, {ttl: 2, third_scale: true}),
      ]
    end

    def is_alive
      @health > 0 || !@attached_target.nil?
    end

    def take_damage damage, owner = nil
      if @attached_target.nil?
        @health -= damage
      end
      if @health < 0
        @dissengage = true
      end
      return @health
    end


    def update_with_args args
      # return 
      test = update(args[0], args[1], args[2], args[3])
      # puts "GRAPPLE HOOK UPdATE with args - #{test}"
      return test
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
      # puts "UPDATING GRAPPLING HOOK HERE: #{@attached_target.class} - #{@health}"
      @player_map_pixel_x = player_map_pixel_x
      @player_map_pixel_y = player_map_pixel_y
      returning_to_object = @hp_reference || @owner
      distance = Gosu.distance(returning_to_object.current_map_pixel_x, returning_to_object.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y)
      if @returning_to_player
        if distance < returning_to_object.get_radius + self.get_radius #* 3.0
          @dissengage = true
        end
      end

      if @returning_to_player
        @attached_target = nil
        start_point = OpenStruct.new(:x => current_map_pixel_x,     :y => current_map_pixel_y)
        end_point   = OpenStruct.new(:x => returning_to_object.current_map_pixel_x, :y => returning_to_object.current_map_pixel_y)
        @angle = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
      end
      if @attached_target
        # Angle from owner to tarket
        start_point = OpenStruct.new(:x => @attached_target.current_map_pixel_x,     :y => @attached_target.current_map_pixel_y)
        end_point   = OpenStruct.new(:x => returning_to_object.current_map_pixel_x, :y => returning_to_object.current_map_pixel_y)
        angle_to_origin = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
        # Reversing direction
        # angle_to_origin = self.class.angle_1to360(angle_to_origin - 180)
        @attached_target.movement(@pull_strength, angle_to_origin)
        @owner.movement(@pull_strength, angle_to_origin + 180)

        @current_map_pixel_x = @attached_target.current_map_pixel_x
        @current_map_pixel_y = @attached_target.current_map_pixel_y

        if Gosu.distance(@attached_target.current_map_pixel_x, @attached_target.current_map_pixel_y, returning_to_object.current_map_pixel_x, returning_to_object.current_map_pixel_y) < @boarding_tile_distance
          #  trigger boarding process HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          @dissengage = true
        end
      end

      if @attached_target.nil? && !@returning_to_player && distance >= MAX_TILE_LENGTH * @average_tile_size
        # Sneaky way of skipping collision detection after hitting object
        @hit_objects_class_filter = []
        @returning_to_player = true
        @speed = @speed * 0.8
      end

      if @attached_target 
        keep_alive_if_attached = true
      else
        keep_alive_if_attached = super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)[:is_alive]
      end

      # Chain breaking point
      if Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, returning_to_object.current_map_pixel_x, returning_to_object.current_map_pixel_y) > @breaking_point_tile_length
        @dissengage = true
      end

      # To release it from being tracked from the launcher. 
      # Dissengaging doubles cooldown
      if @dissengage
        # @health = 0
        # puts "SETTING COOLDOWN DELY HERE. #{@hp_reference.item.class} - #{@hp_reference.item.class::COOLDOWN_DELAY}"
        # Should be handled on the launcher.. not the projectile.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        @hp_reference.item.cooldown_wait = @hp_reference.item.class::COOLDOWN_DELAY # * 5.0
        if @hp_reference.item.cooldown_penalty > 0
          # puts "RIGHT HERE: #{@hp_reference.item.cooldown_penalty}  + #{@hp_reference.item.cooldown_wait}"
          @hp_reference.item.cooldown_wait    = @hp_reference.item.cooldown_penalty + @hp_reference.item.cooldown_wait
          @hp_reference.item.cooldown_penalty = 0
        end
        # puts "@hp_reference.item.cooldown_wait: #{@hp_reference.item.cooldown_wait}"
      end

      # return !@dissengage && super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
      if !@attached_target 
        @health = self.take_damage(@health) if self.class::GRAPPLE_MAX_TIME_ALIVE && @time_alive >= self.class::GRAPPLE_MAX_TIME_ALIVE
      end
      # puts "RETURNING GRAPPLE HOOK: isalive: #{!@dissengage && keep_alive_if_attached}   which is #{@dissengage} - #{keep_alive_if_attached}"
      return {is_alive: !@dissengage && keep_alive_if_attached, graphical_effects: []}
    end

    def draw viewable_pixel_offset_x, viewable_pixel_offset_y
      # disable chain
      if @player_map_pixel_x
        returning_to_object = @hp_reference || @owner
        start_point = OpenStruct.new(:x => current_map_pixel_x,     :y => current_map_pixel_y)
        end_point   = OpenStruct.new(:x => returning_to_object.current_map_pixel_x, :y => returning_to_object.current_map_pixel_y)
        angle_to_origin = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
        # Reversing direction
        angle_to_origin = self.class.angle_1to360(angle_to_origin - 180)
        # distance = Gosu.distance(player.current_map_pixel_x, player.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y)
        # if @returning_to_player 
        #   if distance < player.get_radius
        #     returned_to_player = true
        #   end
        # end
        step = (Math::PI/180 * (angle_to_origin + 90))
        base = @chain_image_radius #* 1.2
        new_x = Math.cos(step) * base + @current_map_pixel_x
        new_y = Math.sin(step) * base + @current_map_pixel_y
        # puts "@hp_reference: RIGHT HERE: #{@hp_reference.current_map_pixel_x} - #{@hp_reference.current_map_pixel_y}"
        i = 0
        # puts "returning_to_object.get_radius: #{returning_to_object.get_radius} - #{returning_to_object.class}"
        while i < 300 && Gosu.distance(returning_to_object.current_map_pixel_x, returning_to_object.current_map_pixel_y, new_x, new_y) > (returning_to_object.get_radius + self.get_radius)#* 4.0)
          x, y = GeneralObject.convert_map_pixel_location_to_screen(@player_map_pixel_x, @player_map_pixel_y, new_x, new_y, @screen_pixel_width, @screen_pixel_height)
          @chain_image.draw_rot(x + viewable_pixel_offset_x, y - viewable_pixel_offset_y, @z_projectile, -@current_image_angle, 0.5, 0.5, @height_scale_with_image_scaler, @height_scale_with_image_scaler)
          #
          step = (Math::PI/180 * (angle_to_origin + 90))
          new_x = Math.cos(step) * base + new_x
          new_y = Math.sin(step) * base + new_y
          i += 1
        end
        # # A little past the returning object.
        # (0..1).each do |i|
        #   x, y = GeneralObject.convert_map_pixel_location_to_screen(@owner_map_pixel_x, @owner_map_pixel_y, new_x, new_y, @screen_pixel_width, @screen_pixel_height)
        #   @chain_image.draw_rot(x + viewable_pixel_offset_x, y - viewable_pixel_offset_y, @z_projectile, -@current_image_angle, 0.5, 0.5, @height_scale_with_image_scaler, @height_scale_with_image_scaler)
        #   #
        #   step = (Math::PI/180 * (angle_to_origin + 90))
        #   new_x = Math.cos(step) * base + new_x
        #   new_y = Math.sin(step) * base + new_y
        #   i += 1
        # end
      end


      # @chain_image.draw_rot(@x, @y, ZOrder::Projectile, -@current_image_angle, 0.5, 0.5, @height_scale, @height_scale)
      if @attached_target
        # No need to draw if attached
      else
        super(viewable_pixel_offset_x, viewable_pixel_offset_y)
      end
    end


    def trigger_object_collision(object)
      # puts "GRAPPLE HIT SOMETHING: #{object.class} - self.health: #{@health}"
      @attached_target = object
      @boarding_tile_distance = (object.get_radius + @owner.get_radius) / 2.0
      # Sneaky way of skipping collision detection after hitting object
      @hit_objects_class_filter = []
      # @invulnerable = true
    end



  end
end