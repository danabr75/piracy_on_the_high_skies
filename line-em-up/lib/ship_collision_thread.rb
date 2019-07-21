module ShipCollisionThread

  def self.update window, ship, args
    # Thread.exit if !ship.inited
    # targets = args[0]
    # puts "THREAD STARTING HERE - might not see this one."
    ship.hit_objects(*args)
    # puts "COLLISION RESULTS: RESULT"
    # puts results.inspect
    # {:is_alive=>true, :drops=>[], :point_value=>0, :killed=>0, :graphical_effects=>[]}
    # raise "STOP"

    # results[:graphical_effects].each do |effect|
    #   local_window.graphical_effects << effect
    # end

    # window.remove_destructable_projectile_ids.push(projectile.id) if !results[:is_alive]
  end
end