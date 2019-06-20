require_relative '../lib/config_setting.rb'
require_relative '../models/message_flash.rb'

module QuestInterface

  # Need a dialogue series module?

  # This is where we create new quests
  def self.initial_quests_data
    # ships << AIShip.new(nil, nil, x_value.to_i, y_value.to_i)
    return {
      # Need to keep these strings around. We can eval them, but then can't convert them back to strings.
      "starting-level-quest" => {
        "init_ships_string" =>     ["AIShip.new(nil, nil, 125, 123, {id: 'starting-level-quest-ship-1'})"],
        "init_buildings_string" => [],
        "init_effects" =>   ["focus_on" => {"id" => 'starting-level-quest-ship-1', "time" => 300}], # earth_quakes?, trigger dialogue
        "post_effects" =>   [], # earth_quakes?, trigger dialogue
        "map_name" =>       "desert_v2_small",
        "complete_condition_string" => "
          lambda { |ships, buildings, player|
            found_ship = false
            ships.each do |ship|
              found_ship = true if ship.id == 'starting-level-quest-ship-1'
            end
            return !found_ship
          }
        ",
        # special 'activate_quests' key
        "post_complete_triggers_string" => "
          lambda { |ships, buildings, player|
            return {activate_quests: ['followup-level-quest'], ships: ships, buildings: buildings}
          }
        ",
        # Should not change any ships or buildings in play. Including them in parameters to check IDs
        # Can be nil or can return true
        "active_condition_string" => "
          lambda { |ships, buildings, player|
            return true
          }
        ",
        # Don't have to insert ships here.. this is destroy existing ships (health = 0), boost player health, etc..
        "post_active_triggers_string" => "
          lambda { |ships, buildings, player|
            return {ships: ships, buildings: buildings}
          }
        ",
        "state" => 'inactive' #[inactive, active, complete]

      },
      "followup-level-quest" => {
        "init_ships_string" =>     ["AIShip.new(nil, nil, 125, 125, {id: 'starting-level-quest-ship-2'})", "AIShip.new(nil, nil, 124, 124, {id: 'starting-level-quest-ship-3'})", "AIShip.new(nil, nil, 122, 122, {id: 'starting-level-quest-ship-4'})"],
        "init_buildings_string" => [],
        "init_effects" =>   [], # earth_quakes?, trigger dialogue
        "post_effects" =>   [], # earth_quakes?, trigger dialogue
        "map_name" =>       "desert_v2_small",
        "complete_condition_string" => "
          lambda { |ships, buildings, player|
            found_ship = false
            ships.each do |ship|
              found_ship = true if ['starting-level-quest-ship-2', 'starting-level-quest-ship-3', 'starting-level-quest-ship-4'].include?(ship.id)
            end
            return !found_ship
          }
        ",
        "post_complete_triggers_string" => nil,
        "active_condition_string" => nil, # is triggered to active by another quest
        "post_active_triggers_string" => "
          lambda { |ships, buildings, player|
            return {ships: ships, buildings: buildings}
          }
        ",
        "state" => 'inactive'

      }
    }
  end

  QUEST_KEYS_TO_EVAL = {
      "complete_condition_string" =>        {"new_key" => "complete_condition"     },
      "post_complete_triggers_string" =>    {"new_key" => "post_complete_triggers" },
      "active_condition_string" =>          {"new_key" => "active_condition"       },
      "post_active_triggers_string" =>      {"new_key" => "post_active_triggers"   },
      "init_ships_string" =>                {"new_key" => "init_ships",            "type" => 'array'},
      "init_buildings_string" =>            {"new_key" => "init_buildings",        "type" => 'array'}
  }

    # eval(values[string_key.to_s]) if values[string_key.to_s]

