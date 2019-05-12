require_relative 'launcher.rb'
class BulletLauncher < Launcher
  def init_projectile options
    Bullet.new(@scale, @screen_width, @screen_height, self, options)
  end


  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet_launcher_hardpoint.png")
  end
  def draw
    if @inited
      if @active
        # @image.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @scale, @scale)
      end

      return true
    else
      return false
    end
  end

end