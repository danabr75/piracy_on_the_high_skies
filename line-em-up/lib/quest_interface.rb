require_relative '../lib/config_setting.rb'
require_relative '../models/message_flash.rb'

Dir["../models/effects/*.rb"].each { |f| require f }

module QuestInterface

  # This is where we create new quests
  def self.initial_quests_data
    # ships << AIShip.new(nil, nil, x_value.to_i, y_value.to_i)
    return {
      # Need to keep these strings around. We can eval them, but then can't convert them back to strings.
      "starting_level_quest" => {
        "init_ships_string" => [
            "AIShip.new(nil, nil, 124, 124, {id: 'starting_level_quest_ship_1', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 130, 135, {id: 'starting_level_quest_ship_7', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 130, 140, {id: 'starting_level_quest_ship_8', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 130, 110, {id: 'starting_level_quest_ship_9', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 125, 125, {id: 'starting_level_quest_ship_2', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 30, 100, {id: 'starting_level_quest_ship_3', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 0, 0, {id: 'starting_level_quest_ship_4', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 250, 0, {id: 'starting_level_quest_ship_5', special_target_focus_id: 'player'})",
            "AIShip.new(nil, nil, 0, 250, {id: 'starting_level_quest_ship_6', special_target_focus_id: 'player'})"
          ],
        "init_buildings_string" => [],
        "init_effects" =>   [
          [
            # {effect_type: "focus",    "id" => 'starting_level_quest_ship_1', "time" => 5, target_type: 'ship'},
            # {effect_type: "dialogue", "section_id" => 'level_1'},
            # {effect_type: "focus",    "id" => 'player', "time" => 0, target_type: 'player'},
          ]
        ],
        # KEEP THE ABOVE LINE. 
        # "init_effects" =>   [], # earth_quakes?, trigger dialogue
        "post_effects" =>   [
          [
            # {effect_type: "wait", "time" => 30},
            # {effect_type: "dialogue", "section_id" => 'level_2'}
          ]
        ], # earth_quakes?, trigger dialogue
        "map_name" =>       "desert_v9_small",
        "complete_condition_string" => "
          lambda { |ships, buildings, player|
            found_ship = false
            ships.each do |key, ship|
              found_ship = true if ship.id == 'starting_level_quest_ship_1'
            end
            return !found_ship
          }
        ",
        # special 'activate_quests' key
        # "post_complete_triggers_string" => "
        #   lambda { |ships, buildings, player|
        #     return {activate_quests: ['followup-level-quest'], ships: ships, buildings: buildings}
        #   }
        # ",
        "post_complete_triggers_string" => nil,
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
        "init_ships_string" =>     ["AIShip.new(nil, nil, 118, 118, {id: 'starting_level_quest-ship-2', special_target_focus_id: 'player'})", "AIShip.new(nil, nil, 118, 119, {id: 'starting_level_quest-ship-3', special_target_focus_id: 'player'})", "AIShip.new(nil, nil, 118, 120, {id: 'starting_level_quest-ship-4', special_target_focus_id: 'player'})"],
        "init_buildings_string" => [],
        "init_effects" =>   [], # earth_quakes?, trigger dialogue
        # "init_effects" =>   [["focus" => {"id" => 'starting_level_quest-ship-2', "time" => 100, type: 'ship'}]], # earth_quakes?, trigger dialogue
        "post_effects" =>   [], # earth_quakes?, trigger dialogue
        "map_name" =>       "desert_v9_small",
        "complete_condition_string" => "
          lambda { |ships, buildings, player|
            found_ship = false
            ships.each do |key, ship|
              found_ship = true if ['starting_level_quest-ship-2', 'starting_level_quest-ship-3', 'starting_level_quest-ship-4'].include?(key)
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
         # puts "ISSUE WITH: #{quest_key} on key: #{string_key} - #{e.class}"
        end
      end
    end
    return found_errors
  end


  def self.get_quests config_path
    found_errors = false
    raw_data = get_quests_data(config_path)
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
        rescue NameError, SyntaxError, NoMethodError => e
          found_errors = true
         # puts e.backtrace
         # puts "ISSUE WITH: #{quest_key} on key: #{string_key}"
         # puts "RAW DATA: #{quest_data[string_key]}"
         # puts "ISSUE WITH: #{quest_key} on key: #{string_key} - #{e.class}"
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
  def self.init_quests_on_map_load config_path, quest_datas, map_name, ships, buildings, player, messages, effects, window, options
   # puts "INITING QUESTS HERE"
    local_messages = []
    quest_datas.each do |quest_key, values|
     # puts "INIT QUEST HEY : #{quest_key} and values"
      # puts values.inspect
      state = values["state"]
     # puts "MAYP NAME: #{map_name} and state: #{state}"
      next if values["map_name"] != map_name
      if state == 'active'
        local_messages << "#{quest_key}"
        if values["init_ships"] && values["init_ships"].any?
          values["init_ships"].each do |ship|
           # puts "1loading in ship here for : #{quest_key}"
            ships[ship.id] = ship
          end
        end
       # puts "INIT HERE, WHY NOT INIT"
        if values["init_effects"] && values["init_effects"].any?
         # puts "INIT EFFECTS FOUND - on map load"
         # puts values["init_effects"]
          ships, buildings, messages, effects = initialize_effects(config_path, quest_key, values["init_effects"], map_name, ships, buildings, player, messages, effects, options)
        end
        # Load in buildings
      end
    end
    messages << MessageFlash.new("Active Quests in This Area") if local_messages.any?
    local_messages.each do |message|
      messages << MessageFlash.new(message)
    end

    return [quest_datas, ships, buildings, messages, effects]
  end

  def self.update_quests config_path, quest_datas, map_name, ships, buildings, player, messages, effects, window, options = {}
    updated_quest_keys = {}
    quest_datas.each do |quest_key, values|
      state = values["state"]
      next if values["map_name"] != map_name
      next if state == 'complete'
      # puts 'values["complete_condition"]'
      # puts values["complete_condition"].inspect
      if state == 'active' && values["complete_condition"] && values["complete_condition"].call(ships, buildings, player)
        updated_quest_keys[quest_key] = 'complete'
        values["state"] = 'complete'
        # Trigger state changes
        if values["post_complete_triggers"]
          # LAMBDA returns hash w/ symbols
          results = values["post_complete_triggers"].call(ships, buildings, player)
          # puts "IS RESULTS KEYS STRINGS OR SYMBOLS?2"
          # puts results
          ships     = results[:ships]
          buildings = results[:buildings]
          if results[:activate_quests]
            results[:activate_quests].each do |triggering_quest_key|
             # puts "WHY CAN:T TRIGGER NEW STATUS?? #{triggering_quest_key} - #{triggering_quest_key.class}"
             # puts "IS IT HERE? #{quest_datas[triggering_quest_key]} - and logic? : #{quest_datas[triggering_quest_key]['state'] == 'inactive'}"
              quest_datas[triggering_quest_key]['state'] = 'pending_activation' if quest_datas[triggering_quest_key]['state'] == 'inactive'
             # puts "WAS IT SET? #{quest_datas[triggering_quest_key]['state']}"
            end
          end

        end

        ships, buildings, messages, effects = initialize_effects(config_path, quest_key, values["post_effects"], map_name, ships, buildings, player, messages, effects, options)

      elsif state == 'pending_activation' || state == 'inactive' && values["active_condition"] && values["active_condition"].call(ships, buildings, player)
        # In this special case, run init functions, as if the map were just loaded
        if values["init_ships"] && values["init_ships"].any?
          values["init_ships"].each do |ship|
            ships[ship.id] = ship
          end
        end
          # Load in buildings
        updated_quest_keys[quest_key] = 'active'
        values["state"] = 'active'
        # Trigger state changes
        if values["post_active_triggers"]
          # LAMBDA returns hash w/ symbols
          results = values["post_active_triggers"].call(ships, buildings, player)
          # puts "IS RESULTS KEYS STRINGS OR SYMBOLS?"
          # puts results
          ships     = results[:ships]
          buildings = results[:buildings]
          if results[:activate_quests]
            results[:activate_quests].each do |triggering_quest_key|
              quest_datas[triggering_quest_key]['state'] = 'pending_activation' if quest_datas[triggering_quest_key]['state'] == 'inactive'
            end
          end
          # {activate_quests: ['followup-level-quest'], ships: ships, buildings: buildings}
        end
       # puts "WHAT WAS INIT FFECTS? "
       # puts values["init_effects"].class
       # puts values["init_effects"]
        ships, buildings, messages, effects = initialize_effects(config_path, quest_key, values["init_effects"], map_name, ships, buildings, player, messages, effects, options)


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
    return [quest_datas, ships, buildings, messages, effects]
  end


  def self.initialize_effects config_path, quest_key, effects_datas, map_name, ships, buildings, player, messages, effects, options
   # puts "CASE 0"
   # puts "effects_datas"
    raise "BAD INPUT HERE, effects_datas not an array" if !effects_datas.is_a?(Array)
   # puts effects_datas
    effects_datas.each do |effect_groups|
     # puts "CASE 1"
     # puts "EFFECT DATAS:"
     # puts effect_groups.inspect
      raise "BAD INPUT HERE, effect_groups not an array" if !effect_groups.is_a?(Array)
      # [
      #   {"effect_type"=>"focus", "id"=>"starting_level_quest_ship_1", "time"=>300, "target_type"=>"ship"},
      #   {"effect_type"=>"focus", "id"=>"player", "time"=>0, "target_type"=>"player"}
      # ]
      group = Effects::Group.new(options)
      effect_groups.each do |effect_group|
       # puts effect_group.inspect if !effect_group.is_a?(Hash) 
        # HERE!!!!!!
        # {"effect_type"=>"focus", "id"=>"starting_level_quest_ship_1", "time"=>300, "target_type"=>"ship"}
        raise "BAD INPUT HERE, effect_group not an array. Found: #{effect_group.class}" if !effect_group.is_a?(Hash) 
        # HERE!!!!!!
       # puts "CASE 2"
        # effect_group.each do |key, effect_data|
        # effect_group.each do |effect_data|
        #  # puts effect_data.inspect if !effect_data.is_a?(Hash)
        #   raise "BAD INPUT HERE, effect_data not an hash. Found: #{effect_data.class}" if !effect_data.is_a?(Hash)
        effect = nil
        key = effect_group['effect_type']
       # puts "CASE 3"
        # puts "KEY HERE: #{key}"
        # puts effect_data.inspect
        # raise "what is it"
        effect_options = effect_group['options'] || {}
        # puts "WHAT WAS THIS: #{effect_group['options']}"
        # puts effect_group['options'].inspect
        if key == "focus"
         # puts "CASE 4"
          # {"id"=>"starting_level_quest_ship_1", "time"=>300}
          # puts "PASSING SHIPS:L #{ships}"
          # puts "#{ships.first}"
          raise "Invalid settings for Focus: #{[effect_group['id'], effect_group['target_type'], effect_group['time']]}" if [effect_group['id'], effect_group['target_type'], effect_group['time']].include?(nil)
          effect = Effects::Focus.new(effect_group['id'], effect_group['target_type'], effect_group['time'], ships, buildings, player, options.merge(effect_options))
        elsif key == 'dialogue'
         # puts "CASE 5"
          # def initialize quest_key, section_key, options = {}
          raise "Invalid settings for Dialogue: #{[effect_group['section_id']]}" if [effect_group['section_id']].include?(nil)
          effect = Effects::Dialogue.new(quest_key, effect_group['section_id'], player, options.merge(effect_options))
        elsif key == 'wait'
          raise "Invalid settings for Wait: #{[effect_group['time']]}" if [effect_group['time']].include?(nil)
          effect = Effects::Wait.new(effect_group['time'], options.merge(effect_options))
        end
        raise "Found case that effect did not match known key. Key Found: #{key}" if effect.nil?
        group.effects << effect if effect
      end
      effects << group
    end
    return [ships, buildings, messages, effects]
  end


end















