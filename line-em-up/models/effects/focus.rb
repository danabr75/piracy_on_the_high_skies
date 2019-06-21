require_relative 'effect.rb'

module Effects
  class Focus < Effects::Effect

    def initialize id, type, time, ships, buildings, options = {}
      puts "NEW FOCUS HERE: #{time}"
      super(options)
      @debug = options[:debug]
      @time_alive = 0
      @max_time_alive = 500 #time || 100
      @id = id
      @radius = 5 * @average_scale
      @speed = 1 * @average_scale
      # puts "ID"
      # puts @id.inspect
      # puts @id.class
      @target = nil
      @location_x = nil
      @location_y = nil
      @moving_to_target = true
      @hovering_over_target = false
      @moving_to_player = false
      @returned_to_player  = false
      # @viewable_pixel_offset_x_bank = 0
      # @viewable_pixel_offset_y_bank = 0

      if type == 'ship'
        ships.each do |ship|
          # puts "SHIP HERE: #{ship.id}"
          # puts ship.id.inspect
          # puts ship.id.class
          next if ship.id != id
          @target = ship
        end
      elsif type == 'building'

      else
        # Make center target an open struct that has tile, pixel data - A location
      end
      puts "DID NOT FIND TARGET WITH ID AND TYPE: #{id} - #{type}" if @target.nil?
      raise "DID NOT FIND TARGET WITH ID AND TYPE: #{id} - #{type}" if @target.nil? && @debug
    end

    def is_active
      !@returned_to_player
    end

# START
# EFFECT UPDATE : [true, false, false, false]
# PLAYER LOC: 14062.5 - 14062.5
# OFFSET: 0 - 0
# ANGLE HERE: 18.130186912500932

# HOVER:
# PLAYER LOC: 14062.5 - 14062.5
# OFFSET: 52.882931512472915 - -161.50733137593124

# RETURN - bad
# PLAYER LOC: 14062.5 - 14062.5
# OFFSET: 0.4455084691589981 - -213.94475441924533
# ------
# PLAYER LOC: 14062.5 - 14062.5
# OFFSET: 48.51314625886342 - -165.87711662954075
# ANGLE2 HERE: 135.0


# start_point   = OpenStruct.new(:x => 14062.5 - 0.4455084691589981, :y => 14062.5 - -213.94475441924533)
# end_point     = OpenStruct.new(:x => 14062.5, :y => 14062.5)
# angle = GeneralObject.angle_1to360(180.0 - GeneralObject.calc_angle(start_point, end_point) - 90)
# 0.11930985732607269


    # OFFSET moves background... needs to move players and ships too. + projectiles.
    # THIS SECTION HAS HUGE ISSUES WITH CALCING ANGLES AND OFFSETs
    def update gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y
      puts "EFFECT UPDATE : #{[@moving_to_target, @hovering_over_target, @moving_to_player, @returned_to_player]}"
      puts "PLAYER LOC: #{player.current_map_pixel_x} - #{player.current_map_pixel_y}"
      puts "OFFSET: #{viewable_pixel_offset_x} - #{viewable_pixel_offset_y}"
      # speed = @hovering_over_target ? offset_target.get_speed : @speed
      speed = @speed

      @time_alive += 1 if @hovering_over_target
      if @time_alive > @max_time_alive && @hovering_over_target
        # raise "OK, got here"
        @hovering_over_target = false
        @moving_to_player = true
        @location_x = offset_target.current_map_pixel_x
        @location_y = offset_target.current_map_pixel_y
        # @viewable_pixel_offset_x_bank = viewable_pixel_offset_x
        # @viewable_pixel_offset_y_bank = viewable_pixel_offset_y
      end
      # for testing
      if @target.nil?
        @time_alive = @max_time_alive
      else
        offset_target = @target
      end
      if @returned_to_player 
        offset_target = nil
        viewable_pixel_offset_x = 0
        viewable_pixel_offset_y = 0
      elsif @moving_to_target || @hovering_over_target

        distance = Gosu.distance(player.current_map_pixel_x + viewable_pixel_offset_x, player.current_map_pixel_y + viewable_pixel_offset_y, offset_target.current_map_pixel_x, offset_target.current_map_pixel_y)

        if distance < @radius
          @moving_to_target     = false
          @hovering_over_target = true
        else
          start_point = OpenStruct.new(:x => player.current_map_pixel_x + viewable_pixel_offset_x,     :y => player.current_map_pixel_y + viewable_pixel_offset_y)
          end_point   = OpenStruct.new(:x => offset_target.current_map_pixel_x, :y => offset_target.current_map_pixel_y)


          angle = GeneralObject.angle_1to360(180.0 - GeneralObject.calc_angle(start_point, end_point) - 90)
          puts "ANGLE HERE: #{angle}"

          base = speed * @average_scale

          step = (Math::PI/180 * (angle + 90))# - 180
          new_x = Math.cos(step) * base + viewable_pixel_offset_x
          new_y = Math.sin(step) * base + viewable_pixel_offset_y

          viewable_pixel_offset_x += (viewable_pixel_offset_x - new_x)
          viewable_pixel_offset_y += (viewable_pixel_offset_y - new_y)
        end
      elsif @moving_to_player

        # This is wrong, will never stop at player need to include offset.. or create new offect
        distance = Gosu.distance(player.current_map_pixel_x + viewable_pixel_offset_x, player.current_map_pixel_y + viewable_pixel_offset_y, player.current_map_pixel_x, player.current_map_pixel_y)

        if distance < @radius
          @moving_to_player   = false
          @returned_to_player = true
          viewable_pixel_offset_x = 0
          viewable_pixel_offset_y = 0
        else
          start_point   = OpenStruct.new(:x => player.current_map_pixel_x + viewable_pixel_offset_x, :y => player.current_map_pixel_y + (viewable_pixel_offset_y * -1))
          end_point     = OpenStruct.new(:x => player.current_map_pixel_x, :y => player.current_map_pixel_y)


          angle = GeneralObject.angle_1to360(GeneralObject.calc_angle(start_point, end_point) - 90)
          # if angle == 315.0
          puts "ANGLE2 HERE: #{angle}"

          base = speed * @average_scale

          step = (Math::PI/180 * (angle + 90))# - 180
          new_x = Math.cos(step) * base + viewable_pixel_offset_x
          new_y = Math.sin(step) * base + viewable_pixel_offset_y

          viewable_pixel_offset_x -= (viewable_pixel_offset_x - new_x)
          viewable_pixel_offset_y -= (viewable_pixel_offset_y - new_y)
          # end
        end
      end
      puts "POST  UPDATE : #{[@moving_to_target, @hovering_over_target, @moving_to_player, @returned_to_player]}"
      return [gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y]
    end

    def draw
      # Do nothing for now
    end
  end
end