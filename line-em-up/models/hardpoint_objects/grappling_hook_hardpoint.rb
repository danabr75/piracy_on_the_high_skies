module HardpointObjects
  class GrapplingHookHardpoint < HardpointObjects::HardpointObject
    HARDPOINT_NAME = "grappling_hook_launcher"
    LAUNCHER_MIN_ANGLE = -60
    LAUNCHER_MAX_ANGLE = 60
    PROJECTILE_CLASS = GrapplingHook
    FIRING_GROUP_NUMBER = 3
    COOLDOWN_DELAY = 120
    ACTIVE_PROJECTILE_LIMIT = 1

    def initialize(options = {})
      @hp_reference = options[:hp_reference]
      @image_empty = Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
      super(options)
    end

    def self.get_hardpoint_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end


    def draw angle, x, y, z
      if @cooldown_wait <= 0.0 && (self.class::ACTIVE_PROJECTILE_LIMIT.nil? || @projectiles.count < self.class::ACTIVE_PROJECTILE_LIMIT)
        @image.draw_rot(x, y, z, angle, 0.5, 0.5, @width_scale / self.class::IMAGE_SCALER, @height_scale / self.class::IMAGE_SCALER)
      else
        @image_empty.draw_rot(x, y, z, angle, 0.5, 0.5, @width_scale / self.class::IMAGE_SCALER, @height_scale / self.class::IMAGE_SCALER)
      end
    end

    def update mouse_x = nil, mouse_y = nil, object = nil
      @cooldown_wait -= 1.0 if @cooldown_wait > 0.0
      if !@active && @projectiles.count == 0
        return false
      else
        @projectiles.reject! do |hook|
          hook.dissengage
        end

        return true
      end
    end

    # def @active= value
    #   puts "THIS IUS AN ACTIVE TEST HERE"
    #   super(value)
    # end

    # def deactivate
    #   @active = false
    #   @active_for = 0
    # end

    def attack hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options = {}
      angle_min = self.class.angle_1to360(self.class::LAUNCHER_MIN_ANGLE + hardpoint_firing_angle)
      angle_max = self.class.angle_1to360(self.class::LAUNCHER_MAX_ANGLE + hardpoint_firing_angle)
      # puts "GRAPPLING HOOK L ATTACK HERE: #{@active} -test: #{@test}"
      # puts "#{@projectiles.count >= self.class::ACTIVE_PROJECTILE_LIMIT} && #{!@active} && #{is_angle_between_two_angles?(destination_angle, angle_min, angle_max)}"
      # @projectiles.last.time_alive check is to prevent accidental quick double-clicks
      # puts "GRAP ATTACK HERE: #{@active_for}"
      if @projectiles.count >= self.class::ACTIVE_PROJECTILE_LIMIT && !@active && @projectiles.last.time_alive > 15 && is_angle_between_two_angles?(destination_angle, angle_min, angle_max)
        # puts "DETACHING HOOK"
        @cooldown_penalty = self.class::COOLDOWN_DELAY * 2
        @projectiles.each do |hook|
          hook.detach_hook
        end
        return nil
      else
        return super(hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, options)
      end
    end

    def self.name
      "Grappling Hook Launcher"
    end

    def self.description
      return [
        "This is a grappling hook. Allows boarding enemy ships.",
        "Right-click to launch hook. Right-click again to drop hook.",
        "Hook can only Grapple on launch, not on return."
      ]
    end

    def self.value
      500
    end

  end
end