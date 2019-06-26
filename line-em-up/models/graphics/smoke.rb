require 'gosu'

require 'opengl'
require 'glu'
require 'glut'

module Graphics

  include OpenGL # Gl
  include GLUT   # Glut 
  include GLU    # Glu


  class Smoke

    attr_reader :is_alive

    def initialize
      @points = []

      (0..10).each do |i|
        x = rand(2) - 1
        y = rand(2) - 1
        x = x + 450
        y = y + 450
        @points << [x, y]
      end
      puts "INIT POINTS: #{}"
      puts @points
      @time_alive = 0
      @image = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/smoke.png")
      @image2 = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/bomb.png")
      @is_alive = true
    end

    def update mouse_x, mouse_y, player
      @time_alive += 1
      @points.each do |p|
        x = p[0]
        y = p[1]
        if x < 450
          x -= 1
        else
          x += 1
        end
        if y < 450
          y -= 1
        else
          y += 1
        end
        p[0] = x
        p[1] = y
      end
    end

    def draw

      # gl_FragColor

      # info = image.gl_tex_info

      # glBindTexture(GL_TEXTURE_2D, info.tex_name)

       # @image.draw_rot 235, @image.height + 110, 0, 10, 0, 0, 1, 1, Gosu::Color::RED, :shader => @fade
      # @image.draw_rot 235, @image.height + 110, 0, 10, 0, 0, 1, 1, Gosu::Color::RED, {shader: {}}
      @points.each do |p|
        # @image.draw_as_points(@points, 100, options = {})
        # @image.draw_rot@time_alive, p[], 0, 10, 0, 0, 1, 1, Gosu::Color::RED, {shader: {}}
        #draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
        # color = Gosu::Color.new(0xff_000000)
        if @time_alive > 0
          color = Gosu::Color.new(255 - (@time_alive).to_i, 255, 255, 255)
          # scale = 1 - ((1 - (255 - @time_alive) / 255.0)) / 3
          # scale = 1
          scale = @time_alive / 100.0
        else
          color = Gosu::Color.new(255, 255, 255, 255)
          scale = 0
        end
        @image.draw_rot(p[0], p[1], ZOrder::UI, @time_alive, 0.5, 0.5, scale, scale, color) #if @image
        puts "DRAWING IAMGE: #{[p[0], p[1]]}"
        if @time_alive >= 255
          @is_alive = false
        end
      end

        # @image.draw_rot(300, 300, ZOrder::UI, @time_alive, 0.5, 0.5, 4, 4) #if @image
      # @image2.draw(400, 400, ZOrder::UI) #if @image
      # glEnable(GL_BLEND)
      # glDisable(GL_DEPTH_TEST)
      # glBlendFunc( GL_SRC_ALPHA, GL_ONE );
      # vec2 pixel = gl_FragCoord.xy / res.xy;
   

      # gl_FragColor = Glut.texture2D( tex, pixel )
      # gl_FragColor.r += 0.01


      # glColor4d(colors[0], colors[1], colors[2], colors[3])
      # glVertex3d(vert_pos1[0], vert_pos1[1], vert_pos1[2])

    end 
  end
end