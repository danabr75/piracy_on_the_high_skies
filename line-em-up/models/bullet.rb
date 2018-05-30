require_relative 'dumb_projectile.rb'

class Bullet < DumbProjectile
  DAMAGE = 3
  COOLDOWN_DELAY = 20
  # Friendly projects are + speeds
  MAX_SPEED      = 15

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
  end
end