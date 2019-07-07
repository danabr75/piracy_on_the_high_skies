module ShipUpdateThread

  def self.update window, ship, args
    mouse_x = args[0]
    mouse_y = args[1]
    player_map_pixel_x  = args[2]
    player_map_pixel_y  = args[3]
    air_targets  = args[4]
    land_targets = args[5]

    results = ship.update(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, air_targets, land_targets, {is_thread: true})
    # puts "SHIIP DEAD" if !ship.is_alive
    # puts "SHIP UPDATE RESULT - SHIPWRECK"  if results[:shipwreck]
    # puts results.inspect  if results[:shipwreck]

    results[:projectiles].each do |projectile|
      window.add_projectiles << projectile if projectile
    end
    results[:destructable_projectiles].each do |projectile|
      window.destructable_projectiles.push(projectile) if projectile
    end
    results[:graphical_effects].each do |effect|
      window.graphical_effects.push(effect) if effect
    end
    # results[:shipwreck].each do |shipwreck|
    window.shipwrecks.push(results[:shipwreck]) if results[:shipwreck]
    # end

    window.remove_ship_ids << ship.id if !results[:is_alive]
  end

end