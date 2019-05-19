require_relative 'dumb_projectile.rb'
require_relative 'laser_particle.rb'
require 'opengl'
require 'glu'
require 'glut'

class Launcher < DumbProjectile
  attr_accessor :x, :y, :active, :projectiles, :image_path, :test, :inited, :cooldown_wait
  # DAMAGE = 0.001
  COOLDOWN_DELAY = 15
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def init_projectile
    raise "Override me"
  end


  def initialize(scale, screen_width, screen_height, object, map_width, map_height, options = {})
    options[:relative_y_padding] = -(object.image_height_half)
    super(scale, screen_width, screen_height, object, nil, nil, map_width, map_height, options)
    @active = true
    @projectiles = []
    @image_optional = self.class.get_image#Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")

    @inited = true
    @cooldown_wait = 0
    # @image_angle = options[:image_angle] || 0
    # puts "IMAGE ANGLE: #{@image_angle}"
    # raise "STOP "
  end

  def get_cooldown
    COOLDOWN_DELAY
  end

  # Used via hardpoint
  def self.get_hardpoint_image
    # raise "Override me"
    # default
    Gosu::Image.new("#{MEDIA_DIRECTORY}/laser_beam_hardpoint.png")
  end

  def attack initial_angle, location_x, location_y, pointer
    if @cooldown_wait <= 0
      options = {damage_increase: @damage_increase}
      projectile = init_projectile(options)
      @projectiles << projectile
      @cooldown_wait = get_cooldown
      return projectile
    end
  end

  # Get image is called before the initialization is complete
  def self.get_image
    # optional image
    # Gosu::Image.new("#{MEDIA_DIRECTORY}/laser-start-overlay.png")
  end
  # In generalobject
  # def get_image
  #   self.class.get_image
  # end

  def get_hardpoint_image
    # default
    Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoint_empty.png")
  end

  def deactivate
    @active = false
    # @projectiles.each do |particle|
    #   particle.active = false
    # end
  end

  def update mouse_x = nil, mouse_y = nil, object = nil, scroll_factor = 1
    if @inited && @active
      @x = object.x
      @y = object.y
    end
    @cooldown_wait -= 1.0 if @cooldown_wait > 0.0
    if !@active && @projectiles.count == 0
      return false
    else
      # @projectiles.reject! do |particle|
      #   !particle.parental_update(nil, nil, nil)
      # end

      return true
    end
  end

  def get_draw_ordering
    ZOrder::Launcher
  end

  # Furthest active particle in active beam
  # def get_furthest_active_particle
  #   last_active_particle = nil
  #   if @active
  #     @projectiles.reverse.each do |lp|
  #       if lp.active && lp.y_is_on_screen
  #         last_active_particle = lp
  #       else
  #         break
  #       end

  #     end
  #   end
  #   return last_active_particle
  # end

  def draw
    if @inited
      if @active
        if @image_optional
          # if @image_angle != nil
          #   @image_optional.draw_rot(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @image_angle, 0.5, 0.5, @scale, @scale)
          # else
            @image_optional.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @scale, @scale)
          # end
        end
      end

      return true
    else
      return false
    end
  end

  def draw_gl
    # if @inited
    #   z = ZOrder::Projectile
    #   new_width1, new_height1, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y - @image_height_half/2, @screen_width         , @screen_height)
    #   new_width2, new_height2, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x, @y + @image_height_half/2, @screen_width         , @screen_height)
    #   new_width3, new_height3, increment_x, increment_y = LaserBeam.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y - @image_height_half/2, @screen_width         , @screen_height)

    #   glEnable(GL_BLEND)
    #   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    #   glBegin(GL_TRIANGLES)
    #     glColor4f(0, 1, 0, 0.2)
    #     glVertex3f(new_width1, new_height1, 0.0)
    #     glVertex3f(new_width2, new_height2, 0.0)
    #     glVertex3f(new_width3, new_height3, 0.0)
    #   glEnd
    # end
  end
end