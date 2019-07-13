module ZOrder
  # MenuBackground appears underneath HardPointClickableLocation
  # Hardpoint appears on top of HardPointClickableLocation
  # I don't understand this
  # The more right, the more on top you are.
  # Left should be under everything
  Background, Building, LaserParticle, BigExplosions, Pickups, AIShip, AIHardpointBase, AIHardpoint, AIProjectile, Player, HardpointBase, Hardpoint, PlayerProjectile, MenuBackground, HardPointClickableLocation, Launcher, SmallExplosions, MiniMap, MiniMapIcon, UI, CurserUIBuffer, Cursor = *0..50
end

# [2] pry(main)> ZOrder::Ship
# => 8
# [3] pry(main)> ZOrder::HardPointClickableLocation
# => 9
# [4] pry(main)> ZOrder::Hardpoint
# => 10