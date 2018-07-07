require_relative 'dumb_projectile.rb'
require_relative 'laser_particle.rb'
require 'opengl'
require 'glu'
require 'glut'

class LaserParticle < DumbProjectile
  attr_accessor :active
  DAMAGE = 1
  # COOLDOWN_DELAY = 1
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def initialize(scale, screen_width, screen_height, object, options = {})
    super(scale, screen_width, screen_height, object, options)
    @active = true
  end

  def get_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/laserbolt.png")
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
  end

  def update mouse_x = nil, mouse_y = nil, player = nil
    @time_alive += 1
    @y > 0 && @y < @screen_height
  end

  def parental_update mouse_x = nil, mouse_y = nil, player = nil
    @y -= @current_speed
    @x = player.x if player && @active
    @y > 0 && @y < @screen_height
  end


  include Gl
  include Glu 
  include Glut

  def draw
    # draw nothing
  end

  def draw_gl
    new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

    height = 15 * increment_y * @scale

    z = ZOrder::Projectile

    # glLineWidth(5 * @scale)
    glLineWidth((10000))
    glBegin(GL_LINES)
    # 22.4% red, 100% green and 7.8% blue
      glColor3f(1, 1.0, 1.0)
      glVertex3d(new_pos_x, new_pos_y, z)
      glVertex3d(new_pos_x, new_pos_y + height, z)
    glEnd
  end

end