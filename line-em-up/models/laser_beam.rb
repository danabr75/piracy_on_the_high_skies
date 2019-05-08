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

  def self.get_image_hardpoint
    Gosu::Image.new("#{MEDIA_DIRECTORY}/laser_beam_hardpoint.png")
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
      Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
  end

  def get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-beam-hardpoint.png")
  end

  def deactivate
    @active = false
    @laser_particles.each do |particle|
      particle.active = false
    end
  end

  def update mouse_x = nil, mouse_y = nil, object = nil, scroll_factor = 1
    if @inited && @active
      @x = object.x
      @y = object.y
    end
    if !@active && @laser_particles.count == 0
      return false
    else
      found_collision = false
      @laser_particles.reverse.each do |particle|
        if found_collision
          particle.active = false
        elsif particle.collision
          found_collision = true
        end
      end
      @laser_particles.reject! do |particle|
        # puts "LASETER PART UPDATE: #{particle.collision}"
        if @active
          result = !particle.parental_update(nil, nil, object)
          result
        else
          result = !particle.parental_update(nil, nil, nil)
          result
        end
      end

      return true
    end
  end

  def get_draw_ordering
    ZOrder::LaserBeam
  end

  # Furthest active particle in active beam
  def get_furthest_active_particle
    last_active_particle = nil
    if @active
      @laser_particles.reverse.each do |lp|
        if lp.active && lp.y_is_on_screen
          last_active_particle = lp
        else
          break
        end

      end
    end
    return last_active_particle
  end

  def draw
    if @inited
      if @active
        @image.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @scale, @scale)
      end

      return true
    else
      return false
    end
  end

  def draw_gl
    if @inited
      z = ZOrder::Projectile
      new_width1, new_height1, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y - @image_height_half/2, @screen_width         , @screen_height)
      new_width2, new_height2, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x, @y + @image_height_half/2, @screen_width         , @screen_height)
      new_width3, new_height3, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y - @image_height_half/2, @screen_width         , @screen_height)

      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

      glBegin(GL_TRIANGLES)
        glColor4f(0, 1, 0, 0.2)
        glVertex3f(new_width1, new_height1, 0.0)
        glVertex3f(new_width2, new_height2, 0.0)
        glVertex3f(new_width3, new_height3, 0.0)
      glEnd
      # Not going to draw GL the laser particles
      # if false && @laser_particles.count > 0
      #   furthest_laser_particle = get_furthest_active_particle
      #   if furthest_laser_particle
      #     image = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-overlay.png")
      #     image_width_half = image.width  / 2
      #     image_height_half = image.height  / 2

      #     new_width1, new_height1, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x - image_width_half/2, @y - image_height_half/2, @screen_width, @screen_height)
      #     new_width2, new_height2, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x - image_width_half/2, furthest_laser_particle.y + image_height_half/2, @screen_width, @screen_height)
      #     new_width3, new_height3, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x + image_width_half/2, @y - image_height_half/2, @screen_width, @screen_height)
      #     new_width4, new_height4, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x + image_width_half/2, furthest_laser_particle.y + image_height_half/2, @screen_width, @screen_height)

      #     # glEnable(GL_BLEND)
      #     # glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

      #     glBegin(GL_TRIANGLES)
      #       glColor4f(0, 1, 0, 0.4)
      #       glVertex3f(new_width1, new_height1, 0.0)
      #       glVertex3f(new_width2, new_height2, 0.0)
      #       glVertex3f(new_width3, new_height3, 0.0)
      #       # glVertex3f(new_width4, new_height4, 0.0)
      #     glEnd
      #     glBegin(GL_TRIANGLES)
      #       glColor4f(0, 1, 0, 0.4)
      #       # glVertex3f(new_width1, new_height1, 0.0)
      #       glVertex3f(new_width2, new_height2, 0.0)
      #       glVertex3f(new_width3, new_height3, 0.0)
      #       glVertex3f(new_width4, new_height4, 0.0)
      #     glEnd
      #   end
      # end

    end
  end
end