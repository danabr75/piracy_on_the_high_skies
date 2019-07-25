module ShipWreckUpdateThread

  def self.update window, shipwreck, args
    result = shipwreck.update(*args)
    if result[:building]
      window.add_buildings.push(result[:building])
    end
    if !result[:is_alive]
      window.remove_shipwreck_ids << shipwreck.id
    end
  end

end