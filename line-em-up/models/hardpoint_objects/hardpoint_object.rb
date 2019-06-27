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
    end

    def self.get_starting_sound
      return nil
    end

    def init_projectile hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options = {}
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

    def attack hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options = {}
      validate_not_nil([options], self.class.name, __callee__) 
      angle_min = self.class.angle_1to360(self.class::LAUNCHER_MIN_ANGLE + hardpoint_firing_angle)
      angle_max = self.class.angle_1to360(self.class::LAUNCHER_MAX_ANGLE + hardpoint_firing_angle)

      if is_angle_between_two_angles?(destination_angle, angle_min, angle_max)
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
            if owner.use_steam(self.class::STEAM_POWER_USAGE)
              @spinning_up = false
              # raise "STOP HERE: + #{get_steam_usage}"
              # puts "#{owner.use_steam(get_steam_usage)} = owner.use_steam(#{get_steam_usage})"
              projectile = init_projectile(hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options)
              @projectiles << projectile if !self.class::ACTIVE_PROJECTILE_LIMIT.nil?
              @cooldown_wait = get_cooldown
            end
          else
            @spinning_up_sound.play(@effects_volume, 1, false) if @spinning_up_sound && @active_for == 0 #&& @spinning_up == false
            @spinning_up = true
          end
          return projectile
        end
      else
        @within_angle = false
        # puts "ANGLE WAS NOT BETWEEN TWO ANGLES: #{destination_angle} w #{angle_min} and #{angle_max}"
      end
    end

    def self.get_hardpoint_media_location
      MEDIA_DIRECTORY + "/hardpoints/" + HARDPOINT_NAME
    end

    # Hate to have to use a parameter for this, seems so simple
    def self.get_hardpoint_image
      # # puts "RIGHT HERE: #{HARDPOINT_NAME}"
      # using_name = hardpoint_name || HARDPOINT_NAME
      raise "You forgot to override the launcher's 'HARDPOINT_NAME' here - for this class: #{self.name}"
      # # puts "HERE IT IS: #{self.class.name} with #{get_hardpoint_media_location}"
      # Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{using_name}/hardpoint.png")
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
    end
    # In generalobject
    # def get_image
    #   self.class.get_image
    # end

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

    # This section is somehwat outdated.
    def update mouse_x = nil, mouse_y = nil, object = nil
      # puts "MINIGUN ACTIVE FOR: #{@active_for}"
      # Moving to attack section
      # if !self.class::ACTIVE_DELAY.nil? && @active
      #   @active_for += 1                       if @active_for != self.class::ACTIVE_DELAY
      #   @active_for = self.class::ACTIVE_DELAY if @active_for > self.class::ACTIVE_DELAY
      # end
     
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

    def draw angle, x, y, z
      @image.draw_rot(x, y, z, angle, 0.5, 0.5, @width_scale / self.class::IMAGE_SCALER, @height_scale / self.class::IMAGE_SCALER)
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
