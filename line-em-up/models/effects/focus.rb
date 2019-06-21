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
      @speed = 10 * @average_scale
      # puts "ID"
      # puts @id.inspect
      # puts @id.class
      @target = nil
      @hover_over_target = false
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
      @time_alive < @max_time_alive
    end


    # OFFSET moves background... needs to move players and ships too. + projectiles.
    def update gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y
      @time_alive += 1
      # for testing
      if @time_alive > 120
        if @target.nil?
          @time_alive = @max_time_alive
        else
          offset_target = @target
          # gl_background.recenter_map(offset_target)
        end
        if !is_active
          offset_target = nil
          viewable_pixel_offset_x = 0
          viewable_pixel_offset_y = 0
          # gl_background.recenter_map(offset_target)
        else

          start_point = OpenStruct.new(:x => player.current_map_pixel_x,     :y => player.current_map_pixel_y)
          end_point   = OpenStruct.new(:x => offset_target.current_map_pixel_x, :y => offset_target.current_map_pixel_y)
          angle = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)

          base = @speed * @average_scale

          step = (Math::PI/180 * (angle + 90))# - 180
          new_x = Math.cos(step) * base + @current_map_pixel_x
          new_y = Math.sin(step) * base + @current_map_pixel_y
          x_diff = (@current_map_pixel_x - new_x)# * -1
          y_diff = @current_map_pixel_y - new_y

          viewable_pixel_offset_x += 10
          viewable_pixel_offset_y = 0
        end
      end
      return [gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y]
    end

    def draw
      # Do nothing for now
    end
  end
end