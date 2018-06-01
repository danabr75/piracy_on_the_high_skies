require_relative 'dumb_projectile.rb'
require 'opengl'
# require 'ruby-opengl'
# require 'glu'
# require 'glut'

class Bullet < DumbProjectile
  DAMAGE = 3
  COOLDOWN_DELAY = 20
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def get_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/laserbolt.png")
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
  end

  # include Gl
  # include Glu 
  # include Glut


  def alt_draw
    glClearColor(0.0, 0.2, 0.5, 1.0)
    glClearDepth(0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    # info = @image.gl_tex_info
    glDepthFunc(GL_GEQUAL)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_BLEND)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity 
    glTranslate(0, 0, -4)
  
    # glEnable(GL_TEXTURE_2D)
    # glBindTexture(GL_TEXTURE_2D, info.tex_name)



    middle_x = @screen_width / 2
    puts "MIDDLE X: #{middle_x}"
    middle_y = @screen_height / 2
    puts "MIDDLE Y: #{middle_y}"
    increment_x = 1.0 / middle_x
    increment_y = 1.0 / middle_y
    puts "INcREMENT X : #{increment_x}"
    puts "INcREMENT Y : #{increment_y}"

    puts "PRE X: #{@x}"
    puts "PRE Y: #{@y}"
    puts "MID X: #{(@x - middle_x)}"
    puts "MID Y: #{(@y - middle_y)}"

    new_pos_x = (@x - middle_x) * increment_x
    new_pos_y = (@y - middle_y) * increment_y
    # Inverted Y
    new_pos_y = new_pos_y * -1

    height = @image_height.to_f * increment_x

    puts "NEW POS X: #{new_pos_x}"
    puts "NEW POS Y: #{new_pos_y}"

    z = ZOrder::Projectile
    # @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)
    # gl do
    # points_x = 3
    # pounts_y = 10
    Gosu.gl(z) do
      glLineWidth(5)
      glBegin(GL_LINES)
        glColor3f(1.0, 0.0, 0.0)
        glVertex3d(new_pos_x, new_pos_y, z)
        glVertex3d(new_pos_x, new_pos_y - height, z)
        # glVertex3d(new_pos_x, new_pos_y - increment_y, z)
        # glVertex3d(0, 0, z)
        # glVertex3d(1, 0, z)
      glEnd
    end

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