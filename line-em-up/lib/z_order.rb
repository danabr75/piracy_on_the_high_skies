module ZOrder
  # MenuBackground appears underneath HardPointClickableLocation
  # Hardpoint appears on top of HardPointClickableLocation
  # I don't understand this
  Background, Building, LaserParticle, Projectile, BigExplosions, Pickups, AIShip, Player, Ship, Hardpoint, MenuBackground, HardPointClickableLocation, Launcher, SmallExplosions, UI, CurserUIBuffer, Cursor = *0..50
end

# [2] pry(main)> ZOrder::Ship
# => 8
# [3] pry(main)> ZOrder::HardPointClickableLocation
# => 9
# [4] pry(main)> ZOrder::Hardpoint
# => 10