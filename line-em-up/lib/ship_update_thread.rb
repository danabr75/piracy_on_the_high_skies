module ShipUpdateThread

  def self.create_new ship, args
    window  = args[0]
    mouse_x = args[1]
    mouse_y = args[2]
    player  = args[3]
    air_targets  = args[4]
    land_targets = args[5]
    # self.mouse_x, self.mouse_y, @player, @ships + [@player], @buildings)
    t = Thread.new(ship, window, mouse_x, mouse_y, player, air_targets, land_targets) do
      |local_ship, local_window, local_mouse_x, local_mouse_y, local_player, local_air_targets, local_land_targets|
      results = local_ship.update(local_mouse_x, local_mouse_y, local_player, local_air_targets, local_land_targets)

      results[:projectiles].each do |projectile|
        local_window.add_projectiles <<  projectile if projectile
      end
      results[:destructable_projectiles].each do |projectile|
        local_window.destructable_projectiles.push(projectile) if projectile
      end
      results[:graphical_effects].each do |effect|
        local_window.graphical_effects.push(effect) if effect
      end
      # results[:shipwreck].each do |shipwreck|
        local_window.shipwrecks.push(results[:shipwreck]) if results[:shipwreck]
      # end
    end
    return t
  end

end