require 'gosu'

require 'opengl'
require 'glu'
require 'glut'

module Graphics

  include OpenGL # Gl
  include GLUT   # Glut 
  include GLU    # Glu


  class AngledSmoke < Graphics::AngledParticle

    attr_reader :is_alive

    NUMBER_OF_PARTICLES = 20

    def self.get_image
      @image = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/smoke.png")
    end

  end
end