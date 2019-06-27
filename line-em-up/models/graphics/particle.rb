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

    def self.get_image
      raise "override me"
    end

    def initialize current_map_pixel_x, current_map_pixel_y, speed, angle_min, angle_max, width_scale, height_scale, options = {}
      @points = []

      angle_diff = self.class.angle_diff(angle_min, angle_max).abs
      @width_scale, @height_scale = [width_scale, height_scale]

      @average_scale = (@width_scale + @height_scale) / 2.0

      (0..NUMBER_OF_PARTICLES).each do |i|
        angle = rand(angle_diff) + angle_min
        @points << [current_map_pixel_x, current_map_pixel_y, speed, angle]
      end
      @time_alive = 0
      @image = self.class.get_image
      @health = 1
    end

    def update mouse_x, mouse_y, player
      @time_alive += 1
      @points.each do |p|
        x, y = self.class.movement(p[0], p[1], p[3], p[4], @width_scale, @height_scale)
        p[0] = x
        p[1] = y
        p[3] = p[3] - (0.5 * @average_scale)
      end
    end

    def draw
      @points.each do |p|
        if @time_alive > 0
          color = Gosu::Color.new(255 - (@time_alive).to_i, 255, 255, 255)
          scale = @time_alive / 100.0
        else
          color = Gosu::Color.new(255, 255, 255, 255)
          scale = 0.01
        end
        @image.draw_rot(p[0], p[1], ZOrder::UI, @time_alive, 0.5, 0.5, scale, scale, color) #if @image
        if @time_alive >= 255
          @is_alive = false
        end
      end
    end 
  end
end