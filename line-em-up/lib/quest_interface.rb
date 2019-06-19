require_relative '../lib/config_setting.rb'

module QuestInterface

  # Need a dialogue series module?

  # This is where we create new quests
  def self.initial_quests_data
    # ships << AIShip.new(nil, nil, x_value.to_i, y_value.to_i)
    return {
      # Need to keep these strings around. We can eval them, but then can't convert them back to strings.
      "starting-level-quest": {
        init_ships:     ["AIShip.new(nil, nil, 123, 123, {id: 'starting-level-quest-ship-1'})"],
        init_buildings: [],
        init_effects:   [], # earth_quakes?, trigger dialogue
        post_effects:   [], # earth_quakes?, trigger dialogue
        complete_condition_string: "
          lambda { |map_name, ships, buildings, player|
            found_ship = false
            if map_name == 'desert_v2_small'
              ships.each do |ship|
                found_ship = true if ship.id == 'starting-level-quest-ship-1'
              end
            end
            return !found_ship
          }
        ",
        # special 'activate_quests' key
        post_complete_triggers_string: "
          lambda { |map_name, ships, buildings, player|
            return {activate_quests: ['followup-level-quest'], ships: ships, buildings: buildings}
          }
        ",
        # Should not change any ships or buildings in play. Including them in parameters to check IDs
        active_condition_string: "
          lambda { |map_name, ships, buildings, player|
            return map_name == 'desert_v2_small'
          }
        ",
        # Don't have to insert ships here.. this is destroy existing ships (health = 0), boost player health, etc..
        post_active_triggers_string: "
          lambda { |map_name, ships, buildings, player|
            return {ships: ships, buildings: buildings}
          }
        ",
        state: 'inactive' #[inactive, active, complete]

      },
      "followup-level-quest": {
        init_ships:     ["AIShip.new(nil, nil, 125, 125, {id: 'starting-level-quest-ship-2'})"],
        init_buildings: [],
        init_effects:   [], # earth_quakes?, trigger dialogue
        post_effects:   [], # earth_quakes?, trigger dialogue
        complete_condition_string: "
          lambda { |map_name, ships, buildings, player|
            found_ship = false
            if map_name == 'desert_v2_small'
              ships.each do |ship|
                found_ship = true if ship.id == 'starting-level-quest-ship-2'
              end
            end
            return !found_ship
          }
        ",
        post_complete_triggers_string: nil,
        active_condition_string: nil, # is triggered to active by another quest
        post_active_triggers_string: "
          lambda { |map_name, ships, buildings, player|
            return {ships: ships, buildings: buildings}
          }
        ",
        state: 'inactive'

      }
    }
  end

  def self.validate_inital_lambdas
    quest_keys_to_eval = {
      complete_condition_string: :complete_condition, post_complete_triggers_string: :post_complete_triggers,
      active_condition_string: :active_condition, post_active_triggers_string: :post_active_triggers
    }
    initial_quests_data.each do |quest_key, values|
      quest_keys_to_eval.each do |string_key, evaled_key|
        begin
          eval(values[string_key.to_s]) if values[string_key.to_s]
        rescue SyntaxError => e
          puts "ISSUE WITH: #{quest_key} on key: #{string_key}"
        end
      end
    end
    return true
  end

  def self.get_quests_data config_path
    quests_json_data = ConfigSetting.get_setting(config_path, 'Quests', nil)
    if quests_json_data.nil?
      quests_json_data = initial_quests_data.to_json
      # ConfigSetting.set_setting(config_path, 'Quests', quests_json_data.gsub(/\s+/, ''))
      ConfigSetting.set_setting(config_path, 'Quests', quests_json_data)
    end
    return quests_json_data
  end

  def self.get_quests config_path
    # puts "GET HERE"
    found_errors = false
    raw_data = get_quests_data(config_path)
    # puts raw_data.inspect
    quest_datas = JSON.parse(raw_data)
    # puts "PARSED DATA HERE"
    # puts quest_datas.inspect
    quest_keys_to_eval = {
      complete_condition_string: :complete_condition, post_complete_triggers_string: :post_complete_triggers,
      active_condition_string: :active_condition, post_active_triggers_string: :post_active_triggers
    }
    # quest_datas = quest_datas
    quest_datas.each do |quest_key, values|
      quest_keys_to_eval.each do |string_key, evaled_key|
        # puts "ABOUT TO EVAL - #{string_key}"
        # puts values[string_key.to_s].inspect
        begin
          values[evaled_key.to_s] = eval(values[string_key.to_s]) if values[string_key.to_s]
        rescue SyntaxError => e
          found_errors = true
          puts e.backtrace
          puts "ISSUE WITH: #{quest_key} on key: #{string_key}"
          puts "RAW DATA: #{values[string_key.to_s]}"
        end
      end
    end
    # puts "RETURNING: #{quest_datas}"
    raise "Finishing w/ errors" if found_errors
    return quest_datas
  end

  # run once on map loads, inject ships into map
  # Will run init_ships and init_buildings for each active quest
  # this is necessary for on-map-load inits..
  # What if a player enters an area, the updates creates a ship, the player leaves. Need to have on-load inits.
  def self.init_quests config_path, quest_datas, map_name, ships, buildings, player
    quest_datas.each do |quest_key, values|
      state = values["state"]
      if state == 'active'
        if values["init_ships"] && values["init_ships"].any?
          values["init_ships"].each do |ship_string|
            puts "1loading in ship here for : #{quest_key}"
            ships << eval(ship_string)
          end
        end
        # Load in buildings
      end
    end
    return [quest_datas, ships, buildings]
  end

  def self.update_quests config_path, quest_datas, map_name, ships, buildings, player
    updated_quest_keys = {}
    quest_datas.each do |quest_key, values|
      state = values["state"]
      next if state == 'complete'
      if state == 'active' && values["complete_condition"] && values["complete_condition"].call(map_name, ships, buildings, player)
        updated_quest_keys[quest_key] = 'complete'
        values["state"] = 'complete'
        # Trigger state changes
        if values["post_complete_triggers"]
          # LAMBDA returns hash w/ symbols
          results = values["post_complete_triggers"].call(map_name, ships, buildings, player)
          puts "IS RESULTS KEYS STRINGS OR SYMBOLS?2"
          puts results
          ships     = results[:ships]
          buildings = results[:buildings]
          if results[:activate_quests]
            results[:activate_quests].each do |triggering_quest_key|
              puts "WHY CAN:T TRIGGER NEW STATUS?? #{triggering_quest_key} - #{triggering_quest_key.class}"
              puts "IS IT HERE? #{quest_datas[triggering_quest_key]} - and logic? : #{quest_datas[triggering_quest_key]['state'] == 'inactive'}"
              quest_datas[triggering_quest_key]['state'] = 'pending_activation' if quest_datas[triggering_quest_key]['state'] == 'inactive'
              puts "WAS IT SET? #{quest_datas[triggering_quest_key]['state']}"
            end
          end

        end
      elsif state == 'pending_activation' || state == 'inactive' && values["active_condition"] && values["active_condition"].call(map_name, ships, buildings, player)
        # In this special case, run init functions, as if the map were just loaded
        # if state == 'pending_activation'
          if values["init_ships"] && values["init_ships"].any?
            values["init_ships"].each do |ship_string|
              puts "2loading in ship here for : #{quest_key}"
              ships << eval(ship_string)
            end
          end
          # Load in buildings
        # end
        updated_quest_keys[quest_key] = 'active'
        values["state"] = 'active'
        # Trigger state changes
        if values["post_active_triggers"]
          # LAMBDA returns hash w/ symbols
          results = values["post_active_triggers"].call(map_name, ships, buildings, player)
          puts "IS RESULTS KEYS STRINGS OR SYMBOLS?"
          puts results
          ships     = results[:ships]
          buildings = results[:buildings]
          if results[:activate_quests]
            results[:activate_quests].each do |triggering_quest_key|
              quest_datas[triggering_quest_key]['state'] = 'pending_activation' if quest_datas[triggering_quest_key]['state'] == 'inactive'
            end
          end
          # {activate_quests: ['followup-level-quest'], ships: ships, buildings: buildings}
        end
      end
      # return {quest_datas: quest_datas, ships: ships, buildings: buildings}
    end

    # Only if stage change
    # ConfigSetting.set_mapped_setting(config_path, ['Inventory', '2'.to_s, '2'.to_s], 'BulletLauncher')
    updated_quest_keys.each do |quest_key, state|
      puts "SETTING KEY HERE!!"
      puts "updtating quest keys: #{quest_key} - #{state} - what is class: #{quest_key.class}"
      ConfigSetting.set_mapped_setting(config_path, ['Quests', quest_key.to_s, 'state'], state)
    end
    # return {quest_datas: quest_datas, ships: ships, buildings: buildings}
    return [quest_datas, ships, buildings]
  end

end















