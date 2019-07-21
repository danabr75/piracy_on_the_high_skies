module DestructableProjectileCollisionThread

  def self.update window, projectile, args
    # Thread.exit if !projectile.inited
    # air_targets    = args[0]
    # ground_targets = args[1]

    # puts "THREAD STARTING HERE - might not see this one."
    results = projectile.hit_objects(*args)
    # puts "COLLISION RESULTS: RESULT"
    # puts results.inspect
    # {:is_alive=>true, :drops=>[], :point_value=>0, :killed=>0, :graphical_effects=>[]}
    # raise "STOP"

    results[:graphical_effects].each do |effect|
      window.add_graphical_effects << effect
    end

    # window.remove_destructable_projectile_ids.push(projectile.id) if !results[:is_alive]
  end
end