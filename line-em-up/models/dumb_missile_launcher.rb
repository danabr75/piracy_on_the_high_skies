require_relative 'launcher.rb'
class DumbMissileLauncher < Launcher
  MISSILE_LAUNCHER_MIN_ANGLE = 75.0
  MISSILE_LAUNCHER_MAX_ANGLE = 105.0
  MISSILE_LAUNCHER_INIT_ANGLE = 90.0
  # COOLDOWN_DELAY = 15

  def init_projectile initial_angle, location_x, location_y, pointer, options
    # Bullet.new(@scale, @screen_width, @screen_height, self, options)
    Missile.new(@scale, @screen_width, @screen_height, @width_scale, @height_scale, self, pointer.x, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE - initial_angle, MISSILE_LAUNCHER_MAX_ANGLE - initial_angle, MISSILE_LAUNCHER_INIT_ANGLE - initial_angle, location_x, location_y, @screen_map_width, @screen_map_height, {damage_increase: @damage_increase})
  end


  def self.get_hardpoint_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_launcher.png")
  end
  # def draw
  #   if @inited
  #     if @active
  #       # @image.draw(@x - @image_width_half, @y - @image_height_half, get_draw_ordering, @width_scale, @height_scale)
  #     end

  #     return true
  #   else
  #     return false
  #   end
  # end

  def attack initial_angle, location_x, location_y, pointer
    # puts "DUMB MISSILE LAUNCHER ATTACK"
    if @cooldown_wait <= 0
      options = {damage_increase: @damage_increase}
      projectile = init_projectile(initial_angle, location_x, location_y, pointer, options)
      # @projectiles << projectile
      @cooldown_wait = get_cooldown
      return projectile
    end
  end

end