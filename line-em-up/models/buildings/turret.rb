require_relative 'building.rb'
require_relative '../projectiles/missile.rb'

# Offensive store for now, don't have any other hardport types atm.
module Buildings
  class Turret < Buildings::Building

    PROJECTILE_CLASS = Projectiles::Missile

    def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
      @window = window
      # puts "OTIONS"
      # puts options.inspect
      super(current_map_tile_x, current_map_tile_y, window, options)
      raise "really need a faction on this" if @faction.nil?
      @image = self.class::get_image
      @info = @image.gl_tex_info

      @found_target = nil
      @found_target_at = nil
      @time_to_attack = 360
      @cooldown = 240
      @attack_distance = @average_tile_size * 3
      @last_fired_at = nil

      @launch_projectiles_at = []

      # update_colors(get_faction_color)
      # @
    end

    def tile_draw_gl v1, v2, v3, v4
      super(v1, v2, v3, v4)
    end

    # def draw viewable_pixel_offset_x, viewable_pixel_offset_y
    #   if @current_take_over_time > 0 #@being_taken_over && @take_over_block == false
    #     take_over_counter = 0.0
    #     # current_angle  = 11.0
    #     current_angle  = 0
    #     while @current_take_over_time > 0 && take_over_counter <= @current_take_over_time
    #       # draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
    #       @take_over_image.draw_rot(@x, @y, ZOrder::UI, current_angle, 0.5, 8, @height_scaler_with_take_over_image, @height_scaler_with_take_over_image, @take_over_colors)

    #       take_over_counter += 3
    #       current_angle     += 3
    #     end
    #     # puts "ENDING ANGLE: #{current_angle}"
    #   end
    #   super(viewable_pixel_offset_x, viewable_pixel_offset_y, @basic_color)
    # end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options = {}
      # puts "TURRET HERE: @found_target: #{@found_target}"
      if @found_target && (Gosu.distance(@found_target.current_map_pixel_x, @found_target.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) > @attack_distance || !@found_target.is_alive || is_friendly_to?(@found_target.get_faction_id))
        @found_target = nil
        # puts "RESETING FOUND_TARGET AT"
        @found_target_at = nil
        @last_fired_at = nil
        @image = self.class.get_image
        @info  = @image.gl_tex_info
      end

      ships.each do |key, target|
        break if @found_target
        next if !is_hostile_to?(target.get_faction_id)
        if Gosu.distance(target.current_map_pixel_x, target.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @attack_distance
          @found_target = target
        end
      end
      if @found_target.nil?
        if is_hostile_to?(player.get_faction_id) && Gosu.distance(player.current_map_pixel_x, player.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @attack_distance
          @found_target = player
        end
      end

      if @found_target && @found_target_at.nil?
        @image = self.class.get_open_image
        @info  = @image.gl_tex_info
        # puts "SETTING FOUND_TARGET_AT"
        @found_target_at = @time_alive
      end

      load_projectiles = false
      # First time ATTACK - slower to attack than additional
      # puts "TURRET: @time_alive: #{@time_alive} - @found_target_at: #{@found_target_at} - @time_to_attack: #{@time_to_attack}"
      if @last_fired_at.nil? && @found_target_at && @time_alive > @found_target_at + @time_to_attack
        @last_fired_at = @time_alive
        load_projectiles = true
      elsif !@last_fired_at.nil? && @time_alive > @last_fired_at + @cooldown
        @last_fired_at = @time_alive
        load_projectiles = true
      end

      if load_projectiles
        # puts "LOADING PROJECTS"
        @launch_projectiles_at << @time_alive
        @launch_projectiles_at << @time_alive + 8
        @launch_projectiles_at << @time_alive + 16
      end

      projectiles = []
      @launch_projectiles_at.reject! do |send_at|
        if @time_alive >= send_at
          # puts "ATTACKING HERE"
          projectiles << attack(@found_target.current_map_pixel_x, @found_target.current_map_pixel_y)
          true
        else
          false
        end
      end

      return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options).merge({
        projectiles: projectiles
      })
    end


    def attack target_map_pixel_x, target_map_pixel_y, options = {}
      # graphical_effects = {}
      start_point = OpenStruct.new(:x => @current_map_pixel_x,     :y => @current_map_pixel_y)
      end_point   = OpenStruct.new(:x => target_map_pixel_x, :y => target_map_pixel_y)
      destination_angle = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)


      projectile = self.class::PROJECTILE_CLASS.new(
        @current_map_pixel_x, @current_map_pixel_y, 
        destination_angle, start_point, end_point,
        nil, nil, nil,
        @current_map_tile_x, @current_map_tile_y,
        self, ZOrder::AIProjectile
      )
      return projectile#, destructable_projectile: nil, effects: [], graphical_effects: graphical_effects}
    end









    def self.get_minimap_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/minimap_repair_building.png")
    end

    def get_minimap_image
      return self.class.get_minimap_image
    end

    # Not needed on OffensiveStore
    def set_window window
      @window = window
    end

    def self.get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/sam_site_closed.png", :tileable => true)
    end
    def self.get_open_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/sam_site_open.png", :tileable => true)
    end

  end

end