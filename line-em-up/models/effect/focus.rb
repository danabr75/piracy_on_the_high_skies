module Effect
  class Focus


    def initialize id, time, options = {}
      puts "NEW FOCUS HERE: #{time}"
      @time_alive = 0
      @max_time_alive = 10000000 #time || 100
      @id = id
    end

    def is_active
      @time_alive < @max_time_alive
    end


    # OFFSET moves background... needs to move players and ships too. + projectiles.
    def update gl_background, ships, buildings, player, center_target
      @time_alive += 1
      puts "FOCUS UPDATE: #{viewable_offset_x} - #{viewable_offset_y}"
      return viewable_offset_x + 5, viewable_offset_y + 5, gl_background, ships, buildings, player
    end

    def draw
      # Do nothing for now
    end
  end
end