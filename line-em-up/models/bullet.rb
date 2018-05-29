require_relative 'dumb_projectile.rb'

class Bullet < DumbProjectile
  DAMAGE = 5
  COOLDOWN_DELAY = 30
  # Friendly projects are + speeds
  MAX_SPEED      = 5

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
  end
end