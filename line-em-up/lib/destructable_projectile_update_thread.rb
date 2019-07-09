module DestructableProjectileUpdateThread

  # def self.create_new window, projectile, args
  #   window  = args[0]
  #   mouse_x = args[1]
  #   mouse_y = args[2]
  #   player  = args[3]
  #   t = Thread.new(projectile, window, mouse_x, mouse_y, player) do |local_projectile, local_window, local_mouse_x, local_mouse_y, local_player|
  #     Thread.exit if !local_projectile.is_alive
  #     results = local_projectile.update(local_mouse_x, local_mouse_y, local_player)

  #     results[:graphical_effects].each do |effect|
  #       local_window.graphical_effects << effect
  #     end

  #     # local_window.projectiles.delete(local_projectile.id) if !local_projectile.is_alive
  #     # puts "PRE COUNT #{local_window.remove_projectile_ids.count}"
  #     # puts results
  #     # puts "PUSHING" if !results[:is_alive]
  #     local_window.remove_projectile_ids.push(local_projectile.id) if !results[:is_alive]
  #     # puts "POST COUNT #{local_window.remove_projectile_ids.count}"
  #     Thread.exit
  #   end
  #   return t
  # end

  def self.update window, projectile, args
    puts "DestructableProjectileUpdateThread - projectile.class: #{projectile.class.name} - #{projectile.id} - #{projectile.is_alive} - #{projectile.health}"
    if projectile.is_alive
      puts "CASE 1"
      results = projectile.update_with_args(args)
      puts "results: #{results}" if !results[:is_alive]
      puts "DElETING FROM THREAD1 #{projectile.id}" if !results[:is_alive]
      window.remove_destructable_projectile_ids.push(projectile.id) if !results[:is_alive]
    end
    if !projectile.is_alive
      puts "DElETING FROM THREAD2 #{projectile.id}  - #{self.health}"
      window.remove_destructable_projectile_ids.push(projectile.id)
    end
    puts "DestructableProjectileUpdateThread - END HERE"
  end
  
end