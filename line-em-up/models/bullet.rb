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

  # def convert_x_and_y_to_opengl_coords
  #   # Don't have to recalce these 4 variables on each draw, save to singleton somewhere?
  #   middle_x = @screen_width / 2
  #   puts "CREEN HIEGHT: #{ @screen_height}"
  #   middle_y = @screen_height / 2
  #   increment_x = 1.0 / middle_x
  #   increment_y = 1.0 / middle_y
  #   new_pos_x = (@x - middle_x) * increment_x
  #   new_pos_y = (@y - middle_y) * increment_y
  #   # Inverted Y
  #   new_pos_y = new_pos_y * -1

  #   # height = @image_height.to_f * increment_x
  #   return [new_pos_x, new_pos_y, increment_x, increment_y]
  # end  

  def draw_gl
    new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

    height = 15 * increment_y * @scale

    puts "X and Y: #{@x} and #{@y}"
    puts "increment Y: #{increment_y}"
    puts "increment X: #{increment_x}"

    puts "hieght bullet: #{height}"
    puts "NEW POS Y: #{new_pos_y}"

    z = ZOrder::Projectile

    # glLineWidth(5 * @scale)
    glLineWidth(20 * @scale)
    glBegin(GL_LINES)
    # 22.4% red, 100% green and 7.8% blue
      glColor3f(1, 1.0, 1.0)
      glVertex3d(new_pos_x, new_pos_y, z)
      glVertex3d(new_pos_x, new_pos_y + height, z)
    glEnd
  end

end