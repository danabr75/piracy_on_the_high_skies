require_relative 'dumb_projectile.rb'
require 'gosu'
# require 'opengl'
# require 'glu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

# For opengl-bindings
# OpenGL.load_lib()

# GLUT.load_lib()


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


  def draw
    # draw nothing
    @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)
  end

  def initialize(scale, screen_width, screen_height, object, options = {})
    super(scale, screen_width, screen_height, object, options)
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

  # def draw_gl
  #   new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

  #   height = 15 * increment_y

  #   puts "X and Y: #{@x} and #{@y}"
  #   puts "increment Y: #{increment_y}"
  #   puts "increment X: #{increment_x}"

  #   puts "hieght bullet: #{height}"
  #   puts "NEW POS Y: #{new_pos_y}"

  #   z = ZOrder::Projectile

  #   # glLineWidth(5 * @scale)
  #   glLineWidth(5)
  #   glBegin(GL_LINES)
  #   # 22.4% red, 100% green and 7.8% blue
  #     glColor3f(1, 1.0, 1.0)
  #     glVertex3d(new_pos_x, new_pos_y, z)
  #     glVertex3d(new_pos_x, new_pos_y + height, z)
  #   glEnd
  # end


  # end  



  def draw_gl
#     height = 20 * @scale
#     width = 30 * @scale
#     new_pos_x, new_pos_y, increment_x, increment_y = Bullet.convert_x_and_y_to_opengl_coords(@x, @y, @screen_width, @screen_height)
#     new_width1, new_height1, increment_x, increment_y = Bullet.convert_x_and_y_to_opengl_coords(@x + width / 2, @y, @screen_width, @screen_height)
#     new_width2, new_height2, increment_x, increment_y = Bullet.convert_x_and_y_to_opengl_coords(@x, @y + height, @screen_width, @screen_height)
#     new_width3, new_height3, increment_x, increment_y = Bullet.convert_x_and_y_to_opengl_coords(@x - width / 2, @y, @screen_width, @screen_height)

#     # height = 55 * increment_y * @scale
#     # width  = 55 * increment_x * @scale

#     z = ZOrder::Projectile

#     # glLineWidth(5 * @scale)
#     # scale = 1.0 * @scale


#     glBegin(GL_TRIANGLES)
#       glColor4f(1, 0.5, 0.5, get_draw_ordering)
#       glVertex3f(new_width1, new_height1, 0.0)
#       glVertex3f(new_width2, new_height2, 0.0)
#       glVertex3f(new_width3, new_height3, 0.0)
#     glEnd

#     # glBegin(GL_TRIANGLES)
#     #   glColor4f(1, 1, 1, 1)
#     #   glVertex3f(new_width1, new_height3 + 0.1, 0.0)
#     #   glVertex3f(new_width3, new_height2 + 0.1, 0.0)
#     #   glVertex3f(new_width2, new_height1 + 0.1, 0.0)
#     # glEnd

#     new_width1, new_height1, increment_x, increment_y = Bullet.convert_x_and_y_to_opengl_coords(@x - width / 2, @y + height, @screen_width         , @screen_height)
#     new_width2, new_height2, increment_x, increment_y = Bullet.convert_x_and_y_to_opengl_coords(@x            , @y         , @screen_width, @screen_height)
#     new_width3, new_height3, increment_x, increment_y = Bullet.convert_x_and_y_to_opengl_coords(@x + width / 2, @y + height, @screen_width         , @screen_height)
#     glBegin(GL_TRIANGLES)
#       glColor4f(0.5, 1, 0.5, get_draw_ordering)
#       glVertex3f(new_width1, new_height1, 0.0)
#       glVertex3f(new_width2, new_height2, 0.0)
#       glVertex3f(new_width3, new_height3, 0.0)
#     glEnd


# # =======
# #     glLineWidth(20 * @scale)
# #     glBegin(GL_LINES)
# #     # 22.4% red, 100% green and 7.8% blue
# #       glColor3f(1, 1.0, 1.0)
# #       glVertex3d(new_pos_x, new_pos_y, z)
# #       glVertex3d(new_pos_x, new_pos_y + height, z)
#     # glEnd
# # >>>>>>> 8012b34281af3e19bb5f897bcab2161c1a00e7b0


  end





end
