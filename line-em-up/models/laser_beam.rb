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
    super(scale, screen_width, screen_height, object, options)
    @active = true
    @laser_particles = []
    puts "@object. #{@object}"
    @image_path = object.get_image_path
    puts "AHA HERE"
    puts "@image_path: #{@image_path}"
    @test = 'test'
    @inited = true
  end

  def attack
    options = {damage_increase: @damage_increase}
    if laser_particles.count == 1
      options[:head] = true
    elsif false # tail something how
    end
    @laser_particles << LaserParticle.new(@scale, @screen_width, @screen_height, self, options)
    return @laser_particles.last
  end

  # Get image is called before the initialization is complete
  def get_image
    if @inited
      # puts "GET IMAGE - v2"
      # puts "PARTICLE COUNT: #{@laser_particles.count}"
      # puts @laser_particles.inspect
      # puts "image_path: #{@image_path}"
      # Gosu::Image.new(@image_path)
      Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship.png")
      # puts 'SELF.object.getimage'
      # puts self.object
      # self.object.get_image
    else
      Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
    end
  end

  def deactivate
    @active = false
    @laser_particles.each do |particle|
      particle.active = false
    end
  end

  def update mouse_x = nil, mouse_y = nil, player = nil
    if @active
      @x = player.x
      @y = player.y
    end
    if !@active && @laser_particles.count == 0
      puts "RETURING FALSE"
      return false
    else
      puts "PARTICLE COUNT: #{@laser_particles.count}"
      @laser_particles.reject! do |particle|
        puts "updating particle: #{particle.x} and #{particle.y}"
        if @active
          result = !particle.parental_update(nil, nil, player)
          puts "PARTICLE REUTERINING: #{result}"
          result
        else
          result = !particle.parental_update(nil, nil, nil)
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

  # def draw
  #   # # draw nothing
  #   # @laser_particles.each do |particle|
  #   #   particle.draw
  #   # end

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