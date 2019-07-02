module ProjectileUpdateThread

  def create_new window, projectile
    # Thread.new(i) { |j| run(j) }
    return Thread.new(window, projectile) do |local_window, local_projectile|

    end
  end

end