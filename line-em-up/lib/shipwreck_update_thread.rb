module ShipWreckUpdateThread

  def self.update window, shipwreck, args
    result = shipwreck.update(*args)
    if result[:building]
      building = result[:building]
      building.set_window(window)
      window.add_buildings.push(building)
    end
    window.remove_shipwreck_ids << shipwreck.id  if !result[:is_alive]
  end

end