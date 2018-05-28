require_relative 'pickup.rb'

class HealthPack < Pickup
  attr_reader :x, :y

  HEALTH_BOOST = 25

  def initialize(scale, x = nil, y = nil)
    @scale = scale
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_pack_0.png", :tileable => true)
    @x = x
    @y = y
  end

  def draw
    image_rot = (Gosu.milliseconds / 50 % 26)
    if image_rot >= 13
      image_rot = 26 - image_rot
    end 
    image_rot = 12 if image_rot == 13
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_pack_#{image_rot}.png", :tileable => true)
    # @image.draw(@x - get_width / 2, @y - get_height / 2, ZOrder::Pickup)
    super
  end


  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    @y += GLBackground::SCROLLING_SPEED * @scale

    @y < height + get_height
  end

  def collected_by_player player
    if player.health + HEALTH_BOOST > player.class::MAX_HEALTH 
      player.health = player.class::MAX_HEALTH
    else
      player.health += HEALTH_BOOST
    end
  end


end