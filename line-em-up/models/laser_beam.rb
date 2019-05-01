require_relative 'dumb_projectile.rb'
require_relative 'laser_particle.rb'
require 'opengl'
require 'glu'
require 'glut'

class LaserBeam < DumbProjectile
  attr_accessor :x, :y, :active, :laser_particles, :image_path, :test, :inited
  # DAMAGE = 0.001
  COOLDOWN_DELAY = 1
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def initialize(scale, screen_width, screen_height, object, options = {})
    options[:relative_y_padding] = -(object.image_height_half)
    puts "START LASER BEAM: #{options}"
    super(scale, screen_width, screen_height, object, options)
    @active = true
    @laser_particles = []
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
    @inited = true
  end

  def attack
    options = {damage_increase: @damage_increase}
    if laser_particles.count == 0
      options[:is_head] = true
    end
    @laser_particles << LaserParticle.new(@scale, @screen_width, @screen_height, self, options)
    return @laser_particles.last
  end

  # Get image is called before the initialization is complete
  def get_image
    # if @inited
      # getting spaceship size
      Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
    # else
      # Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
    # end
  end

  def deactivate
    @active = false
    @laser_particles.each do |particle|
      particle.active = false
    end
    # if @laser_particles.count >= 2
    #   @laser_particles.last.position = :is_tail
    # end
  end

  def update mouse_x = nil, mouse_y = nil, player = nil
    if @active
      @x = player.x
      @y = player.y - player.image_height_half
    end
    if !@active && @laser_particles.count == 0
      return false
    else
      @laser_particles.reject! do |particle|
        if @active
          result = !particle.parental_update(nil, nil, player)
          result
        else
          result = !particle.parental_update(nil, nil, nil)
          result
        end
      end
      return true
    end
  end


  # include Gl
  # include Glu 
  # include Glut

  def get_draw_ordering
    ZOrder::LaserBeam
  end

  def draw
    if @active
      @image.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @scale, @scale)
      # @image.draw(@x + @image_width_half, @y - @image_height_half, 0, @scale, @scale)
      return true
    else
      return false
    end
  end

  def draw_gl
    if @inited
      z = ZOrder::Projectile
      new_width1, new_height1, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y - @image_height_half/2, @screen_width         , @screen_height)
      new_width2, new_height2, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y + @image_height_half/2, @screen_width         , @screen_height)
      new_width3, new_height3, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y - @image_height_half/2, @screen_width         , @screen_height)
      new_width4, new_height4, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y + @image_height_half/2, @screen_width         , @screen_height)
      glBegin(GL_TRIANGLES)
        glColor4f(0, 1, 0, get_draw_ordering)
        glVertex3f(new_width1, new_height1, 0.0)
        glVertex3f(new_width2, new_height2, 0.0)
        glVertex3f(new_width3, new_height3, 0.0)
        # glVertex3f(new_width4, new_height4, 0.0)
      glEnd
      glBegin(GL_TRIANGLES)
        glColor4f(0, 1, 0, get_draw_ordering)
        # glVertex3f(new_width1, new_height1, 0.0)
        glVertex3f(new_width2, new_height2, 0.0)
        glVertex3f(new_width3, new_height3, 0.0)
        glVertex3f(new_width4, new_height4, 0.0)
      glEnd
    end
  end

  # end

  # def draw_gl
  #   @laser_particles.each do |particle|
  #     particle.draw_gl
  #   end
  #   # new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

  #   # height = 15 * increment_y * @scale

  #   # z = ZOrder::Projectile

  #   # # glLineWidth(5 * @scale)
  #   # glLineWidth((10000))
  #   # glBegin(GL_LINES)
  #   # # 22.4% red, 100% green and 7.8% blue
  #   #   glColor3f(1, 1.0, 1.0)
  #   #   glVertex3d(new_pos_x, new_pos_y, z)
  #   #   glVertex3d(new_pos_x, new_pos_y + height, z)
  #   # glEnd
  # end

end