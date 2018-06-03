require_relative 'dumb_projectile.rb'
require 'opengl'
require 'glu'
require 'glut'

class Bullet < DumbProjectile
  DAMAGE = 3
  COOLDOWN_DELAY = 20
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def get_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/laserbolt.png")
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
  end

  include Gl
  include Glu 
    include Glut


  def draw
    # draw nothing
  end

  def draw_gl
    # puts "DRAWING BULLET"
  
    # glEnable(GL_TEXTURE_2D)
    # glBindTexture(GL_TEXTURE_2D, info.tex_name)



    middle_x = @screen_width / 2
    middle_y = @screen_height / 2
    increment_x = 1.0 / middle_x
    increment_y = 1.0 / middle_y
    new_pos_x = (@x - middle_x) * increment_x
    new_pos_y = (@y - middle_y) * increment_y
    # Inverted Y
    new_pos_y = new_pos_y * -1

    height = @image_height.to_f * increment_x

    z = ZOrder::Projectile
    # @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)
    # gl do
    # points_x = 3
    # pounts_y = 10
    # Gosu.gl(z) do

    # glClearColor(1, 1, 1, 1)
    # glClearDepth(-4)
    # glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    # # info = @image.gl_tex_info
    # glDepthFunc(GL_GEQUAL)
    # # glEnable(GL_DEPTH_TEST)
    # glEnable(GL_BLEND)

    # glMatrixMode(GL_MODELVIEW)
    # glLoadIdentity 

    # glMatrixMode(GL_MODELVIEW)
    # glLoadIdentity

    glLineWidth(5)
    glBegin(GL_LINES)
      glColor3f(1.0, 0.0, 0.0)
      glVertex3d(new_pos_x, new_pos_y, z)
      glVertex3d(new_pos_x, new_pos_y - height, z)
    glEnd








      # glGenFramebuffers(1, &Framebuffer);
      # glBindFramebuffer(GL_FRAMEBUFFER, Framebuffer); 

      # glGenTextures(1, &renderedNormalTexture);   
      # glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderedNormalTexture, 0);

      # glGenTextures(1, &renderedDepthTexture);    
      # glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, renderedDepthTexture, 0);

      # glGenTextures(1, &edgeTexture); 
      # glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT2, GL_TEXTURE_2D, edgeTexture, 0);

      # ndbuffers[0] = GL_COLOR_ATTACHMENT0;
      # ndbuffers[1] = GL_COLOR_ATTACHMENT1;
      # ndbuffers[2] = GL_COLOR_ATTACHMENT2;
      # glDrawBuffers(3, ndbuffers);


    # end


    # glGenFramebuffers(1, &Framebuffer);
    # glBindFramebuffer(GL_FRAMEBUFFER, Framebuffer); 

    # glGenTextures(1, &renderedNormalTexture);   
    # glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderedNormalTexture, 0);

    # glGenTextures(1, &renderedDepthTexture);    
    # glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, renderedDepthTexture, 0);

    # glGenTextures(1, &edgeTexture); 
    # glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT2, GL_TEXTURE_2D, edgeTexture, 0);

    # ndbuffers[0] = GL_COLOR_ATTACHMENT0;
    # ndbuffers[1] = GL_COLOR_ATTACHMENT1;
    # ndbuffers[2] = GL_COLOR_ATTACHMENT2;
    # glDrawBuffers(3, ndbuffers);

    # Gosu.gl(z) do
    #   glLineWidth(50)
    #   glColor3f(1.0, 0.0, 0.0)
    #   glBegin(GL_TRIANGLE_STRIP)
    #     glVertex3f(0, 0.0, z)
    #     glVertex3f(0.5, 0, z)
    #     glVertex3f(0.5, 0.5, z)
    #   glEnd
    # end

    # end
  end

end