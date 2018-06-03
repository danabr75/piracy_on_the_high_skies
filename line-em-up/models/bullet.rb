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
    new_pos_x, new_pos_y, increment_x = convert_x_and_y_to_opengl_coords

    height = @image_height.to_f * increment_x

    z = ZOrder::Projectile

    glLineWidth(5 * @scale)
    glBegin(GL_LINES)
    # 22.4% red, 100% green and 7.8% blue
      glColor3f(1, 1.0, 1.0)
      glVertex3d(new_pos_x, new_pos_y, z)
      glVertex3d(new_pos_x, new_pos_y - height, z)
    glEnd
  end

end