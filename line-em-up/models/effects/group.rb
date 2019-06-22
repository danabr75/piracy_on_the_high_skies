module Effects
  class Group

    attr_accessor :effects

    def initialize options = {}
      @debug = options[:debug]
      @effects = []
    end

    def is_active
      @effects.count > 0
    end

    def update gl_background, ships, buildings, player, center_target, viewable_pixel_offset_x, viewable_pixel_offset_y
      puts "UPDATIGN EFFECT GROUP"
      first_effect = @effects.first

      if first_effect
        puts "FIRST EFFECT HERE target class: #{first_effect.target.class}"
        gl_background, ships, buildings, player, center_target, viewable_pixel_offset_x, viewable_pixel_offset_y = first_effect.update(gl_background, ships, buildings, player, center_target, viewable_pixel_offset_x, viewable_pixel_offset_y)
        # @effects.reject! do |effect|
        #   gl_background, ships, buildings, player, center_target, viewable_pixel_offset_x, viewable_pixel_offset_y = effect.update(gl_background, ships, buildings, player, center_target, viewable_pixel_offset_x, viewable_pixel_offset_y)
        #   !effect.is_active
        # end

        puts "FIRST EFFECT IS ACTIVE: #{first_effect.is_active}"
        @effects.shift if !first_effect.is_active
      end

      return [gl_background, ships, buildings, player, center_target, viewable_pixel_offset_x, viewable_pixel_offset_y, @effects.count]
    end

    def draw
      # Do nothing for now
    end

  end
end