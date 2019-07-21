module BuildingUpdateThread

  def self.update window, building, args
    result = building.update(*args)

    if result[:add_ships]
      result[:add_ships].each do |ship|
        window.add_ships << ship
      end
    end
    if result[:projectiles]
      result[:projectiles].each do |p|
        window.add_projectiles << p
      end
    end
    window.remove_building_ids << building.id if !result[:is_alive]
  end

end