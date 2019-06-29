require 'gosu'

require 'opengl'
require 'glu'
require 'glut'

module Graphics

  include OpenGL # Gl
  include GLUT   # Glut 
  include GLU    # Glu

  class AngledParticle

    attr_reader :is_alive

    NUMBER_OF_PARTICLES = 10
    IMAGE_SCALER = 10.0

    def self.get_image
      raise "override me"
    end

    def initialize current_map_pixel_x, current_map_pixel_y, speed, angle_min, angle_max, width_scale, height_scale, screen_pixel_width, screen_pixel_height, options = {}
      @points = []

      @scale_multiplier = options[:scale_multiplier] || 1.0

      @decay_rate = options[:decay_rate_multiplier] || 1.0
      @r = options[:red] || 255
      @g = options[:green] || 255
      @b = options[:blue] || 255


      @shift_red   = options[:shift_red]   || false
      @shift_green = options[:shift_green] || false
      @shift_blue  = options[:shift_blue]  || false
      puts "HERE:15125123123123"

      puts @shift_red   #= options[:shift_red]   || false
      puts @shift_green #= options[:shift_green] || false
      puts @shift_blue  #= options[:shift_blue]  || false

      angle_diff = nil
      if angle_max
        angle_diff = GeneralObject.angle_diff(angle_min, angle_max).abs
      end
      # puts "ANGLE DIFF HERE"
      # puts "angle_diff = GeneralObject.angle_diff(angle_min, angle_max).abs"
      # puts "angle_diff = GeneralObject.angle_diff(#{angle_min}, #{angle_max}).abs"
      # puts "#{angle_diff} = #{GeneralObject.angle_diff(angle_min, angle_max)}.abs"

      # angle_diff = GeneralObject.angle_diff(angle_min, angle_max).abs
      # angle_diff = GeneralObject.angle_diff(-8.000000000000014, 81.99999999999999).abs
      # value = angle2 - angle1
      # 90.0 = 81.99999999999999 - -8.000000000000014
      # 90.0 = 90.0.abs

      @width_scale, @height_scale = [width_scale, height_scale]

      @average_scale = (@width_scale + @height_scale) / 2.0
      @screen_pixel_width, @screen_pixel_height = [screen_pixel_width, screen_pixel_height]

      (0..self.class::NUMBER_OF_PARTICLES).each do |i|
        angle = !angle_diff.nil? ? rand(angle_diff) + angle_min : angle_min
        # puts "rand(angle_diff) + angle_min"
        # puts "rand(#{angle_diff}) + #{angle_min}"
        # puts "#{rand(angle_diff)} + #{angle_min}"
        # puts "ANGLE ON NEW PARTICLE: #{angle}"

        # rand(angle_diff) + angle_min
        # rand(90.0) + -8.000000000000014
        # 21 + -8.000000000000014
        # ANGLE ON NEW PARTICLE: 42.99999999999998

        @points << [current_map_pixel_x, current_map_pixel_y, speed, angle, -50, -50]
      end
      @is_alive = true
      @image = self.class.get_image
      @health = 1
      @time_alive = 0.0
    end

    def update mouse_x, mouse_y, player
      # puts "PARTICLE UPDATES RIGHT HERE"
      @time_alive += 1.0 * @decay_rate


      @points.each do |p|
        # puts "MOVING ANGLE HERE: #{p[3]}"
        if p[2] > 0.0
          map_pixel_x, map_pixel_y = GeneralObject.movement(p[0], p[1], p[2], p[3], @width_scale, @height_scale)
          p[0] = map_pixel_x
          p[1] = map_pixel_y
          # p[2] = p[2] #- (0.5 * @average_scale)
        end
        # puts "GIVING IT: player + #{[map_pixel_x, map_pixel_y, @screen_pixel_width, @screen_pixel_height]}"
        # puts "TEST: #{player.current_map_pixel_x} - #{player.current_map_pixel_y}"
        # puts player.class
        x, y = GeneralObject.convert_map_pixel_location_to_screen(player, p[0], p[1], @screen_pixel_width, @screen_pixel_height)

        p[4] = x
        p[5] = y
      end
      return @is_alive
    end

    def draw viewable_pixel_offset_x, viewable_pixel_offset_y
      @points.each do |p|
        if @time_alive > 0.0
          scale = @time_alive / 100.0
        else
          scale = 0.01
        end


        new_r = @shift_red   ? @r + @time_alive.to_i : @r
        new_g = @shift_green ? @g + @time_alive.to_i : @g
        new_b = @shift_blue  ? @b + @time_alive.to_i : @b

        color = Gosu::Color.new(255 - (@time_alive).to_i, new_r, new_g, new_b)
        # puts "DRAWING IMAGE HERE - #{[p[0], p[1]]}"

        @image.draw_rot(p[4] + viewable_pixel_offset_x, p[5] + viewable_pixel_offset_y, ZOrder::UI, @time_alive, 0.5, 0.5, scale * @scale_multiplier, scale * @scale_multiplier, color) #if @image
        if @time_alive >= 255.0
          @is_alive = false
        end
      end
    end 
  end
end