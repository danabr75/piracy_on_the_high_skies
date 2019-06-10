require_relative 'projectile.rb'

require 'opengl'
# require 'glu'
# require 'glut'

class Missile < Projectile
  attr_reader :x, :y, :time_alive, :mouse_start_x, :mouse_start_y
  COOLDOWN_DELAY = 3
  MAX_SPEED      = 1

  STARTING_SPEED = 0.0
  INITIAL_DELAY  = 0.5
  SPEED_INCREASE_FACTOR = 2
  DAMAGE = 10
  AOE = 0
  
  MAX_CURSOR_FOLLOW = 4
  ADVANCED_HIT_BOX_DETECTION = true

  # def hit_objects(object_groups)
  #   puts "HERE: #{self.class.get_damage}"
  #   super(object_groups)
  # end

  # def initialize(scale, screen_pixel_width, screen_pixel_height, object, end_point_x, end_point_y, angle_min, angle_max, angle_init, options)
  #   super(scale, screen_pixel_width, screen_pixel_height, object, end_point_x, end_point_y, angle_min, angle_max, angle_init, options)
  #   # puts "MYYYY MISSILE ANGLE: #{@angle}"
  # end
  # include Gl
  # include Glu 
  # include Glut

  # def draw
  #   z = ZOrder::Projectile
  #   # @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @width_scale, @height_scale)
  #   # gl do
  #   # points_x = 3
  #   # pounts_y = 10
  #   # Gosu.gl(z) {
  #   #   # glColor3f(r,g,b);
  #   #   0.upto(pounts_y) do |y|
  #   #     0.upto(points_x) do |x|
  #   #       # glColor3f(1.0, 1.0, 0.0)
  #   #       glColor4d(1, 0, 0, z)
  #   #       glBegin(GL_LINES)
  #   #         glColor3f(1.0, 0.0, 0.0)
  #   #         glVertex3d(@x + x, @y + y, z)
  #   #         # glVertex3d(@x - 5, @y , z)
  #   #       glEnd
  #   #     end
  #   #   end
  #   # }

  #   Gosu.gl(z) {
  #     glLineWidth(2.5)
  #     glColor3f(1.0, 0.0, 0.0)
  #     glBegin(GL_LINES)
  #       glVertex3f(0.0, 0.0, 0.0)
  #       glVertex3f(15, 0, 0)
  #     glEnd
  #   }

  #   # end
  # end

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/mini_missile.png")
  end

  def drops
    [
      # Add back in once SE has been updated to display on map, not on screen.
      # SmallExplosion.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y, nil, {ttl: 2, third_scale: true}),
    ]
  end

  # def initialize(object, mouse_x = nil, mouse_y = nil, options = {})
  #   @image = get_image

  #   if LEFT == options[:side]
  #     @x = object.get_x - (object.get_width / 2)
  #     @y = object.get_y# - player.get_height
  #   elsif RIGHT == options[:side]
  #     @x = (object.get_x + object.get_width / 2) - 4
  #     @y = object.get_y# - player.get_height
  #   else
  #     @x = object.get_x
  #     @y = object.get_y
  #   end
  #   @time_alive = 0
  #   @mouse_start_x = mouse_x
  #   @mouse_start_y = mouse_y
  # end
  
  def update mouse_x, mouse_y, player
    # puts "MISSILE: #{@health}"
    return super(mouse_x, mouse_y, player)
  end
  #   new_speed = 0
  #   if @time_alive > self.class.get_initial_delay
  #     new_speed = self.class.get_starting_speed + (self.class.get_speed_increase_factor > 0 ? @time_alive * self.class.get_speed_increase_factor : 0)
  #     new_speed = self.class.get_max_speed if new_speed > self.class.get_max_speed
  #     new_speed = new_speed * @scale
  #   end



  #   vx = 0
  #   vy = 0
  # if new_speed != 0
  #   vx = ((new_speed / 3) * 1) * Math.cos(@angle * Math::PI / 180)

  #   vy = ((new_speed / 3) * 1) * Math.sin(@angle * Math::PI / 180)
  #   vy = vy * -1
  # end

  #   @x = @x + vx
  #   @y = @y + vy

  #   super(mouse_x, mouse_y)
  # end
end