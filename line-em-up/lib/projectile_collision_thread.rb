module ProjectileCollisionThread

  def self.update window, projectile, args
    targets = args[0]
    results = projectile.hit_objects(targets, {is_thread: true})

    results[:graphical_effects].each do |effect|
      window.add_graphical_effects << effect
    end

    # window.remove_projectile_ids.push(projectile.id) if !results[:is_alive]
  end
end