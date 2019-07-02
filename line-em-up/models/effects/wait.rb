require_relative 'effect.rb'

module Effects
  class Wait < Effects::Effect
    attr_reader :target
    def initialize time, options = {}
     # puts "NEW WAIT HERE: #{time}"
      super(options)
      @debug = options[:debug]
      @time_alive = 0
      @max_time_alive = time #|| 100
      @complete = false
    end

    def is_active
      !@complete
    end
    def update gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y
      @time_alive += 1
      if @time_alive > @max_time_alive
        @complete             = true
      end
      return [gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y]
    end
  end
end