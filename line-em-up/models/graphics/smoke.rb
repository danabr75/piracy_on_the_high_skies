require 'gosu'

require 'opengl'
require 'glu'
require 'glut'

module Graphics

  include OpenGL # Gl
  include GLUT   # Glut 
  include GLU    # Glu
  class Smoke
    def self.draw_gl(pointer)
      x = pointer.x
      y = pointer.y
      pixel = OpenStruct.new(:x => x,     :y => y)

      # gl_FragColor

      image = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/smoke.png", :tileable => true)
      info = image.gl_tex_info

      # glBindTexture(GL_TEXTURE_2D, info.tex_name)


      # @image.draw_rot 235, @image.height + 110, 0, 10, 0, 0, 1, 1, Gosu::Color::RED, :shader => @fade

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