# string_key.to_s: init_ships_string
# HEREL [:init_ships_string, :init_buildings_string, :init_effects, :post_effects, :map_name, :complete_condition_string, :post_complete_triggers_string, :active_condition_string, :post_active_triggers_string, :state]

  def self.get_quests_data config_path
    quests_json_data = ConfigSetting.get_setting(config_path, 'Quests', nil)
    if quests_json_data.nil?
      quests_json_data = initial_quests_data.to_json
      # ConfigSetting.set_setting(config_path, 'Quests', quests_json_data.gsub(/\s+/, ''))
      ConfigSetting.set_setting(config_path, 'Quests', quests_json_data)
    end
    return quests_json_data
  end


  def self.validate_inital_lambdas
    found_errors = true
    initial_quests_data.each do |quest_key, quest_data|
      QUEST_KEYS_TO_EVAL.each do |string_key, values|
        begin
          if values['type'] == 'array'
            quest_data[values["new_key"]] = []
            quest_data[string_key].each do |element|
              quest_data[values["new_key"]] << eval(element)
            end
          else
            quest_data[values["new_key"]] = eval(quest_data[string_key]) if quest_data[string_key]
          end
        rescue SyntaxError, NoMethodError => e
          found_errors = false
          puts "ISSUE WITH: #{quest_key} on key: #{string_key} - #{e.class}"
        end
      end
    end
    return found_errors
  end


  def self.get_quests config_path
    # puts "GET HERE"
    found_errors = false
    raw_data = get_quests_data(config_path)
    # puts raw_data.inspect
    quest_datas = JSON.parse(raw_data)
    quest_datas.each do |quest_key, quest_data|
      QUEST_KEYS_TO_EVAL.each do |string_key, values|
        begin
          if values["type"] == 'array'
            quest_data[values["new_key"]] = []
            quest_data[string_key].each do |element|
              quest_data[values["new_key"]] << eval(element)
            end
          else
            quest_data[values["new_key"]] = eval(quest_data[string_key]) if quest_data[string_key]
          end
        rescue SyntaxError, NoMethodError => e
          found_errors = true
          puts e.backtrace
          puts "ISSUE WITH: #{quest_key} on key: #{string_key}"
          puts "RAW DATA: #{quest_data[string_key]}"
          puts "ISSUE WITH: #{quest_key} on key: #{string_key} - #{e.class}"
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
  def self.init_quests config_path, quest_datas, map_name, ships, buildings, player, messages
    local_messages = []
    quest_datas.each do |quest_key, values|
      # puts "INIT QUEST HEY : #{quest_key} and values"
      # puts values.inspect
      state = values["state"]
      next if values["map_name"] != map_name
      if state == 'active'
        local_messages << "#{quest_key}"
        if values["init_ships"] && values["init_ships"].any?
          values["init_ships"].each do |ship|
            puts "1loading in ship here for : #{quest_key}"
            ships << ship
          end
        end
        # Load in buildings
      end
    end
    messages << MessageFlash.new("Active Quests in This Area") if local_messages.any?
    local_messages.each do |message|
      messages << MessageFlash.new(message)
    end

    return [quest_datas, ships, buildings, messages]
  end

  def self.update_quests config_path, quest_datas, map_name, ships, buildings, player, messages
    updated_quest_keys = {}
    quest_datas.each do |quest_key, values|
      state = values["state"]
      next if values["map_name"] != map_name
      next if state == 'complete'
      if state == 'active' && values["complete_condition"] && values["complete_condition"].call(ships, buildings, player)
        updated_quest_keys[quest_key] = 'complete'
        values["state"] = 'complete'
        # Trigger state changes
        if values["post_complete_triggers"]
          # LAMBDA returns hash w/ symbols
          results = values["post_complete_triggers"].call(ships, buildings, player)
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
      elsif state == 'pending_activation' || state == 'inactive' && values["active_condition"] && values["active_condition"].call(ships, buildings, player)
        # In this special case, run init functions, as if the map were just loaded
        if values["init_ships"] && values["init_ships"].any?
          values["init_ships"].each do |ship|
            ships << ship
          end
        end
          # Load in buildings
        updated_quest_keys[quest_key] = 'active'
        values["state"] = 'active'
        # Trigger state changes
        if values["post_active_triggers"]
          # LAMBDA returns hash w/ symbols
          results = values["post_active_triggers"].call(ships, buildings, player)
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
      messages << MessageFlash.new("#{quest_key} is now #{state}!")
      ConfigSetting.set_mapped_setting(config_path, ['Quests', quest_key.to_s, 'state'], state)
    end
    # return {quest_datas: quest_datas, ships: ships, buildings: buildings}
    return [quest_datas, ships, buildings, messages]
  end

end















