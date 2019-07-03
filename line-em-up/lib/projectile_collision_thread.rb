module ProjectileCollisionThread

  def self.create_new projectile, args
    window  = args[0]
    targets = args[1]
    # Thread.new(i) { |j| run(j) }
    # puts "NEW THREAD"
    t = Thread.new(window, projectile, targets) do |local_window, local_projectile, local_targets|
      # puts "THREAD STARTING HERE - might not see this one."
      results = local_projectile.hit_objects(local_targets, {is_thread: true})

      results[:graphical_effects].each do |effect|
        local_window.graphical_effects << effect
      end

      local_window.remove_projectile_ids.push(local_projectile.id) if !results[:is_alive]
      
      Thread.exit
    end
    # puts "END INIT THREAD"
    return t
  end
end