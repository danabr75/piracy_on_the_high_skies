require_relative 'building.rb'

# Offensive store for now, don't have any other hardport types atm.
module Buildings
  class CommandCenter < Buildings::Building


    attr_reader :credits

    def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
      @window = window
      # puts "OTIONS"
      # puts options.inspect
      super(current_map_tile_x, current_map_tile_y, window, options)
      raise "really need a faction on this" if @faction.nil?
      @image = self.class::get_image
      @info = @image.gl_tex_info


      update_colors(get_faction_color)
      # @basic_color = get_faction_color
      # @color = GeneralObject.convert_gosu_color_to_opengl(@basic_color)

      # @inactive_color = [1, 1, 1, 1]
      # @basic_inactive_color = Gosu::Color.argb(0xff_ffffff)

      # @active_color = [0.7, 1, 0.7, 1]
      # @basic_active_color = Gosu::Color.argb(0xff_aaffaa)

      # @color = @inactive_color
      # @basic_color = @basic_inactive_color
      @being_taken_over = false
      @take_over_block  = false
      @time_to_be_taken_over        = 360
      @current_take_over_time       = 0
      @current_take_over_by = nil

      @take_over_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/command_center_take_over.png")
      # @take_over_angle_increment = 360 / (@time_to_be_taken_over).to_f

      # @other_angle_increment = (@time_to_be_taken_over).to_f / 360.0


      # @take_over_angle_increment = @take_over_angle_increment * 10.0
      # puts "@take_over_angle_increment: #{ @take_over_angle_increment}"
      @height_scaler_with_take_over_image = @height_scale / 8.0
      @take_over_colors = nil
    end

    def tile_draw_gl v1, v2, v3, v4
      super(v1, v2, v3, v4, @color)
    end

    def draw viewable_pixel_offset_x, viewable_pixel_offset_y
      if @being_taken_over && @take_over_block == false
        take_over_counter = 0.0
        # current_angle  = 11.0
        current_angle  = 0
        while @current_take_over_time > 0 && take_over_counter <= @current_take_over_time
          # draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
          @take_over_image.draw_rot(@x, @y, ZOrder::UI, current_angle, 0.5, 8, @height_scaler_with_take_over_image, @height_scaler_with_take_over_image, @take_over_colors)

          take_over_counter += 3
          current_angle     += 3
        end
        # puts "ENDING ANGLE: #{current_angle}"
      end
      super(viewable_pixel_offset_x, viewable_pixel_offset_y, @basic_color)
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options = {}
      # puts "@current_take_over_time: #{@current_take_over_time}"
      being_taken_over = false
      ships.each do |key, target|
        if Gosu.distance(target.current_map_pixel_x, target.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @average_tile_size
          # target.increase_health(0.2 * @fps_scaler)
          if target.get_faction_id != get_faction_id
            being_taken_over = true
            @current_take_over_by = target
          else
            @take_over_block = true
          end
        end
      end
      if Gosu.distance(player.current_map_pixel_x, player.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y) < @average_tile_size
        # player.increase_health(0.2 * @fps_scaler)
        being_taken_over = true
        if player.get_faction_id != get_faction_id
          being_taken_over = true
          @current_take_over_by = player
        else
          @take_over_block = true
        end
      end

      @being_taken_over = being_taken_over

      if @being_taken_over
        @take_over_colors = @current_take_over_by.get_faction_color
      end

      if @being_taken_over == true && @take_over_block == true
        # @color = @inactive_color
        # @basic_color = @basic_inactive_color
      elsif @being_taken_over == true && @take_over_block == false
        @current_take_over_time += 1
        # @color = @active_color
        # @basic_color = @basic_active_color
      else
        @current_take_over_time -= 1 if @current_take_over_time > 0
        # @color = @inactive_color
        # @basic_color = @basic_inactive_color
      end

      if @current_take_over_time >= @time_to_be_taken_over
        @faction.decrease_faction_relations(@current_take_over_by.get_faction_id, Faction::MIN_FACTIONAL_RELATION)
        old_faction_id = self.get_faction_id
        @current_take_over_time = 0
        @being_taken_over = false
        self.set_faction(@current_take_over_by.get_faction_id)
        # @color = get_faction_color
        update_colors(get_faction_color)
        buildings.each do |building|
          building.set_faction(@current_take_over_by.get_faction_id) if building.get_faction_id == old_faction_id
        end
      end

      return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options)
    end

    def update_colors gosu_color
      @basic_color = gosu_color
      @color = GeneralObject.convert_gosu_color_to_opengl(gosu_color)
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
      Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/command_center.png", :tileable => true)
    end

  end

end