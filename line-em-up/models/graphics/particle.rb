require 'gosu'

# require 'opengl'
# require 'glu'
require 'glut'

module Graphics

  # include OpenGL # Gl
  # include GLUT   # Glut 
  # include GLU    # Glu

  class Particle

    attr_reader :is_alive

    NUMBER_OF_PARTICLES = 1
    IMAGE_SCALER = 10.0

    def self.get_image
      raise "override me"
    end

    def initialize current_map_pixel_x, current_map_pixel_y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, fps_scaler, options = {}
      raise "NO SCALES WERE GIVEN: #{height_scale} - #{width_scale}" if width_scale.nil? || height_scale.nil?
      @fps_scaler = fps_scaler
      @points = []

      @scale_multiplier = options[:scale_multiplier] || 1.0

      @decay_rate = options[:decay_rate_multiplier] || 1.0
      @r = options[:red] || 255
      @g = options[:green] || 255
      @b = options[:blue] || 255

      @shift_red   = options[:shift_red]   || false
      @shift_green = options[:shift_green] || false
      @shift_blue  = options[:shift_blue]  || false

      @width_scale, @height_scale = [width_scale, height_scale]

      @average_scale = (@width_scale + @height_scale) / 2.0
      @screen_pixel_width, @screen_pixel_height = [screen_pixel_width, screen_pixel_height]

      (0..self.class::NUMBER_OF_PARTICLES).each do |i|
        @points << [current_map_pixel_x, current_map_pixel_y, -50, -50]
      end
      @is_alive = true
      @image = self.class.get_image
      @health = 1
      @time_alive = 0.0

      @scale_init_boost = options[:scale_init_boost] || 0.0
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
      @time_alive += 1.0 * @decay_rate * @fps_scaler


      @points.each do |p|
        x, y = GeneralObject.convert_map_pixel_location_to_screen(player_map_pixel_x, player_map_pixel_y, p[0], p[1], @screen_pixel_width, @screen_pixel_height)
        p[2] = x
        p[3] = y
      end
      puts "PARTICLE HERE - returning: #{@is_alive}"
      return @is_alive
    end

    def draw viewable_pixel_offset_x, viewable_pixel_offset_y
      @points.each do |p|
        if @time_alive > 0.0
          scale = (@time_alive / 100.0) + @scale_init_boost
        else
          scale = 0.01 + @scale_init_boost
        end

        new_r = @shift_red   ? @r + @time_alive.to_i : @r
        new_g = @shift_green ? @g + @time_alive.to_i : @g
        new_b = @shift_blue  ? @b + @time_alive.to_i : @b

        color = Gosu::Color.new(255 - (@time_alive).to_i, new_r, new_g, new_b)

        @image.draw_rot(p[2] + viewable_pixel_offset_x, p[3] + viewable_pixel_offset_y, ZOrder::Explosions, @time_alive, 0.5, 0.5, scale * @scale_multiplier, scale * @scale_multiplier, color) #if @image
        if @time_alive >= 255.0
          @is_alive = false
        end
      end
    end 
  end
end