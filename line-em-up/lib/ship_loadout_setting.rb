# require 'luit' # overridding

# require_relative '../../vendors/lib/luit'
# require "#{vendor_directory}/lib/luit.rb"


require_relative 'setting.rb'
# require_relative '../models/basic_ship.rb'
# require_relative '../models/launcher.rb'
require_relative '../models/ship_inventory.rb'
require_relative '../models/object_inventory.rb'

require_relative "global_constants.rb"
require_relative "global_variables.rb"

require 'gosu'
# require "#{MODEL_DIRECTORY}/basic_ship.rb"
# require_relative "config_settings.rb"

# THIS IS THE MAIN INVENTORY CONTROLLER, controls the player inventory, hardpoint inventory, and any other container that opens up on the screen.
class ShipLoadoutSetting < Setting
  include GlobalVariables
  include GlobalConstants
  # MEDIA_DIRECTORY
  # SELECTION = ::Launcher.descendants
  NAME = "ship_loadout"
  IMAGE_SCALER = 7.0

  # def self.get_weapon_options
  #   ::Launcher.descendants
  # end

  # attr_accessor :x, :y, :font, :max_width, :max_height, :selection, :value, :ship_value
  attr_accessor :value, :ship_value
  attr_accessor :mouse_x, :mouse_y
  attr_reader :active
  attr_accessor :refresh_player_ship

  HARDPOINT_DIR = MEDIA_DIRECTORY + "/hardpoints"
  INVALID_HARDPOINT_IMAGE = HARDPOINT_DIR + "/invalid_hardpoint.png"

  # attr_accessor :cursor_object

  def initialize window, max_width, max_height, current_height, width_scale, height_scale, options = {}
    @width_scale  = width_scale
    @height_scale = height_scale
    @average_scale = (@width_scale + @height_scale) / 2.0

    @refresh_player_ship = false
    # @z = ZOrder::HardPointClickableLocation
    # LUIT.config({window: window})
    # @window = window # Want relative to self, not window. Can't do that from settting, not a window.
    @mouse_x, @mouse_y = [0,0]
    @window = window # ignoring outer window here? Want actions relative to this window.
    # @local_window = local_window
    @scale = options[:scale] || 1
    # puts "SHIP LOADOUT SETTING SCALE: #{@scale}"
    @font = Gosu::Font.new(20)
    # @x = width
    @y = current_height
    @max_width = max_width
    @max_height = max_height
    # @next_x = 5 * @scale
    @prev_x = @max_width - 5 * @scale - @font.text_width('>')
    # @selection = []

    @ship_inventory = ShipInventory.new(window)
    # @launchers = ::Launcher.descendants.collect{|d| d.name}
    # @meta_launchers = {}
    # @filler_items = []
    # @launchers.each_with_index do |klass_name, index|
    #   klass = eval(klass_name)
    #   image = klass.get_hardpoint_image
    #   button_key = "clicked_launcher_#{index}".to_sym
    #   @meta_launchers[button_key] = {follow_cursor: false, klass: klass, image: image}
    #   @filler_items << {follow_cursor: false, klass: klass, image: image}
    #   @button_id_mapping[button_key] = lambda { |setting, id| setting.click_inventory(id) }
    # end
    @hardpoint_image_z = 50
    # puts "SELECTION: #{@selection}"
    # puts "INNITING #{config_file_path}"
    @config_file_path = CONFIG_FILE
    @save_file_path   = CURRENT_SAVE_FILE
    # @name = self.class::NAME
    # @ship_value = ship_value
    # implement hide_hardpoints on pilotable ship class

    # Used to come from loadout window
    @ship_index = (ConfigSetting.get_setting(@save_file_path, "current_ship_index")).to_s
    @flagship_index = @ship_index
    @current_fleet_index = "fleet_index_#{@ship_index}"
    puts "FLEET INDEX: #{@current_fleet_index}"
    raise "missing ship index" if @ship_index.nil? || @ship_index == ''
    @ship_value = ConfigSetting.get_mapped_setting(@save_file_path, ["player_fleet", @ship_index, "klass"])
    raise "missing ship value at #{@ship_index} - #{@ship_index.class}. GOT: #{@ship_value.inspect}" if @ship_value.nil? || @ship_value == ''
    begin
      klass = eval(@ship_value)
    rescue Exception => e
      puts "Caught Error in Eval: #{e.class} when trying to access 'ship' "
      puts e.message
      puts e.backtrace.join("\n")
      puts "EVAL DATA:"
      puts @ship_value
    end

    hardpoint_data = PilotableShips::PilotableShip.get_hardpoint_data
    @ship = klass.new(@max_width / 2, @max_height / 2, ZOrder::Player, ZOrder::Hardpoint, ZOrder::HardpointBase, 0, "INVENTORY_WINDOW", {always_show: true, use_large_image: true, hide_hardpoints: true, block_initial_angle: true}.merge(hardpoint_data))

    # puts "SHIP HERE: #{@ship.x} - #{@ship.y}"

    # puts "RIGHT HERE!@!!!"
    # puts "@ship.starboard_hard_points"
    # puts @ship.starboard_hard_points
    # @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
    # @window = window
    # first array is rows at the top, 2nd goes down through the rows
    # @inventory_matrix = []
    # @inventory_matrix_max_width = 4
    # @inventory_matrix_max_height = 7
    @cell_width  = 25 * @height_scale
    @cell_height = 25 * @height_scale
    @cell_width_padding = 5 * @height_scale
    @cell_height_padding = 5 * @height_scale
    @button_id_mapping = self.class.get_id_button_mapping

    # @inventory_height = nil
    # @inventory_width  = nil
    # init_matrix
    # puts "FILLER ITEMS: #{@filler_items}"
    # @inventory_items = retrieve_inventory_items
    # fill_matrix(@filler_items)
    # @window.cursor_object = nil
    @hardpoints_height = nil
    @hardpoints_width  = nil
    # @button = LUIT::Button.new(@window, :test, 450, 450, "test", 30, 30)
    @button = LUIT::Button.new(@window, @window, :back, max_width / 2, 30 * @height_scale, ZOrder::UI, "Return to Game", 15 * @height_scale, 15 * @height_scale)
    @font_height  = (12 * @height_scale).to_i
    @font_padding = (4 * @height_scale).to_i
    @font = Gosu::Font.new(@font_height)
    @hover_object = nil

    @object_inventory = nil
    @object_inventory_holding_type = :none
    @buy_rate_from_store  = 1.0
    @sell_rate_from_store = 1.0
    @ship_hardpoints = init_hardpoints_clickable_areas(@ship)
    @active = false

    @invalid_hardpoint_image = Gosu::Image.new(INVALID_HARDPOINT_IMAGE)

    @message_stub = "*" * 40
    @ship_steam_core_capacity = 0
    @ship_steam_core_usage    = 0
    @steam_core_capacity_text = "  Steam Core Capacity: "
    @steam_core_usage_text    = "  Steam Core Usage: "
    @steam_core_capacity_button = LUIT::Button.new(@window, @window, nil, max_width / 1.5, 50 * @height_scale, ZOrder::UI, @message_stub, 15 * @height_scale, 15 * @height_scale)
    @steam_core_usage_button    = LUIT::Button.new(@window, @window, nil, max_width / 1.5, 50 * @height_scale + @steam_core_capacity_button.h, ZOrder::UI, @message_stub, 15 * @height_scale, 15 * @height_scale)

    font_color = 0xff_000000
    button_height = 5 * @height_scale
    button_width  = 5 * @height_scale # max_width  - 50
    @legend_1 = LUIT::Button.new(@window, @window, nil, button_width, button_height, ZOrder::UI, "Hardpoint Legend", 15 * @height_scale, 15 * @height_scale)
    button_height += @legend_1.h
    color, hover_color = Hardpoint.get_hardpoint_colors(:offensive)
    # puts "HOVER COLOR: #{[color, hover_color]}"
    @legend_2    = LUIT::Button.new(@window, @window, nil, button_width, button_height, ZOrder::UI, "Red: Offensive", 15 * @height_scale, 15 * @height_scale, color, hover_color, font_color)
    button_height += @legend_2.h
    color, hover_color = Hardpoint.get_hardpoint_colors(:engine)
    @legend_3    = LUIT::Button.new(@window, @window, nil, button_width, button_height, ZOrder::UI, "Blue: Engine", 15 * @height_scale, 15 * @height_scale, color, hover_color, font_color)
    button_height += @legend_3.h
    color, hover_color = Hardpoint.get_hardpoint_colors(:steam_core)
    @legend_4    = LUIT::Button.new(@window, @window, nil, button_width, button_height, ZOrder::UI, "Yellow: Power", 15 * @height_scale, 15 * @height_scale, color, hover_color, font_color)
    button_height += @legend_4.h
    color, hover_color = Hardpoint.get_hardpoint_colors(:generic)
    @legend_5    = LUIT::Button.new(@window, @window, nil, button_width, button_height, ZOrder::UI, "Green: Offensive/Engine", 15 * @height_scale, 15 * @height_scale, color, hover_color, font_color)
    button_height += @legend_5.h
    color, hover_color = Hardpoint.get_hardpoint_colors(:armor)
    @legend_6    = LUIT::Button.new(@window, @window, nil, button_width, button_height, ZOrder::UI, "Orange: Armor", 15 * @height_scale, 15 * @height_scale, color, hover_color, font_color)


    @buttons = [@steam_core_capacity_button, @steam_core_usage_button, @legend_1, @legend_2, @legend_3, @legend_4, @legend_5, @legend_6]

    @allow_current_ship_change = options[:allow_current_ship_change] || false
    # @fleet = {}

    if @allow_current_ship_change
      raw_fleet_data = ConfigSetting.get_setting(@save_file_path, "player_fleet")
      unconverted_fleet_data = JSON.parse(raw_fleet_data) if raw_fleet_data && raw_fleet_data != ''
      @fleet_data = Util.symbolize_all_keys(unconverted_fleet_data)
      # puts "pre fl;eet data"
      # puts @fleet_data
      # {"0"=>{"klass"=>"PilotableShips::BasicShip", "hardpoint_locations"=>{"0"=>"HardpointObjects::GrapplingHookHardpoint", "1"=>"HardpointObjects::BulletHardpoint", "4"=>"HardpointObjects::BulletHardpoint", "3"=>"HardpointObjects::BulletHardpoint", "5"=>"HardpointObjects::DumbMissileHardpoint", "2"=>"HardpointObjects::BulletHardpoint", "10"=>"HardpointObjects::BasicEngineHardpoint", "6"=>"HardpointObjects::MinigunHardpoint", "8"=>"HardpointObjects::BasicEngineHardpoint", "12"=>"HardpointObjects::BasicSteamCoreHardpoint"}}}
      if @fleet_data
        current_x = @cell_width
        current_y = @max_height * 0.8
        delete_bad_data_at = []
        @fleet_data.each do |fleet_index, fleet_data|
          # puts "FEET DATA instacnt"
          # puts fleet_data.inspect
          if fleet_data[:klass].nil?
            puts "MISSING FLEET CLASS HERE, deleting data"
            puts fleet_data.inspect
            delete_bad_data_at << fleet_index
            next
          end
          klass = eval(fleet_data[:klass])
          image = klass.get_image(klass::ITEM_MEDIA_DIRECTORY)
          fleet_data[:image_scaler] = @height_scale / klass::IMAGE_SCALER
          fleet_data[:image_width]  = (image.width * @height_scale) / klass::IMAGE_SCALER
          fleet_data[:image_height] = (image.height * @height_scale) / klass::IMAGE_SCALER
          fleet_data[:image] = image

          fleet_data[:x] = current_x
          fleet_data[:y] = current_y

          fleet_data[:button_key] = "fleet_index_#{fleet_index.to_s}"
          puts "fleet_data[:button_key] = #{fleet_data[:button_key]}"
          # @click_area = LUIT::ClickArea.new(@window, self, :object_inventory, 0, 0, ZOrder::HardPointClickableLocation, @image_width, @image_height, nil, nil, {hide_rect_draw: true, key_id: Gosu::KB_E})
          click_area = LUIT::ClickArea.new(@window, @window, fleet_data[:button_key], current_x, current_y, ZOrder::HardPointClickableLocation, fleet_data[:image_width], fleet_data[:image_height], nil, nil, {hide_rect_draw: true})
          fleet_data[:click_area] = click_area

          @button_id_mapping[fleet_data[:button_key]] = lambda { |window, menu, id| menu.click_fleet_ship(id.sub('fleet_index_', '')) if !window.block_all_controls }

          button_key = "make_primary_fleet_index_#{fleet_index.to_s}"
          fleet_data[:make_primary_ship_button] = LUIT::Button.new(@window, @window, button_key, current_x, current_y - (15 * @height_scale), ZOrder::UI, "Switch", 15 * @height_scale, 15 * @height_scale)
          @button_id_mapping[button_key] = lambda { |window, menu, id| menu.change_flagship(id.sub('make_primary_fleet_index_', '')) if !window.block_all_controls }
          # fleet_data[:image].draw(current_x, current_y, ZOrder::UI, fleet_data[:image_scaler], fleet_data[:image_scaler], 0xff_ffffff)
          current_x += fleet_data[:image_width] + @cell_width
        end

        delete_bad_data_at.each do |key|
          @fleet_data.delete(key)
        end
      else
        @fleet_data = {}
      end
    end
    # puts "FLEET PARRSED"
    # puts @fleet_data
  end

  def change_flagship fleet_index
    puts "change_flagship #{fleet_index}"
    ConfigSetting.set_setting(@save_file_path, "current_ship_index", fleet_index.to_i)
    @flagship_index = fleet_index.to_s
  end

  def click_fleet_ship fleet_index
    puts "click_fleet_ship: #{fleet_index}"
    puts fleet_index.class
    @ship_index = fleet_index

    @ship_value = ConfigSetting.get_mapped_setting(@save_file_path, ["player_fleet", @ship_index, "klass"])
    raise "missing ship value at #{@ship_index}. GOT: #{@ship_value.inspect}" if @ship_value.nil? || @ship_value == ''
    begin
      klass = eval(@ship_value)
    rescue Exception => e
      puts "Caught Error in Eval: #{e.class} when trying to access 'ship' "
      puts e.message
      puts e.backtrace.join("\n")
      puts "EVAL DATA:"
      puts @ship_value
    end

    hardpoint_data = PilotableShips::PilotableShip.get_hardpoint_data(fleet_index)
    puts "hardpoint data"
    puts hardpoint_data
    @ship = klass.new(@max_width / 2, @max_height / 2, ZOrder::Player, ZOrder::Hardpoint, ZOrder::HardpointBase, 0, "INVENTORY_WINDOW", {always_show: true, use_large_image: true, hide_hardpoints: true, block_initial_angle: true}.merge(hardpoint_data))

    @current_fleet_index = "fleet_index_#{@ship_index}"
    @ship_hardpoints = init_hardpoints_clickable_areas(@ship)
  end

  def add_to_ship_inventory_credits new_credits
    @ship_inventory.add_credits(new_credits)
  end
  def subtract_from_ship_inventory_credits new_credits
    @ship_inventory.subtract_credits(new_credits)
  end
  def get_ship_inventory_credits
    @ship_inventory.credits
  end

  def loading_object_inventory object, drops = [], credits = 0, holding_type = :not_available, options = {}
   # puts "LAODING OJECT INVENTORY #{drops}"
   # puts "WHAT WAS ON THE OBHECT: #{object.drops}"
    @object_inventory = ObjectInventory.new(@window, object.class.to_s, drops, credits, object, holding_type, options)

    @buy_rate_from_store  = @object_inventory.buy_rate
    @sell_rate_from_store = @object_inventory.sell_rate

    if @buy_rate_from_store.nil? || @sell_rate_from_store.nil?
      raise "INVALID OBJECT INVENTORY RATES"
    end
    # @ship_hardpoints = init_hardpoints_clickable_areas(@ship)
    @ship_inventory = ShipInventory.new(@window, {sell_rate: @sell_rate_from_store, buy_rate: @buy_rate_from_store})
    @object_inventory_holding_type = holding_type
  end 

  def unloading_object_inventory
   # puts "TRYING TO UNLOAD OBJECT INVENTORY"
    if @object_inventory
      @object_inventory.unload_inventory
      @object_inventory = nil
      @buy_rate_from_store  = 1.0
      @sell_rate_from_store = 1.0
      @ship_inventory = ShipInventory.new(@window)
      @object_inventory_holding_type = :none
      # @ship_hardpoints = init_hardpoints_clickable_areas(@ship)
    end
  end 

  def enable
    @active = true
  end
  def disable
    @active = false
  end

  # def retrieve_inventory_items
  # end

  def self.get_id_button_mapping
    values = {
      # next:     lambda { |window, menu, id| menu.next_clicked },
      # previous: lambda { |window, menu, id| menu.previous_clicked },
      back:     lambda { |window, menu, id| window.block_all_controls = true; window.cursor_object.nil? ? (menu.unloading_object_inventory ;menu.refresh_player_ship = true;  menu.disable;) : nil }
    }
  end

  def onClick element_id
    found_button = @ship_inventory.onClick(element_id)
    found_button = @object_inventory.onClick(element_id) if !found_button && @object_inventory
    super(element_id) if !found_button
  end

  def hardpoint_draw
    @ship_hardpoints.each do |value|
      click_area = value[:click_area]
      if click_area
        click_area.draw(0, 0)
      else
      end
      item = value[:item]
      if item
        image = item[:image]
        if image
          image.draw(
            value[:x] - (image.width  / 2 ) / IMAGE_SCALER * @height_scale,
            value[:y] - (image.height / 2 ) / IMAGE_SCALER * @height_scale,
            @hardpoint_image_z,
            @height_scale / IMAGE_SCALER, @height_scale / IMAGE_SCALER
          )
        end
        if !value[:hp].is_valid_slot_type(item[:hardpoint_item_slot_type])
          @invalid_hardpoint_image.draw(
            value[:x] - (image.width / 2) / IMAGE_SCALER * @height_scale,
            value[:y] - (image.height / 2) / IMAGE_SCALER * @height_scale,
            @hardpoint_image_z,
            @height_scale / IMAGE_SCALER, @height_scale / IMAGE_SCALER
          )
        end
      end
    end
  end

  def init_hardpoints_clickable_areas ship
    # Populate ship hardpoints from save file here.
    # will be populated from the ship, don't need to here.

    value = []
    ship.hardpoints.each_with_index do |hp, index|
      button_key = "hardpoint_#{index}"

      color, hover_color = hp.hardpoint_colors
      click_area = LUIT::ClickArea.new(@window, @window, button_key, hp.x - @cell_width  / 2, hp.y - @cell_width  / 2, ZOrder::HardPointClickableLocation, @cell_width, @cell_height, color, hover_color)
      @button_id_mapping[button_key] = lambda { |window, menu, id| menu.click_ship_hardpoint(id) if !window.block_all_controls }
      if hp.assigned_weapon_class
        if @buy_rate_from_store.nil? || @sell_rate_from_store.nil?
          raise "INVALID OBJECT INVENTORY RATES"
        end
        image = hp.assigned_weapon_class.get_hardpoint_image
        item = {
          image: image, key: button_key, klass: hp.assigned_weapon_class, value: hp.assigned_weapon_class.value,
          sell_rate: @sell_rate_from_store,
          buy_rate:  @buy_rate_from_store,
          # hardpoint_slot_type: hp.slot_type,
          hardpoint_item_slot_type: hp.assigned_weapon_class::SLOT_TYPE
        }

      else
        item = nil
      end

      value << {item: item, x: hp.x, y: hp.y, click_area: click_area, key: button_key, hp: hp}
    end
    # puts "VALUES HERE FRONT:"
    # puts value[:front]
    # puts "VALUES HERE RIGHT:"
    # puts value[:right].count
    # puts "VALUES HERE LEFT:"
    # puts value[:left].count

    # ship.port_hard_points.each do |hp|
    #   value[:left] << {weapon_klass: hp.assigned_weapon_class, x: hp.x + hp.x_offset, y: hp.y + hp.y_offset}
    # end

    # ship.front_hard_points.each do |hp|
    #   value[:front] << {weapon_klass: hp.assigned_weapon_class, x: hp.x + hp.x_offset, y: hp.y + hp.y_offset}
    # end
    return value
  end

  # THIS IS NOT WORKING CORRECTKLY.
  def click_ship_hardpoint id
   # puts "click_ship_hardpoint: #{id}"
    # Key is front, right, or left
    # left_hardpoint_0
    # current_object = @window.cursor_object || @ship_inventory.cursor_object


    result = id.scan(/hardpoint_(\d+)/).first
    raise "Could not find hardpoint ID" if result.nil?
    i = result.first.to_i
    # puts "PORT AND I: #{port} and #{i}"

    hardpoint_element = @ship_hardpoints[i]
    element = hardpoint_element ? hardpoint_element[:item] : nil
   # puts "@window.cursor_object:"
   # puts @window.cursor_object.inspect

    if @window.cursor_object && element
     # puts "@window.cursor_object[:key]: #{@window.cursor_object[:key]}"
     # puts "ID: #{id}"
     # puts "== #{@window.cursor_object[:key] == id}"
      if @window.cursor_object[:key] == id
        # Same Object, Unstick it, put it back
        # element[:follow_cursor] = false
        # @inventory_matrix[x][y][:item][:follow_cursor] =
        hardpoint_element[:item] = @window.cursor_object
       # puts "CONFIG SETTING 1"
        ConfigSetting.set_mapped_setting(@save_file_path, ["player_fleet", @ship_index, "hardpoint_locations", i.to_s], hardpoint_element[:item][:klass])
        hardpoint_element[:item][:key] = id
        @window.cursor_object = nil
      else
        # Else, drop object, pick up new object
        # @window.cursor_object[:follow_cursor] = false
        # element[:follow_cursor] = true
        temp_element = element
        hardpoint_element[:item] = @window.cursor_object
        hardpoint_element[:item][:key] = id
       # puts "CONFIG SETTING 2 "
        ConfigSetting.set_mapped_setting(@save_file_path, ["player_fleet", @ship_index, "hardpoint_locations", i.to_s], hardpoint_element[:item][:klass])
        @window.cursor_object = temp_element
        @window.cursor_object[:key] = nil # Original home lost, no last home of key present
        # @window.cursor_object[:follow_cursor] = true
        # WRRROOOONNGGG!
        # element = 
      end
    elsif element
      # Pick up element, no current object
      # element[:follow_cursor] = true
      @window.cursor_object = element
      hardpoint_element[:item] = nil
       # puts "CONFIG SETTING 3 "
        # Not working.. 
      # puts [@ship.class.name, "#{port}_hardpoint_locations", i.to_s].to_s
      ConfigSetting.set_mapped_setting(@save_file_path, ["player_fleet", @ship_index, "hardpoint_locations", i.to_s], nil)
    elsif @window.cursor_object
      # Placeing something new in inventory
      hardpoint_element[:item] = @window.cursor_object
      # puts "PUTTING ELEMENT IN: #{hardpoint_element[:item]}"
        # puts "CONFIG SETTING 4 "
      # puts [@ship.class.name, "#{port}_hardpoint_locations", i.to_s].to_s
      # puts hardpoint_element[:item][:klass]
      ConfigSetting.set_mapped_setting(@save_file_path, ["player_fleet", @ship_index, "hardpoint_locations", i.to_s], hardpoint_element[:item][:klass])
      hardpoint_element[:item][:key] = id
      # matrix_element[:item][:follow_cursor] = false
      @window.cursor_object = nil
    end
  end

  # def get_values
  #   if @value
  #     @value
  #   end
  # end

  def hardpoint_update
    hover_object = nil
    ship_steam_core_capacity = 0
    ship_steam_core_usage    = 0
    @ship_hardpoints.each do |value|
      click_area = value[:click_area]
      # puts "CLICK AREA: #{click_area.y}"
      if click_area
        is_hover = click_area.update(0, 0)
        # puts "WAS HARDPOINT HOVER? #{is_hover}"
        # puts "Value item"
        if value[:item] && value[:hp].is_valid_slot_type(value[:item][:hardpoint_item_slot_type])
          if value[:item][:hardpoint_item_slot_type] == :steam_core
            ship_steam_core_capacity += value[:item][:klass]::STEAM_MAX_CAPACITY
          # elsif value[:item][:hardpoint_item_slot_type] == :engine
          else
            ship_steam_core_usage += value[:item][:klass]::PERMANENT_STEAM_USE
          end
        end


        hover_object = {item: value[:item], holding_type: :hardpoint, holding_slot: value[:hp] } if is_hover
        # raise "GOT HERE" if is_hover
      end
    end
    @ship_steam_core_capacity = ship_steam_core_capacity.round
    @ship_steam_core_usage    = ship_steam_core_usage.round

    return hover_object
  end

  def update mouse_x, mouse_y
    if @active
      # puts "SHIP LOADOUT SETTING - HAD CURSOR OJBECT" if @window.cursor_object
      # if @window.cursor_object.nil? && @ship_inventory
      @mouse_x, @mouse_y = [mouse_x, mouse_y]

      @hover_object = hardpoint_update

      @steam_core_capacity_button.update_text(@steam_core_capacity_text + @ship_steam_core_capacity.to_s)
      @steam_core_usage_button.update_text(@steam_core_usage_text + @ship_steam_core_usage.to_s)

      # hover_object = matrix_update
      if @object_inventory && @object_inventory.holding_type == :store
        hover_object = @ship_inventory.update(mouse_x,   mouse_y)
        hover_object = @object_inventory.update(mouse_x, mouse_y, @ship_inventory.credits) if !hover_object
      else
        hover_object = @ship_inventory.update(mouse_x, mouse_y)
        hover_object = @object_inventory.update(mouse_x, mouse_y) if !hover_object && @object_inventory
      end
      @hover_object = hover_object if @hover_object.nil?
      @button.update(-(@button.w / 2), -(@button.h / 2))
      @buttons.each {|b| b.update(0,0)}

      fleet_update if @allow_current_ship_change

      return true
    else
      return nil
    end
  end

  def detail_box_draw
    if @hover_object
      texts = []
      text = nil

      # Are these necessary here? Is there a difference? Maybe if it's a store, we can show a price.


      if @hover_object[:item]
        object = @hover_object[:item]
        value_text = "Sell Value: $#{object[:value]}"
        if @object_inventory_holding_type == :store
          if object[:from_store]
            value_text = "Buy Value: $#{(object[:value] * object[:sell_rate]).to_i}"
          else
            # In the future, can get sell rate from store from where we get `@object_inventory_holding_type`
            value_text = "Sell Value: $#{(object[:value] * 0.1).to_i}"
          end
        else
          value_text = "Value: $#{object[:value]}"
        end

        if object[:klass].name
          texts << object[:klass].name
        end
        if object[:klass].description
          if object[:klass].description.is_a?(String)
            texts << object[:klass].description
          elsif object[:klass].description.is_a?(Array)
            object[:klass].description.each do |description|
              texts << description
            end
          end
          texts << value_text
        end
      end

      padding_y  = @font_height / 2
      padding_x  = @font_height / 2
      box_x      = (@max_width / 4) - padding_x
      box_y      = (@max_height) - ((@font_height) * 8) - padding_y
      box_width  = (@max_width / 2) + padding_x
      box_height = (texts.count * @font_height) + padding_y + padding_y
      # puts "BOX DIMENTIONS"
      # puts [box_x, box_y, box_width, box_height].join(", ")
      # 320, 960, 640, 72
      Gosu::draw_rect(box_x, box_y, box_width, box_height, Gosu::Color.argb(0xff_595959), ZOrder::MenuBackground) if texts.count > 0

      texts.each_with_index do |text, index|
        height_padding = index * @font_height
        # puts "HEIGHT PADDING: #{index} - #{height_padding}"
        @font.draw(text, (@max_width / 4), (@max_height) + height_padding - (@font_height * 8), ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
        # @font.draw(text, (@max_width / 2) - (@font.text_width(text) / 2.0), (@max_height) - @font_height - (@font_padding * 4), ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      end
    end
  end

  def fleet_draw
    @fleet_data.each do |key, fleet_data|
      fleet_data[:image].draw(fleet_data[:x], fleet_data[:y], ZOrder::UI, fleet_data[:image_scaler], fleet_data[:image_scaler], 0xff_ffffff)
      if @current_fleet_index == fleet_data[:button_key]
        Gosu::draw_rect(fleet_data[:x], fleet_data[:y], fleet_data[:image_width], fleet_data[:image_height], Gosu::Color.argb(0xff_595959), ZOrder::MenuBackground)
      end

      if @flagship_index != key.to_s
        fleet_data[:make_primary_ship_button].draw(0,0)
      end

    end
  end

  def fleet_update
    @fleet_data.each do |key, fleet_data|
      fleet_data[:click_area].update(0,0)

      if @flagship_index != key.to_s
        fleet_data[:make_primary_ship_button].update(0,0)
      end

    end
  end

  def draw
    if @active
      @ship_inventory.draw
      @object_inventory.draw if @object_inventory

      fleet_draw if @allow_current_ship_change

      detail_box_draw

      if @window.cursor_object
        @window.cursor_object[:image].draw(@mouse_x, @mouse_y, @hardpoint_image_z, @height_scale / IMAGE_SCALER, @height_scale / IMAGE_SCALER)
      end

      hardpoint_draw

      # matrix_draw

      # @button.draw(-(@button.w / 2), -(@y_offset - @button.h / 2))
      @button.draw(-(@button.w / 2), -(@button.h / 2))
      # @steam_core_capacity_button.draw(0, 0)
      # @steam_core_usage_button.draw(0, 0)
      @buttons.each {|b| b.draw(0,0)}

      # @font.draw(@name, ((@max_width / 2) - @font.text_width(@name) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)

      @ship.draw
      # @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)
      # @font.draw(">", @prev_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
    end
  end

end