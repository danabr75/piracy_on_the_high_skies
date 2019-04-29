require_relative 'dumb_projectile.rb'
require_relative 'laser_particle.rb'
require 'gosu'
# require 'opengl'
# require 'glu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT
OpenGL.load_lib()
GLUT.load_lib()

class LaserParticle < DumbProjectile
  attr_accessor :active, :position
  DAMAGE = 0.4
  # COOLDOWN_DELAY = 1
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def initialize(scale, screen_width, screen_height, object, options = {})
    options[:debug] = true
    puts "object.image_height_half: #{object.image_height_half}"

    options[:relative_y_padding] = -(object.image_height_half)
    super(scale, screen_width, screen_height, object, options)
    @active = true
    if options[:is_head]
      @position = :is_head
      # @image_background = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-background.png")
      @image            = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
    elsif options[:is_tail]
      @position = :is_tail
      # @image_background = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-end-background.png")
      @image            = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-end-overlay.png")
    else
      # @image_background = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-background.png")
      @image            = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-overlay.png")
    end
  end

  def get_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-overlay.png")
    if @position == :is_head
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
    elsif @position == :is_tail
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-end-overlay.png")
    else
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-overlay.png")
    end
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


  # include Gl
  # include Glu 
  # include Glut

  def draw
    # draw nothing
    puts "ABOPUT TO DRAWA"
    puts "@x: #{@x}"
    puts "@y: #{@y}"
    puts "get_width: #{get_width}"
    puts "GET HERE"
    puts "get_height: #{get_height}"
    # @image.draw(@x - get_width, @y - get_height, get_draw_ordering, @scale, @scale)
    # @image_background.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)

    @image.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @scale, @scale)
    # @image.draw(@x- get_width, @y, get_draw_ordering, @scale, @scale)
  end

  def draw_gl
    new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

    height = 15 * increment_y * @scale

    z = ZOrder::Projectile

    # glLineWidth(5 * @scale)
    glBegin(GL_LINES)
      # glLineWidth(50.0 * @scale)
    # 22.4% red, 100% green and 7.8% blue
      glColor3f(1, 1.0, 1.0)
      glVertex3d(new_pos_x, new_pos_y, z)
      glVertex3d(new_pos_x, new_pos_y + (height * 1.5), z)
    glEnd

    # glBegin(GL_TRIANGLES) # see lesson01
    #   glColor3f(1, 0, 1.0)
    #   glVertex3f( 0,  1, 0) # see lesson01
    #   glColor3f(0, 1.0, 1.0)
    #   glVertex3f( 1, -1, 0)
    #   glColor3f(0, 0, 1.0)
    #   glVertex3f(-1, -1, 0)
    # glEnd
    

  end

end