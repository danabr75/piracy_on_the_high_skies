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
    player.rockets += 35
  end

end