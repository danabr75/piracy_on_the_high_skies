require_relative 'dumb_projectile.rb'
require_relative 'laser_particle.rb'
require 'opengl'
require 'glu'
require 'glut'

# Should be LaserLauncher
class LaserLauncher < Launcher
  attr_accessor :x, :y, :active, :projectiles, :image_path, :test, :inited
  # DAMAGE = 0.001
  # Doesn't work
  COOLDOWN_DELAY = 0
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  HARDPOINT_NAME = "laser_launcher"

  # def init_projectile init_angle, options
  #   LaserParticle.new(@scale, @screen_pixel_width, @screen_pixel_height, self, init_angle, options)
  # end
  
  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/#{HARDPOINT_NAME}/hardpoint.png")
  end

  def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, object, options = {})
    raise "MISSING OPTIONS HERE #{width_scale}, #{height_scale}, #{map_width}, #{map_height}" if [width_scale, height_scale, map_pixel_width, map_pixel_height].include?(nil)
    options[:relative_y_padding] = -(object.image_height_half)
    puts "START LASER BEAM: #{options}"
    super(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, object, options)
    @active = true
    @projectiles = []
    @image_optional = self.class.get_image
    @inited = true
    @cooldown_wait = 0
  end

  def self.get_image
    # optional image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
  end

  # def self.get_hardpoint_image
  #   Gosu::Image.new("#{MEDIA_DIRECTORY}/laser_beam_hardpoint.png")
  # end

  def get_cooldown
    self.class::COOLDOWN_DELAY
  end

  # only needed for is-head command
  def attack initial_angle, location_x, location_y, pointer
    if @cooldown_wait <= 0
      @cooldown_wait = get_cooldown
      options = {damage_increase: @damage_increase}
      if @projectiles.count == 0
        options[:is_head] = true
      end
      raise "MISSING OPTIONS HERE #{initial_angle}, #{location_x}, #{location_y}, #{@screen_map_width}, #{@screen_map_height}" if [initial_angle, location_x, location_y, @screen_map_width, @screen_map_height].include?(nil)
      projectile = LaserParticle.new(@scale, @screen_pixel_width, @screen_pixel_height, @width_scale, @height_scale, self, initial_angle, location_x, location_y, @screen_map_width, @screen_map_height, options)
      @projectiles << projectile
      return projectile
    end
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
    @projectiles.each do |particle|
      particle.active = false
    end
  end

  # custom
  def update mouse_x = nil, mouse_y = nil, object = nil, scroll_factor = 1
    @cooldown_wait -= 1.0 if @cooldown_wait > 0.0
    if @inited && @active
      @x = object.x
      @y = object.y
    end
    if !@active && @projectiles.count == 0
      return false
    else
      found_collision = false
      @projectiles.reverse.each do |particle|
        if found_collision
          particle.active = false
        elsif particle.collision
          found_collision = true
        end
      end
      @projectiles.reject! do |particle|
        # puts "LASETER PART UPDATE: #{particle.collision}"
        if @active && particle.active
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

  # def get_draw_ordering
  #   ZOrder::LaserBeam
  # end

  # Furthest active particle in active beam
  def get_furthest_active_particle
    last_active_particle = nil
    if @active
      @projectiles.reverse.each do |lp|
        if lp.active && lp.y_is_on_screen
          last_active_particle = lp
        else
          break
        end

      end
    end
    return last_active_particle
  end

  # def draw
  #   if @inited
  #     if @active
  #       if @image_optional
  #         @image_optional.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @width_scale, @height_scale)
  #       end
  #     end

  #     return true
  #   else
  #     return false
  #   end
  # end

  def draw_gl
    if @inited
      z = ZOrder::Projectile
      new_width1, new_height1, increment_x, increment_y = GeneralObject.convert_x_and_y_to_opengl_coords(@x - @image_width_half/8, @y - @image_height_half/2, @screen_pixel_width         , @screen_pixel_height)
      new_width2, new_height2, increment_x, increment_y = GeneralObject.convert_x_and_y_to_opengl_coords(@x, @y + @image_height_half/8, @screen_pixel_width         , @screen_pixel_height)
      new_width3, new_height3, increment_x, increment_y = GeneralObject.convert_x_and_y_to_opengl_coords(@x + @image_width_half/8, @y - @image_height_half/2, @screen_pixel_width         , @screen_pixel_height)

      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

      glBegin(GL_TRIANGLES)
        glColor4f(0, 1, 0, 0.2)
        glVertex3f(new_width1, new_height1, 0.0)
        glVertex3f(new_width2, new_height2, 0.0)
        glVertex3f(new_width3, new_height3, 0.0)
      glEnd
      # Not going to draw GL the laser particles - not working correctly
      # if @projectiles.count > 0
      #   furthest_laser_particle = get_furthest_active_particle
      #   if furthest_laser_particle
      #     image = Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-middle-overlay.png")
      #     image_width_half = image.width  / 2
      #     image_height_half = image.height  / 2

      #     new_width1, new_height1, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x - image_width_half/4, @y - image_height_half/2, @screen_pixel_width, @screen_pixel_height)
      #     new_width2, new_height2, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x - image_width_half/4, furthest_laser_particle.y + image_height_half/2, @screen_pixel_width, @screen_pixel_height)
      #     new_width3, new_height3, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x + image_width_half/4, @y - image_height_half/2, @screen_pixel_width, @screen_pixel_height)
      #     new_width4, new_height4, increment_x, increment_y = LaserParticle.convert_x_and_y_to_opengl_coords(@x + image_width_half/4, furthest_laser_particle.y + image_height_half/2, @screen_pixel_width, @screen_pixel_height)

      #     # glEnable(GL_BLEND)
      #     # glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

      #     glBegin(GL_TRIANGLES)
      #       glColor4f(0, 1, 0, 1)
      #       glVertex3f(new_width1, new_height1, 0.0)
      #       glVertex3f(new_width2, new_height2, 0.0)
      #       glVertex3f(new_width3, new_height3, 0.0)
      #       # glVertex3f(new_width4, new_height4, 0.0)
      #     glEnd
      #     glBegin(GL_TRIANGLES)
      #       glColor4f(0, 1, 0, 1)
      #       # glVertex3f(new_width1, new_height1, 0.0)
      #       glVertex3f(new_width2, new_height2, 0.0)
      #       glVertex3f(new_width3, new_height3, 0.0)
      #       glVertex3f(new_width4, new_height4, 0.0)
      #     glEnd
      #   end
      # end

    end
  end

  def self.name
    "Laser Launcher"
  end

  def self.description
    "This does not work yet. Do not fire"
  end

end