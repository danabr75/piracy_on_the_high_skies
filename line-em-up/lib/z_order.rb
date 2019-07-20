module ZOrder
  # MenuBackground appears underneath HardPointClickableLocation
  # Hardpoint appears on top of HardPointClickableLocation
  # I don't understand this
  # The more right, the more on top you are.
  # Left should be under everything
  Background, Building, GroundProjectile, AIShip, AIFactionEmblem, AIHardpointBase, AIHardpoint, AIProjectile, Player, FactionEmblem, HardpointBase, Hardpoint, PlayerProjectile, Explosions, MenuBackground, HardPointClickableLocation, Launcher, MiniMap, MiniMapIcon, PlayerMiniMapIcon, SpecialMiniMapIcon, UI, CurserUIBuffer, Cursor = *0..50
end

# [2] pry(main)> ZOrder::Ship
# => 8
# [3] pry(main)> ZOrder::HardPointClickableLocation
# => 9
# [4] pry(main)> ZOrder::Hardpoint
# => 10