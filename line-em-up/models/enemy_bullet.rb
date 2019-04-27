require_relative 'dumb_projectile.rb'
require 'opengl'
require 'glu'
require 'glut'

class EnemyBullet < DumbProjectile
  DAMAGE = 3
  COOLDOWN_DELAY = 18
  # Enemy y speeds are negative
  MAX_SPEED      = -10


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini-reverse.png")
  end

  # include Gl
  # include Glu 
  # include Glut

  def draw
    # draw nothing
  end


  def draw_gl
    new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

    height = @image_height.to_f * increment_y

    z = ZOrder::Projectile

    glLineWidth(5 * @scale)
    glBegin(GL_LINES)
      glColor3f(1.0, 0.0, 0.0)
      glVertex3d(new_pos_x, new_pos_y, z)
      glVertex3d(new_pos_x, new_pos_y - height, z)
    glEnd

    # scale = 1.0 * @scale

    # glColor4f(scale, scale, scale, scale / 2)

    # glBegin(GL_QUADS)
    #   glVertex3f(-1.0, +1.0, 0.0);
    #   glVertex3f(-1.0, -1.0, 0.0)
    #   glVertex3f(+1.0, -1.0, 0.0)
    #   glVertex3f(+1.0, +1.0, 0.0)
    # glEnd

  end

  # def draw_gl
  #   new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

  #   height = @image_height.to_f * increment_y

  #   z = ZOrder::Projectile

  #   glLineWidth(5 * @scale)
  #   glBegin(GL_LINES)
  #     glColor3f(1.0, 0.0, 0.0)
  #     glVertex3d(new_pos_x, new_pos_y, z)
  #     glVertex3d(new_pos_x, new_pos_y - height, z)
  #   glEnd
  # end

end