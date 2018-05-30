require_relative 'dumb_projectile.rb'

class EnemyBullet < DumbProjectile
  DAMAGE = 3
  COOLDOWN_DELAY = 18
  # Enemy y speeds are negative
  MAX_SPEED      = -8


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini-reverse.png")
  end
end