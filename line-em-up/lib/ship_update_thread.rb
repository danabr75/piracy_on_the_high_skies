module ShipUpdateThread

  def self.update window, ship, args
    # Thread.exit if !ship.inited
    # mouse_x = args[0]
    # mouse_y = args[1]
    # player_map_pixel_x  = args[2]
    # player_map_pixel_y  = args[3]
    # air_targets  = args[4]
    # land_targets = args[5]
    # options = args[6] || {}
    # options[:is_thread] = true
    results = ship.update(*args)
    # puts "SHIIP DEAD" if !ship.is_alive
    # puts "SHIP UPDATE RESULT - SHIPWRECK"  if results[:shipwreck]
    # puts results.inspect  if results[:shipwreck]

    results[:projectiles].each do |projectile|
      window.add_projectiles << projectile if projectile
    end
    results[:destructable_projectiles].each do |projectile|
      window.add_destructable_projectiles << projectile if projectile
    end
    results[:graphical_effects].each do |effect|
      window.graphical_effects.push(effect) if effect
    end
    # results[:shipwreck].each do |shipwreck|
    window.add_shipwrecks.push(results[:shipwreck]) if results[:shipwreck]
    # end

    window.remove_ship_ids << ship.id if !results[:is_alive]
  end

end