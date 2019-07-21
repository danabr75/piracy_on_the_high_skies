module ShipWreckUpdateThread

  def self.update window, shipwreck, args
    result = shipwreck.update(*args)
    window.add_buildings.push(result[:building]) if result[:building]
    window.remove_shipwreck_ids << shipwreck.id  if !result[:is_alive]
  end

end