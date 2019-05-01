require 'opengl'
require 'glu'
require 'glut'

class ExecuteOpenGl
  # def self.init_scene
  #   glEnable(GL_TEXTURE_2D)
  #   glShadeModel(GL_SMOOTH)
  #   glClearColor(0,0,0,0.5)
  #   glClearDepth(1)
  #   glBlendFunc(GL_SRC_ALPHA,GL_ONE) #see nehe08
  #   glEnable(GL_BLEND)
  # end

  # def self.add_perspective_to_scene
  #   glMatrixMode(GL_PROJECTION)
  #   glLoadIdentity
  #   gluPerspective(45.0, width / height, 0.1, 100.0)
  #   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) #see nehe07
  # end

  # include Gl
  # include Glu 
  # include Glut

  def draw background, projectiles, player
    # @zoom = -14
    Gosu.gl do
      # init_scene
      # glEnable(GL_TEXTURE_2D)
      # glShadeModel(GL_SMOOTH)
      glClearColor(0.0, 0.2, 0.5, 1.0)
      glClearDepth(0)
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      # glBlendFunc(GL_SRC_ALPHA,GL_ONE) #see nehe08
      # glEnable(GL_BLEND)

      background.exec_gl

      projectiles.each_with_index do |projectile, i|
        glMatrixMode(GL_MODELVIEW)  #see lesson 01
        glLoadIdentity              #see lesson 01
        # puts "-projectile.get_draw_ordering - 10: #{-projectile.get_draw_ordering - 10}"
        glTranslatef(0, 0, -13)   #see lesson 01
        # glTranslatef(0, 0, -14)   #see lesson 01
        projectile.draw_gl
      end

      player.draw_gl

    end
  end
end
