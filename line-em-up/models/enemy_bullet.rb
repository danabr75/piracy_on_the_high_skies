require_relative 'projectile.rb'

class EnemyBullet < Projectile
  DAMAGE = 5
  COOLDOWN_DELAY = 30
  MAX_SPEED      = 5

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini-reverse.png")
  end

  def initialize(scale, width, height, object, mouse_x = nil, mouse_y = nil, options = {})
    @scale = scale
    @time_alive = 0
    @image = get_image
    # @color = Gosu::Color.new(0xff_000000)
    # @color.red = rand(255 - 40) + 40
    # @color.green = rand(255 - 40) + 40
    # @color.blue = rand(255 - 40) + 40
    if LEFT == options[:side]
      @x = object.x - (object.get_width / 2)
      @y = object.y# - player.get_height
    elsif RIGHT == options[:side]
      @x = (object.x + object.get_width / 2) - 4
      @y = object.y# - player.get_height
    else
      @x = object.x
      @y = object.y
    end
  end

  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    @y += self.class.get_max_speed * @scale
    # Return false when out of screen (gets deleted then)
    @y > 0
    # super(mouse_x, mouse_y)
  end
end