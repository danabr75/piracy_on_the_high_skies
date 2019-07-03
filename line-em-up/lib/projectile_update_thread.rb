module ProjectileUpdateThread

  def self.create_new projectile, args
    window  = args[0]
    mouse_x = args[1]
    mouse_y = args[2]
    player  = args[3]
    t = Thread.new(projectile, window, mouse_x, mouse_y, player) do |local_projectile, local_window, local_mouse_x, local_mouse_y, local_player|
      results = local_projectile.update(local_mouse_x, local_mouse_y, local_player)

      results[:graphical_effects].each do |effect|
        local_window.graphical_effects << effect
      end

      # local_window.projectiles.delete(local_projectile.id) if !local_projectile.is_alive
      local_window.remove_projectile_ids << local_projectile.id if !local_projectile.is_alive
    end
    return t
  end

end