require_relative 'hardpoint_object'

module HardpointObjects
  class ArmorHardpoint < HardpointObjects::HardpointObject
    ABSTRACT_CLASS = true
    HARDPOINT_NAME = "replace_me"  
    PROJECTILE_CLASS   = nil 
    FIRING_GROUP_NUMBER = nil # Passive

    PERMANENT_STEAM_USE       = nil
    TILES_PER_SECOND_MODIFIER = nil
    ROTATION_MODIFIER         = nil

    SHOW_HARDPOINT = false

    SHOW_HARDPOINT_BASE = false

    SLOT_TYPE = :armor

    IMAGE_SCALER = 5.0


    def self.get_hardpoint_image
      raise "OVERRIDE ME"
    end

    def self.description
      raise "OVERRIDE ME"
    end

    def self.value
      raise "OVERRIDE ME"
    end

    def initialize options
      super(options)
      media_dir = options[:owner_klass]::ITEM_MEDIA_DIRECTORY
      # Ex: Should be MEDIA_DIRECTORY + pilotable_ships/basic_ship/basic_armor.png
      outer_shell_image_path = "#{media_dir}/#{self.class::HARDPOINT_NAME}.png"
      if File.file?(outer_shell_image_path)
        @outer_shell_image = Gosu::Image.new(outer_shell_image_path)
      else
        puts "Couldn't find file: #{outer_shell_image_path}"
      end
    end

    def draw angle, x, y, z, z_base, z_projectile, options = {} #{originating_x: @x, originating_y: @y}
      # puts "getting right display"
      @outer_shell_image.draw_rot(options[:originating_x], options[:originating_y], z_base, angle - @firing_angle_offset, 0.5, 0.5, @height_scale_with_image_scaler, @height_scale_with_image_scaler, @colors)
      # {originating_x: @x, originating_y: @y}
      # # raise "missing z_base: #{self.class}" if z_base.nil?
      # # puts "HARDPOINT DRAW: #{self.class::SHOW_READY_PROJECTILE} - #{SHOW_READY_PROJECTILE}"
      # if self.class::SHOW_READY_PROJECTILE
      #   if @cooldown_wait <= 0.0
      #     @projectile_image.draw_rot(x, y, z_projectile, angle - @firing_angle_offset, 0.5, 0.5, @show_projectile_height_scale, @show_projectile_height_scale, @colors)
      #   end
      # # else
      #   # puts "not showing proj - #{self.class.name}"
      # end
      # if self.class::SHOW_HARDPOINT
      #   @image.draw_rot(x, y, z, angle - @firing_angle_offset, 0.5, 0.5, @height_scale_with_image_scaler, @height_scale_with_image_scaler, @colors)
      # end

      # if z_base && self.class::SHOW_HARDPOINT_BASE
      #   @image_base.draw_rot(x, y, z_base, angle - @firing_angle_offset, 0.5, 0.5, @hp_reference.height_scale_with_image_scaler, @hp_reference.height_scale_with_image_scaler, @colors)
      # end
    end

  end
end

