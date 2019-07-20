module ProjectileCollisionThread

  def self.update window, projectile, args
    air_targets    = args[0]
    ground_targets = args[1]
    results = projectile.hit_objects(air_targets, ground_targets, {is_thread: true})

    results[:graphical_effects].each do |effect|
      window.add_graphical_effects << effect
    end

    # window.remove_projectile_ids.push(projectile.id) if !results[:is_alive]
  end
end