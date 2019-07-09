module ProjectileCollisionThread

  def self.update window, projectile, args
    targets = args[0]
    projectile.hit_objects(targets, {is_thread: true})
    # window.remove_projectile_ids.push(projectile.id) if !results[:is_alive]
  end
end