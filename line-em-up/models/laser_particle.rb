require_relative 'dumb_projectile.rb'
require_relative 'laser_particle.rb'
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

class LaserParticle < DumbProjectile
  attr_accessor :active, :position, :image_background, :background_image_width_half, :background_image_height_half, :collision
  DAMAGE = 0.4
  # DAMAGE = 0.1
  # COOLDOWN_DELAY = 1
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def initialize(scale, screen_width, screen_height, object, options = {})
    options[:debug] = true

    options[:relative_y_padding] = -(object.image_height_half)
    super(scale, screen_width, screen_height, object, options)
    @active = true
    if options[:is_head]
      @position = :is_head
      @image_background = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-end-background.png")
      @image            = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-end-overlay.png")
    elsif options[:is_tail]
      @position = :is_tail
      @image_background = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-background.png")
      @image            = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
    else
      @image_background = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-background.png")
      @image            = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-overlay-half.png")
    end

    @background_image_width_half = get_background_image.width / 2
    @background_image_height_half = get_background_image.height / 2
    @collision = false
  end

  def get_draw_ordering
    ZOrder::LaserParticle
  end

  def get_background_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-overlay.png")
    if @position == :is_head
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-end-background.png")
    elsif @position == :is_tail
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-background.png")
    else
      return Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-background.png")
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

  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    if @inited
      @time_alive += 1
      @y > 0 && @y < @screen_height
    end
  end

  def parental_update mouse_x = nil, mouse_y = nil, player = nil
    if @inited
      @y -= @current_speed
      @x = player.x if player && @active
      @y > 0 && @y < @screen_height
    end
  end

  def collision_triggers
    @collision = true
  end


  # include Gl
  # include Glu 
  # include Glut

  def draw
    if @inited# && !@active
    #   @image_background.draw(@x - @background_image_width_half, @y - @background_image_height_half, get_draw_ordering, @scale, @scale)
      @image.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @scale, @scale)
    end
  end

  def draw_gl
    # if @inited# && !@active
    #   new_width1, new_height1, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x - @image_width_half/8, @y - @image_height_half/2, @screen_width, @screen_height)
    #   new_width2, new_height2, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x - @image_width_half/8, @y + @image_height_half/2, @screen_width, @screen_height)
    #   new_width3, new_height3, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x + @image_width_half/8, @y - @image_height_half/2, @screen_width, @screen_height)
    #   new_width4, new_height4, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x + @image_width_half/8, @y + @image_height_half/2, @screen_width, @screen_height)

    #   glEnable(GL_BLEND)
    #   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    #   glBegin(GL_TRIANGLES)
    #     glColor4f(0, 1, 0, 0.2)
    #     glVertex3f(new_width1, new_height1, 0.0)
    #     glVertex3f(new_width2, new_height2, 0.0)
    #     glVertex3f(new_width3, new_height3, 0.0)
    #     # glVertex3f(new_width4, new_height4, 0.0)
    #   glEnd
    #   glBegin(GL_TRIANGLES)
    #     glColor4f(0, 1, 0, 0.2)
    #     # glVertex3f(new_width1, new_height1, 0.0)
    #     glVertex3f(new_width2, new_height2, 0.0)
    #     glVertex3f(new_width3, new_height3, 0.0)
    #     glVertex3f(new_width4, new_height4, 0.0)
    #   glEnd
    # end
  end

end