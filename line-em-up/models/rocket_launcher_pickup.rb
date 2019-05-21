require_relative 'pickup.rb'

class RocketLauncherPickup < Pickup

  NAME = 'rocket_launcher'

  def initialize(scale, screen_width, screen_height, width_scale, height_scale, x = nil, y = nil, options = {})
    @x = x || rand(screen_width)
    @y = y || 0
    super(scale, screen_width, screen_height, width_scale, height_scale, @x, @y, options)
  end

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/rocket_launcher.png")
  end

  # def draw
  # end

  # def update
  # end

  def collected_by_player player
    player.add_hard_point(RocketLauncherPickup::NAME)
  end
end