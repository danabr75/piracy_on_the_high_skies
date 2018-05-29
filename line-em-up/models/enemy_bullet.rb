require_relative 'dumb_projectile.rb'

class EnemyBullet < DumbProjectile
  DAMAGE = 5
  COOLDOWN_DELAY = 30
  # Enemy y speeds are negative
  MAX_SPEED      = -5

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini-reverse.png")
  end
end