# Also taken from the tutorial, but drawn with draw_rot and an increasing angle
# for extra rotation coolness!
require_relative 'pickup.rb'

class Star < Pickup
  POINT_VALUE_BASE = 2
  
  def initialize(scale, screen_width, screen_height, x = nil, y = nil, options = {})
    # @scale = scale
    # @image = get_image
    # @time_alive = 0
    @x = x || rand(screen_width)
    @y = y || 0
    super(scale, screen_width, screen_height, @x, @y, options)
    @color = Gosu::Color.new(0xff_000000)
    @color.red = rand(255 - 40) + 40
    @color.green = rand(255 - 40) + 40
    @color.blue = rand(255 - 40) + 40
  end

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/single_star.png")
  end


  def get_points
    return POINT_VALUE_BASE
  end

  # def get_height
  #   25 * @scale
  # end

  # def get_width
  #   25 * @scale
  # end

  # def get_radius
  #   13 * @scale
  # end  


  def draw
    # img = @image[Gosu.milliseconds / 100 % @image.size];
    # img.draw_rot(@x, @y, ZOrder::Pickups, @y, 0.5, 0.5, @scale, @scale, @color, :add)
    @image.draw_rot(@x, @y, ZOrder::Pickups, @y, 0.5, 0.5, @scale, @scale, @color, :add)
  end
  
  # def update mouse_x = nil, mouse_y = nil
  #   # Move towards bottom of screen
  #   @y += 1
  #   super(mouse_x, mouse_y)
  # end

  def collected_by_player player
    player.attack_speed += 0.02
    if player.attack_speed > Player::MAX_ATTACK_SPEED
      player.attack_speed = Player::MAX_ATTACK_SPEED
      player.health += 1
    end
  end
end