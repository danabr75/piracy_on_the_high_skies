require_relative 'pickup.rb'

class HealthPack < Pickup

  HEALTH_BOOST = 25

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/health_pack_0.png", :tileable => true)
  end

  def draw
    image_rot = (Gosu.milliseconds / 50 % 26)
    if image_rot >= 13
      image_rot = 26 - image_rot
    end 
    image_rot = 12 if image_rot == 13
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_pack_#{image_rot}.png", :tileable => true)
    @image.draw(@x - get_width / 2, @y - get_height / 2, ZOrder::Pickups, @width_scale, @height_scale)
    # super
  end


  def collected_by_player player
    value = player.boost_increase * HEALTH_BOOST
    if player.health + value > player.class::MAX_HEALTH 
      player.health = player.class::MAX_HEALTH
    else
      player.health += value
    end
  end


end