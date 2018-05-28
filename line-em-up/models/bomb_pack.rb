require_relative 'pickup.rb'

class BombPack < Pickup
  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bomb_pack.png", :tileable => true)
  end

  def draw
    # @image.draw_rot(@x, @y, ZOrder::Pickups, @y, 0.5, 0.5, 1, 1)
    draw_rot()
  end

  def collected_by_player player
    player.bombs += 3
  end

end