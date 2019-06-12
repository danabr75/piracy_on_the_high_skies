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

  # def update mouse_x, mouse_y, player
  #   # get_map_pixel_location_from_map_tile_location
  #   return super(mouse_x, mouse_y, player, {persist_even_if_not_alive: true})
  # end

  # def self.tile_draw_gl v1, v2, v3, v4
  #   @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
  #   @info = @image2.gl_tex_info

  #   info = @info
  #   colors = [1, 1, 1, 1]
  #   glBindTexture(GL_TEXTURE_2D, info.tex_name)
  #   glBegin(GL_TRIANGLE_STRIP)
  #     # bottom left 
  #     glTexCoord2d(info.left, info.bottom)
  #     glColor4d(colors[0], colors[1], colors[2], colors[3])
  #     glVertex3d(v1[0], v1[1], v1[2])

  #     # Top Left
  #     glTexCoord2d(info.left, info.top)
  #     glColor4d(colors[0], colors[1], colors[2], colors[3])
  #     glVertex3d(v2[0], v2[1], v2[2])

  #     # bottom Right
  #     glTexCoord2d(info.right, info.bottom)
  #     glColor4d(colors[0], colors[1], colors[2], colors[3])
  #     glVertex3d(v3[0], v3[1], v3[2])

  #     # top right
  #     glTexCoord2d(info.right, info.top)
  #     glColor4d(colors[0], colors[1], colors[2], colors[3])
  #     glVertex3d(v4[0], v4[1], v4[2])
  #   glEnd
  # end


  def collected_by_player player
    value = player.boost_increase * HEALTH_BOOST
    if player.health + value > player.class::MAX_HEALTH 
      player.health = player.class::MAX_HEALTH
    else
      player.health += value
    end
  end


end