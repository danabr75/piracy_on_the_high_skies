require 'gosu'

require 'opengl'
require 'glu'
require 'glut'


require_relative 'particle.rb'

module Graphics

  include OpenGL # Gl
  include GLUT   # Glut 
  include GLU    # Glu


  class Smoke < Graphics::Particle

    attr_reader :is_alive

    NUMBER_OF_PARTICLES = 1

    def self.get_image
      @image = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/smoke.png")
    end

  end
end