require_relative 'pickup.rb'

class MissilePack < Pickup
  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_pack.png", :tileable => true)
  end

  def draw
    # @image.draw_rot(@x, @y, ZOrder::Pickups, @y, 0.5, 0.5, 1, 1)
    draw_rot()
  end

  def collected_by_player player
    value = 35
    boost_increase = player.boost_increase
    if boost_increase > 1
      boost_increase = 1 + ((boost_increase - 1) / 10)
    end
    player.rockets += (boost_increase * value).round
  end

end