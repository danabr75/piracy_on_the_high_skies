require 'opengl'
require 'glu'
require 'glut'

#used to be launcher

module HardpointObjects
  class HardpointObject < GeneralObject
    attr_accessor :x, :y, :active, :projectiles, :image_path, :test, :inited, :cooldown_wait, :cooldown_penalty
    # DAMAGE = 0.001
    COOLDOWN_DELAY = 45
    ACTIVE_DELAY = nil
    # Friendly projects are + speeds
    MAX_SPEED      = 15

    HARDPOINT_NAME = "replace_me"  
    HARDPOINT_DIR = MEDIA_DIRECTORY + "/hardpoints/" + HARDPOINT_NAME
    PROJECTILE_CLASS = nil
    ACTIVE_PROJECTILE_LIMIT = nil
    STORE_RARITY = 1 # 1 is lowest, cap it at 100
    RARITY_MAX   = 100
    # Send these to GeneralObject as well. Have GeneralObject validate.
    ABSTRACT_CLASS = false
    EXPECTED_IMAGE_PIXEL_HEIGHT = 128
    EXPECTED_IMAGE_PIXEL_WIDTH  = 128
    IMAGE_SCALER = 16.0

    STEAM_POWER_USAGE = 1.0

    SHOW_READY_PROJECTILE = false

    SHOW_HARDPOINT_BASE = false

    LAUNCHER_MIN_ANGLE    = nil
    LAUNCHER_MAX_ANGLE    = nil
    LAUNCHER_ROTATE_SPEED = nil

    IS_DESTRUCTABLE_PROJECTILE = false

    # POST_DESTRUCTION_EFFECTS = false

    # def get_post_destruction_effects
    #   raise 'override me'
    #   return []
    # end


    def initialize(options = {})
      @image = self.class.get_hardpoint_image
      super(options)

      @active = false
      @within_angle = false
      @projectiles = []
      @image_optional = self.class.get_image#Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")

      @inited = true
      @cooldown_wait = 0
      # necessary for startup
      @active_for  = 0
      @spinning_up = false
      @spinning_up_sound = self.class.get_starting_sound
      @cooldown_penalty = 0
      if self.class::SHOW_HARDPOINT_BASE
        @image_base = self.class.get_hardpoint_base_image
      end

      @firing_angle_offset = 0
      @destination_angle   = 0
    end

    def self.get_starting_sound
      return nil
    end

    def init_projectile hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options = {}
     # puts "INIT PROJECTILLE HERE"
      validate_not_nil([options], self.class.name, __callee__)
      options[:hp_reference] = @hp_reference if @hp_reference
      # validate_not_nil([current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y], self.class.name, __callee__)
      self.class::PROJECTILE_CLASS.new(
        current_map_pixel_x, current_map_pixel_y, 
        destination_angle, start_point, end_point,
        self.class::LAUNCHER_MIN_ANGLE + hardpoint_firing_angle, self.class::LAUNCHER_MAX_ANGLE + hardpoint_firing_angle, hardpoint_firing_angle,
        current_map_tile_x, current_map_tile_y,
        owner, options
      )
    end


    def get_steam_usage
      return self.class::STEAM_POWER_USAGE
    end

    def attack hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options = {}
      validate_not_nil([options], self.class.name, __callee__) 
      # HARDPOINT FIRING ANGLE: -90
      # puts "HARDPOINT FIRING ANGLE: #{hardpoint_firing_angle}"
      angle_min = self.class.angle_1to360(self.class::LAUNCHER_MIN_ANGLE + hardpoint_firing_angle)
      angle_max = self.class.angle_1to360(self.class::LAUNCHER_MAX_ANGLE + hardpoint_firing_angle)

     # puts "OWNER: #{options[:owner]}"
     # puts "TRYING TO ATTACK: - #{self.class.name}"
      test2 = is_angle_between_two_angles?(@destination_angle, angle_min, angle_max)
     # puts "WAS IT BETWEEN ANGLES? #{test2}"
      # if is_angle_between_two_angles?(@destination_angle, angle_min, angle_max)
      projectile = nil
      destructable_projectile = nil
      graphical_effects = []
      if test2
       # puts "BETWEEN ANGLES"
        @within_angle = true

        if !self.class::ACTIVE_DELAY.nil? && @active
          @active_for += 1                       if @active_for != self.class::ACTIVE_DELAY
          @active_for = self.class::ACTIVE_DELAY if @active_for > self.class::ACTIVE_DELAY
        end
        # puts " HWAT SI GOING ON HERE: @active_for #{@active_for} - @active #{@active}"

        if @cooldown_wait <= 0 && (self.class::ACTIVE_PROJECTILE_LIMIT.nil? || @projectiles.count < self.class::ACTIVE_PROJECTILE_LIMIT)
          # puts "TEST!!!!!" if self.class::ACTIVE_PROJECTILE_LIMIT != nil
          # puts "LAUCHING ATTACK HERE #{@projectiles.count} and limit: #{self.class::ACTIVE_PROJECTILE_LIMIT}" if self.class::ACTIVE_PROJECTILE_LIMIT != nil
          # puts "REACTIVATING LAUNCHER"
          @active = true
          # puts "HERE: self.class::ACTIVE_DELAY < @active_for: #{self.class::ACTIVE_DELAY < @active_for} = #{self.class::ACTIVE_DELAY} < #{@active_for}"
          if self.class::ACTIVE_DELAY.nil? || self.class::ACTIVE_DELAY <= @active_for
           # puts "TRYING TO ATTACK "
            if owner.use_steam(self.class::STEAM_POWER_USAGE)
             # puts "USED STEAM HERE"
              @spinning_up = false
              # raise "STOP HERE: + #{get_steam_usage}"
              # puts "#{owner.use_steam(get_steam_usage)} = owner.use_steam(#{get_steam_usage})"
              if self.class::LAUNCHER_ROTATE_SPEED
                item = init_projectile(hardpoint_firing_angle + @firing_angle_offset, current_map_pixel_x, current_map_pixel_y, hardpoint_firing_angle + @firing_angle_offset, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options)
              else
                item = init_projectile(hardpoint_firing_angle + @firing_angle_offset, current_map_pixel_x, current_map_pixel_y, @destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options)
              end
              if self.class::IS_DESTRUCTABLE_PROJECTILE
                destructable_projectile = item
              else
                projectile = item
              end
              # if self.class::POST_DESTRUCTION_EFFECTS
              #   self.get_post_destruction_effects.each do |effect|
              #     graphical_effects << effect
              #   end
              # end
              @projectiles << item if !self.class::ACTIVE_PROJECTILE_LIMIT.nil?
              @cooldown_wait = get_cooldown
            end
          else
            @spinning_up_sound.play(@effects_volume, 1, false) if @spinning_up_sound && @active_for == 0 #&& @spinning_up == false
            @spinning_up = true
          end
          effects = []
          if projectile || destructable_projectile
            # effect = Graphics::AngledSmoke.new(
            #   @current_map_pixel_x, @current_map_pixel_y, 1, @destination_angle, nil, @width_scale,
            #   @height_scale, @screen_pixel_width, @screen_pixel_height,
            #   {
            #     green: 35, blue: 13, decay_rate_multiplier: 15.0, shift_blue: true, shift_green: true,
            #     scale_multiplier: 0.25
            #   }
            # )
            # effects << effect
          end

          return {projectile: projectile, destructable_projectile: destructable_projectile, effects: effects, graphical_effects: graphical_effects}
        end
      else
        @within_angle = false
        # puts "ANGLE WAS NOT BETWEEN TWO ANGLES: #{destination_angle} w #{angle_min} and #{angle_max}"
      end
      return {projectile: nil, destructable_projectile: nil, effects: [], graphical_effects: graphical_effects}
    end

    def self.get_hardpoint_media_location
      MEDIA_DIRECTORY + "/hardpoints/" + HARDPOINT_NAME
    end

    # # Hate to have to use a parameter for this, seems so simple
    # def self.get_hardpoint_image
    #   # # puts "RIGHT HERE: #{HARDPOINT_NAME}"
    #   # using_name = hardpoint_name || HARDPOINT_NAME
    #   raise "You forgot to override the launcher's 'HARDPOINT_NAME' here - for this class: #{self.name}"
    #   # # puts "HERE IT IS: #{self.class.name} with #{get_hardpoint_media_location}"
    #   # Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{using_name}/hardpoint.png")
    # end
    def self.get_hardpoint_image
      Gosu::Image.new("#{self::MEDIA_DIRECTORY}/hardpoints/#{self::HARDPOINT_NAME}/hardpoint.png")
    end
    def self.get_hardpoint_base_image
      Gosu::Image.new("#{self::MEDIA_DIRECTORY}/hardpoints/#{self::HARDPOINT_NAME}/hardpoint_base.png")
    end

    def get_cooldown
      self.class::COOLDOWN_DELAY
    end

    # # Used via hardpoint
    # def self.get_hardpoint_image
    #   # raise "Override me"
    #   # default
    #   Gosu::Image.new("#{MEDIA_DIRECTORY}/laser_beam_hardpoint.png")
    # end

    # Get image is called before the initialization is complete
    def self.get_image
      # optional image
      # Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
      # raise "OVERRIDE ME"
    end

    def self.get_hardpoint_image_base
      raise "OVERRIDE ME"
    end

    def get_hardpoint_image
      # default
      self.class.get_hardpoint_image
      # Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
    end

    def deactivate
      @active = false
      # @active_for = 0
      @spinning_up = false
      @within_angle = false
      # @projectiles.each do |particle|
      #   particle.active = false
      # end
    end

    # def rotate_towards_destination angle_diff
    #   if angle_diff > 0.0
    #     rotate_clockwise
    #   else
    #     rotate_counterclockwise
    #   end
    # end
    # def rotate_clockwise
    #   # puts "ROTATING AI"
    #   increment = @rotation_speed
    #   if @angle - increment <= 0
    #     @angle = (@angle - increment) + 360
    #   else
    #     @angle -= increment
    #   end
    #   @ship.angle = @angle
    #   # @ship.rotate_hardpoints_clockwise(increment.to_f)
    #   return 1
    # end
    # def rotate_counterclockwise
    #   # puts "ROTATING COUNTER AI"
    #   increment = @rotation_speed
    #   if @angle + increment >= 360
    #     @angle = (@angle + increment) - 360
    #   else
    #     @angle += increment
    #   end
    #   @ship.angle = @angle
    #   # @ship.rotate_hardpoints_counterclockwise(increment.to_f)
    #   return 1
    # end

    # This section is somehwat outdated.
    def update mouse_x = nil, mouse_y = nil, object = nil, hardpoint_angle = nil, current_map_pixel_x = nil, current_map_pixel_y = nil, attackable_location_x = nil, attackable_location_y = nil
     # puts "HARDPOINT OBJECT UPDATE - #{self.class.name}"
      # return true unless self.class.name == "HardpointObjects::GrapplingHookHardpoint"
      # puts [mouse_x, mouse_y, hardpoint_angle, current_map_pixel_x, current_map_pixel_y, attackable_location_x, attackable_location_y]
      # HARDPOINT UPDATE ANGLE (ship_angle): 0
      # puts "HARDPOINT UPDATE ANGLE (hardpoint_angle): #{hardpoint_angle}"
      # puts "MINIGUN ACTIVE FOR: #{@active_for}"
      # Moving to attack section
      # if !self.class::ACTIVE_DELAY.nil? && @active
      #   @active_for += 1                       if @active_for != self.class::ACTIVE_DELAY
      #   @active_for = self.class::ACTIVE_DELAY if @active_for > self.class::ACTIVE_DELAY
      # end
      # puts "RIGHT HERE TEST"
      # puts [@current_map_pixel_x, @current_map_pixel_y, attackable_location_x, attackable_location_y]
      if attackable_location_x && attackable_location_y
       # puts "FOUND ATTACKABKE LOCATION X AND Y"
        if self.class::LAUNCHER_MIN_ANGLE && self.class::LAUNCHER_MAX_ANGLE
          # puts "@firing_angle_offset: #{@firing_angle_offset}"
          start_point = OpenStruct.new(:x => current_map_pixel_x,   :y => current_map_pixel_y)
         # puts "START POINT: #{current_map_pixel_x} - #{current_map_pixel_y}"
          end_point   = OpenStruct.new(:x => attackable_location_x, :y => attackable_location_y)
         # puts "TARGET: #{attackable_location_x} - #{attackable_location_y}"
          # Reorienting angle to make 0 north
          @destination_angle = self.class.angle_1to360(-(self.class.calc_angle(start_point, end_point) - 90))
         # puts "DESTINATIONANGLE: #{@destination_angle}"
          # puts "self.class.angle_1to360(self.class::LAUNCHER_MIN_ANGLE + ship_angle)"
          # puts "self.class.angle_1to360(#{self.class::LAUNCHER_MIN_ANGLE} + #{ship_angle})"
          angle_min = self.class.angle_1to360(self.class::LAUNCHER_MIN_ANGLE + hardpoint_angle)
         # puts "MIN - #{self.class::LAUNCHER_MIN_ANGLE} - #{hardpoint_angle}"
          angle_max = self.class.angle_1to360(self.class::LAUNCHER_MAX_ANGLE + hardpoint_angle)
         # puts "MAX - #{self.class::LAUNCHER_MAX_ANGLE} - #{hardpoint_angle}"

          # puts "@firing_angle_offset: #{@firing_angle_offset}"
          test = is_angle_between_two_angles?(@destination_angle, angle_min, angle_max)
         # puts "WAS IT BBETWEEN ANGLES: #{test} - input was: #{@destination_angle} - #{angle_min} - #{angle_max}"
            # DESTINATIONANGLE: 338.1777146603222
            # MIN - -60 - 180.43599999999506
            # MAX - 60 - 180.43599999999506

            # WAS IT BBETWEEN ANGLES: false
            # input was: 338.1777146603222 - 120.43599999999506 - 240.43599999999506

          if test
            # if self.class::LAUNCHER_ROTATE_SPEED
            # @within_angle = true
           # puts "IS WITHIN ANGLE"
            current_angle = self.class.angle_1to360(hardpoint_angle + @firing_angle_offset)
            # puts "DESTINATION AND CURRENT ANGLE: #{@destination_angle} - #{current_angle}"
            if @destination_angle != current_angle
              angle_diff  = GeneralObject.angle_diff(@destination_angle, current_angle)
              # puts "ANGLED DIFF: #{angle_diff}"

              # if angle_diff > 0.0 && angle_diff.abs > self.class::LAUNCHER_ROTATE_SPEED
              if angle_diff > 0.0 # && angle_diff.abs > self.class::LAUNCHER_ROTATE_SPEED
                # @firing_angle_offset += self.class::LAUNCHER_ROTATE_SPEED
                @firing_angle_offset -= self.class::LAUNCHER_ROTATE_SPEED

                # @firing_angle_offset = @destination_angle - hardpoint_angle if @firing_angle_offset < @destination_angle - hardpoint_angle

                # puts "CASE 1"
                # puts "1-@firing_angle_offset = @destination_angle - hardpoint_angle if @firing_angle_offset > @destination_angle - hardpoint_angle"
                # puts "2-#{@firing_angle_offset} = #{@destination_angle} - #{hardpoint_angle} if #{@firing_angle_offset} > #{@destination_angle} - #{hardpoint_angle}"
                # puts "3-#{@firing_angle_offset} = #{@destination_angle - hardpoint_angle} if #{@firing_angle_offset} > #{@destination_angle - hardpoint_angle}"
              elsif angle_diff < 0.0 # && angle_diff.abs > self.class::LAUNCHER_ROTATE_SPEED
                @firing_angle_offset += self.class::LAUNCHER_ROTATE_SPEED

                # @firing_angle_offset = @destination_angle - hardpoint_angle if @firing_angle_offset > @destination_angle - hardpoint_angle

                # puts "CASE 2"
                # puts "1-@firing_angle_offset = @destination_angle - hardpoint_angle if @firing_angle_offset > @destination_angle - hardpoint_angle"
                # puts "2-#{@firing_angle_offset} = #{@destination_angle} - #{hardpoint_angle} if #{@firing_angle_offset} < #{@destination_angle} - #{hardpoint_angle}"
                # puts "3-#{@firing_angle_offset} = #{@destination_angle - hardpoint_angle} if #{@firing_angle_offset} < #{@destination_angle - hardpoint_angle}"
              end
            end
            # @destination_angle   = 0
          elsif @firing_angle_offset != 0.0
           # puts "NOT WITHIN ANGLE  self.class.name: #{self.class.name}"
           # puts [@destination_angle, angle_min, angle_max]
           # puts "ADJUSTING ANGLE OFFSET HERE: #{@firing_angle_offset}"
            if @firing_angle_offset > 0.0
              @firing_angle_offset -= self.class::LAUNCHER_ROTATE_SPEED
              @firing_angle_offset = 0.0 if @firing_angle_offset < 0.0
            elsif @firing_angle_offset < 0.0
              @firing_angle_offset += self.class::LAUNCHER_ROTATE_SPEED
              @firing_angle_offset = 0.0 if @firing_angle_offset > 0.0
            end
          end
        end
      end

     
      if !self.class::ACTIVE_DELAY.nil? && (!@within_angle || !@active) && @active_for > 0
        if !@active
          @active_for -= 5   if @active_for != 0.0
          @active_for  = 0   if @active_for <  0.0
        else
          @active_for -= 0.3 if @active_for != 0.0
          @active_for  = 0   if @active_for <  0.0
        end
      end

      # @spinning_up_sound.play(@effects_volume, 1, false) if @spinning_up && @spinning_up_sound 
      # if @inited && @active
        # @x = object.x
        # @y = object.y
      # end
      @cooldown_wait -= 1.0 if @cooldown_wait > 0.0
      if !@active && @projectiles.count == 0
        return false
      else
        @projectiles.reject! do |projectile|
          !projectile.is_alive
        end

        return true
      end
    end

    def get_draw_ordering
      ZOrder::Launcher
    end

    # Furthest active particle in active beam
    # def get_furthest_active_particle
    #   last_active_particle = nil
    #   if @active
    #     @projectiles.reverse.each do |lp|
    #       if lp.active && lp.y_is_on_screen
    #         last_active_particle = lp
    #       else
    #         break
    #       end

    #     end
    #   end
    #   return last_active_particle
    # end

    def draw angle, x, y, z, z_base
      # puts "HARDPOINT DRAW: #{self.class::SHOW_READY_PROJECTILE} - #{SHOW_READY_PROJECTILE}"
      if self.class::SHOW_READY_PROJECTILE
        if @cooldown_wait <= 0.0
          self.class::PROJECTILE_CLASS.get_image.draw_rot(x, y, self.class::PROJECTILE_CLASS::DRAW_ORDER, angle - @firing_angle_offset, 0.5, 0.5, @height_scale / self.class::PROJECTILE_CLASS::IMAGE_SCALER, @height_scale / self.class::PROJECTILE_CLASS::IMAGE_SCALER)
        end
      end
      @image.draw_rot(x, y, z, angle - @firing_angle_offset, 0.5, 0.5, @height_scale, @height_scale)

      if self.class::SHOW_HARDPOINT_BASE
        @image_base.draw_rot(x, y, z_base, angle - @firing_angle_offset, 0.5, 0.5, @height_scale, @height_scale)
      end

    end

    # def draw_gl
    #   # if @inited
    #   #   z = ZOrder::Projectile
    #   #   new_width1, new_height1, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y - @image_height_half/2, @screen_pixel_width         , @screen_pixel_height)
    #   #   new_width2, new_height2, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x, @y + @image_height_half/2, @screen_pixel_width         , @screen_pixel_height)
    #   #   new_width3, new_height3, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y - @image_height_half/2, @screen_pixel_width         , @screen_pixel_height)

    #   #   glEnable(GL_BLEND)
    #   #   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    #   #   glBegin(GL_TRIANGLES)
    #   #     glColor4f(0, 1, 0, 0.2)
    #   #     glVertex3f(new_width1, new_height1, 0.0)
    #   #     glVertex3f(new_width2, new_height2, 0.0)
    #   #     glVertex3f(new_width3, new_height3, 0.0)
    #   #   glEnd
    #   # end
    # end
  end
end
