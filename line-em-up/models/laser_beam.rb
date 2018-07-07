require_relative 'dumb_projectile.rb'
require_relative 'laser_particle.rb'
require 'opengl'
require 'glu'
require 'glut'

class LaserBeam < DumbProjectile
  attr_accessor :x, :y, :active, :laser_particles
  DAMAGE = 5
  COOLDOWN_DELAY = 0.001
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def initialize(scale, screen_width, screen_height, object, options = {})
    super(scale, screen_width, screen_height, object, options)
    @active = true
    @laser_particles = []
  end

  def attack
    @laser_particles << LaserParticle.new(@scale, @screen_width, @screen_height, self, {damage_increase: @damage_increase})
  end

  def get_image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/laserbolt.png")
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
  end

  def update mouse_x = nil, mouse_y = nil, player = nil
    if !@active && @laser_particles.count == 0
      puts "RETURING FALSE"
      return false
    else
      puts "PARTICLE COUNT: #{@laser_particles.count}"
      @laser_particles.reject! do |particle|
        puts "updating particle: #{particle.x} and #{particle.y}"
        if @active
          result = !particle.update(nil, nil, player)
          puts "PARTICLE REUTERINING: #{result}"
          result
        else
          result = !particle.update
          puts "PARTICLE REUTERINING: #{result}"
          result
        end
      end
      return true
    end
  end


  # include Gl
  # include Glu 
  # include Glut

  def draw
    # # draw nothing
    # @laser_particles.each do |particle|
    #   particle.draw
    # end

  end

  def draw_gl
    @laser_particles.each do |particle|
      particle.draw_gl
    end
    # new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords

    # height = 15 * increment_y * @scale

    # z = ZOrder::Projectile

    # # glLineWidth(5 * @scale)
    # glLineWidth((10000))
    # glBegin(GL_LINES)
    # # 22.4% red, 100% green and 7.8% blue
    #   glColor3f(1, 1.0, 1.0)
    #   glVertex3d(new_pos_x, new_pos_y, z)
    #   glVertex3d(new_pos_x, new_pos_y + height, z)
    # glEnd
  end

end