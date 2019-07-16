require_relative '../projectiles/grappling_hook.rb'
module HardpointObjects
  class GrapplingHookHardpoint < HardpointObjects::HardpointObject
    HARDPOINT_NAME = "grappling_hook_launcher"
    LAUNCHER_MIN_ANGLE = -60
    LAUNCHER_MAX_ANGLE = 60
    LAUNCHER_ROTATE_SPEED = 3
    PROJECTILE_CLASS = Projectiles::GrapplingHook
    FIRING_GROUP_NUMBER = 3
    # FIRING_GROUP_NUMBER = 2
    COOLDOWN_DELAY = 120
    ACTIVE_PROJECTILE_LIMIT = 1
    SHOW_HARDPOINT_BASE = true
    STEAM_POWER_USAGE = 20.0

    SHOW_READY_PROJECTILE = true

    IS_DESTRUCTABLE_PROJECTILE = true
    
    SLOT_TYPE = :offensive

    def initialize(options = {})
      @hp_reference = options[:hp_reference]
      @image_empty = Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
      super(options)
    end

    def self.get_hardpoint_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
    end


    # def draw angle, x, y, z, z_base
    #   if @cooldown_wait <= 0.0 && (self.class::ACTIVE_PROJECTILE_LIMIT.nil? || @projectiles.count < self.class::ACTIVE_PROJECTILE_LIMIT)
    #     @image.draw_rot(x, y, z, angle, 0.5, 0.5, @width_scale / self.class::IMAGE_SCALER, @height_scale / self.class::IMAGE_SCALER)
    #   else
    #     @image_empty.draw_rot(x, y, z, angle, 0.5, 0.5, @width_scale / self.class::IMAGE_SCALER, @height_scale / self.class::IMAGE_SCALER)
    #   end
    # end

    def update mouse_x = nil, mouse_y = nil, object = nil, hardpoint_angle = nil, current_map_pixel_x = nil, current_map_pixel_y = nil, attackable_location_x = nil, attackable_location_y = nil
      @cooldown_wait -= 1.0 if @cooldown_wait > 0.0
      if @projectiles.count == 0
        # puts "GH CAN ATTACK HERE."
        # return false
        test = super(mouse_x, mouse_y, object, hardpoint_angle, current_map_pixel_x, current_map_pixel_y, attackable_location_x, attackable_location_y)
        # puts "GH - ATTACK RESULT: #{test}"
        return test
      else
        # puts "ACTIVE: #{@active} and count #{@projectiles.count}"
        @projectiles.reject! do |hook|
          # puts "HP-HOOK.HEALTH: #{hook.health} - TARGET NIL?: #{hook.attached_target.nil?} - and diss: #{hook.dissengage}"
          hook.dissengage || (hook.health <= 0 && hook.attached_target.nil?)
        end

        return true
      end
    end

    # def @active= value
    #  # puts "THIS IUS AN ACTIVE TEST HERE"
    #   super(value)
    # end

    # def deactivate
    #   @active = false
    #   @active_for = 0
    # end

    def attack hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, z_projectile, options = {}
      angle_min = self.class.angle_1to360(self.class::LAUNCHER_MIN_ANGLE + hardpoint_firing_angle)
      angle_max = self.class.angle_1to360(self.class::LAUNCHER_MAX_ANGLE + hardpoint_firing_angle)
      # puts "GRAPPLING HOOK L ATTACK HERE: #{@active} -test: #{@test}"
      # puts "#{@projectiles.count >= self.class::ACTIVE_PROJECTILE_LIMIT} && #{!@active} && #{is_angle_between_two_angles?(destination_angle, angle_min, angle_max)}"
      # @projectiles.last.time_alive check is to prevent accidental quick double-clicks
      # puts "GRAP ATTACK HERE: #{@active_for}"

      # puts "GRAPPLE ATTACH - has projectiles: #{@projectiles.count}"
      if @projectiles.count >= self.class::ACTIVE_PROJECTILE_LIMIT && !@active && @projectiles.last.time_alive > 15 && is_angle_between_two_angles?(@destination_angle, angle_min, angle_max)
        # puts "DETACHING HOOK"
        @cooldown_penalty = self.class::COOLDOWN_DELAY * 2
        @projectiles.each do |hook|
          hook.detach_hook
        end
       # puts "GRAPPLE NOT ACTIVE"
        return {projectile: nil, effects: [], destructable_projectile: nil, graphical_effects: []}
      else
       # puts "GRAPPLE ACTIVE - going SUPER"
        test = super(hardpoint_firing_angle, current_map_pixel_x, current_map_pixel_y, start_point, end_point, current_map_tile_x, current_map_tile_y, owner, z_projectile, options)
        # puts "GH ATTACKING: #{test}"
        return test
      end
    end

    # def self.name
    #   "Grappling Hook Launcher"
    # end

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