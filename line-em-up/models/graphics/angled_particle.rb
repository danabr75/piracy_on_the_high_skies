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

      angle_diff = GeneralObject.angle_diff(angle_min, angle_max).abs
      @width_scale, @height_scale = [width_scale, height_scale]

      @average_scale = (@width_scale + @height_scale) / 2.0
      @screen_pixel_width, @screen_pixel_height = [screen_pixel_width, screen_pixel_height]

      (0..self.class::NUMBER_OF_PARTICLES).each do |i|
        angle = rand(angle_diff) + angle_min
        @points << [current_map_pixel_x, current_map_pixel_y, speed, angle, -50, -50]
      end
      @is_alive = true
      @image = self.class.get_image
      @health = 1
      @time_alive = 0
    end

    def update mouse_x, mouse_y, player
      # puts "PARTICLE UPDATES RIGHT HERE"
      @time_alive += 1
      @points.each do |p|
        map_pixel_x, map_pixel_y = GeneralObject.movement(p[0], p[1], p[2], p[3], @width_scale, @height_scale)
        p[0] = map_pixel_x
        p[1] = map_pixel_y
        p[2] = p[2] #- (0.5 * @average_scale)
        # puts "GIVING IT: player + #{[map_pixel_x, map_pixel_y, @screen_pixel_width, @screen_pixel_height]}"
        # puts "TEST: #{player.current_map_pixel_x} - #{player.current_map_pixel_y}"
        # puts player.class
        x, y = GeneralObject.convert_map_pixel_location_to_screen(player, map_pixel_x, map_pixel_y, @screen_pixel_width, @screen_pixel_height)

        p[4] = x
        p[5] = y
      end
      return @is_alive
    end

    def draw viewable_pixel_offset_x, viewable_pixel_offset_y
      @points.each do |p|
        if @time_alive > 0
          color = Gosu::Color.new(255 - (@time_alive).to_i, 255, 255, 255)
          scale = @time_alive / 100.0
        else
          color = Gosu::Color.new(255, 255, 255, 255)
          scale = 0.01
        end
        # puts "DRAWING IMAGE HERE - #{[p[0], p[1]]}"

        @image.draw_rot(p[4] + viewable_pixel_offset_x, p[5] + viewable_pixel_offset_y, ZOrder::UI, @time_alive, 0.5, 0.5, scale, scale, color) #if @image
        if @time_alive >= 255
          @is_alive = false
        end
      end
    end 
  end
end