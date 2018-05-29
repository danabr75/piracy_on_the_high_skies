require 'ostruct'
require_relative 'projectile.rb'

class EnemyBomb < Projectile
  COOLDOWN_DELAY = 50
  MAX_SPEED      = 5
  STARTING_SPEED = 3.0
  INITIAL_DELAY  = 0
  SPEED_INCREASE_FACTOR = 0.0
  DAMAGE = 20
  AOE = 0
  
  MAX_CURSOR_FOLLOW = 4

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bomb.png")
  end

  def draw
    # @image.draw(@x, @y, ZOrder::Projectile, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default)
    # @image.draw(@x, @y, ZOrder::Projectile, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default)
    # draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
    # @image.draw_rot(@x, @y, ZOrder::Projectile, @y, 0.5, 0.5, scale, scale)
    return draw_rot()
  end
  

  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    vx = (self.class.get_starting_speed * @scale) * Math.cos(@angle * Math::PI / 180)

    vy =  (self.class.get_starting_speed * @scale) * Math.sin(@angle * Math::PI / 180)
    # Because our y is inverted
    vy = vy * -1

    @x = @x + vx
    @y = @y + vy

    super(width, height, mouse_x, mouse_y)
  end
end