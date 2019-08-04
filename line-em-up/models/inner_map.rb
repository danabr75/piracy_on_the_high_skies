require_relative "../lib/global_constants.rb"
include GlobalConstants
Dir["#{LIB_DIRECTORY  }/*.rb"].each { |f| require f }
Dir["#{MODEL_DIRECTORY}/*.rb"].each { |f| require f }
Dir["#{VENDOR_LIB_DIRECTORY}/*.rb"].each { |f| require f }
# Sub folders as well.
Dir["#{LIB_DIRECTORY  }/**/*.rb"].each { |f| require f }
Dir["#{MODEL_DIRECTORY}/**/*.rb"].each { |f| require f }
Dir["#{VENDOR_LIB_DIRECTORY}/**/*.rb"].each { |f| require f }

class InnerMap
  include GlobalConstants

  attr_accessor :width, :height, :block_all_controls, :ship_loadout_menu, :menu, :cursor_object

  attr_accessor :projectiles, :destructable_projectiles, :ships, :graphical_effects, :shipwrecks, :add_graphical_effects
  attr_accessor :add_projectiles, :remove_projectile_ids
  attr_accessor :add_ships, :remove_ship_ids, :add_buildings, :remove_building_ids
  attr_accessor :add_destructable_projectiles, :remove_destructable_projectile_ids
  attr_accessor :add_shipwrecks, :remove_shipwreck_ids

  attr_reader :player, :mouse_x, :mouse_y
  attr_accessor :show_minimap, :game_pause
  attr_reader :active

  attr_accessor :exit_map, :add_messages

  include GlobalVariables



  def initialize window, map_name, fps_scaler, resolution_scale, width_scale, height_scale, average_scale, width, height, options = {}
    # LUIT.config({window: window}) # not really necessary logically speaking ,but this appears to have fixed a bug where the background tiles were the wrong image, after using the outer map ship loadout screen.
    @window, @fps_scaler, @resolution_scale, @width_scale, @height_scale, @average_scale, @width, @height = [window, fps_scaler, resolution_scale, width_scale, height_scale, average_scale, width, height]
    # @local_window = self

    @fps_log = []
    @fps_counter = 0

    @config_path = self.class::CONFIG_FILE
    @save_file_path = self.class::CURRENT_SAVE_FILE

    @open_gl_executer = ExecuteOpenGl.new

    # GET difficulty from config file.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    @difficulty = options[:difficulty]
    @block_all_controls = !options[:block_controls_until_button_up].nil? && options[:block_controls_until_button_up] == true ? true : false
    @debug = true #options[:debug]
    # GameWindow.fullscreen(self) if fullscreen
    # @start_fullscreen = fullscreen
    @center_ui_y = 0
    @center_ui_x = 0
    
    # graphics_value = ConfigSetting.get_setting(@config_path, "Graphics Setting", GraphicsSetting::SELECTION[0])
    # @graphics_setting = GraphicsSetting.get_interval_value(graphics_value)


    @collision_counter = 0
    @destructable_collision_counter = 1
    @projectile_collision_manager              = AsyncProcessManager.new(ProjectileCollisionThread, 16, true, :joined_threads)
    @destructable_projectile_collision_manager = AsyncProcessManager.new(DestructableProjectileCollisionThread, 8, true, :joined_threads)
    @destructable_projectile_update_manager    = AsyncProcessManager.new(DestructableProjectileUpdateThread, 8, true, :joined_threads)
    @ship_collision_manager                    = AsyncProcessManager.new(ShipCollisionThread, 6, true, :joined_threads)
    # if true #@graphics_setting == :basic
      # Maybe just wait for all threads to finish???
      @ship_update_manager       = AsyncProcessManager.new(ShipUpdateThread, 6, true, :joined_threads)
      # @projectile_update_manager = AsyncProcessManager.new(ProjectileUpdateThread, 16, true, :test_processes)
      @projectile_update_manager = AsyncProcessManager.new(Projectiles::Projectile, 8, true, :processes, :async_update, :get_data, :set_data, "#{MODEL_DIRECTORY}/projectiles/projectile.rb")
      # Building update needs to be joined, or else ships are updated with missing images
      @building_update_manager   = AsyncProcessManager.new(BuildingUpdateThread, 6, true, :joined_threads) # , :joined_threads
      @shipwreck_update_manager   = AsyncProcessManager.new(ShipWreckUpdateThread, 2, true, :joined_threads) # , :joined_threads
    # else
    #   @ship_update_manager       = AsyncProcessManager.new(ShipUpdateThread, 8, true)
    #   @projectile_update_manager = AsyncProcessManager.new(ProjectileUpdateThread, 8, true)
    #   @building_update_manager   = AsyncProcessManager.new(BuildingUpdateThread, 8, true)
    # end

    @game_pause = false
    # @menu = nil
    # @can_open_menu = true
    # @can_pause = true
    @can_resize = !options[:block_resize].nil? && options[:block_resize] == true ? false : true
    @can_toggle_secondary = true
    # @can_toggle_fullscreen_a = true
    # @can_toggle_fullscreen_b = true


    @graphics_setting = GlobalVariables.graphics_setting
    @factions = GlobalVariables.factions

    load_map(map_name) if map_name

    # GlobalVariables.set_config(@width_scale, @height_scale, @width, @height,
    #   @gl_background.map_pixel_width, @gl_background.map_pixel_height,
    #   @gl_background.map_tile_width, @gl_background.map_tile_height,
    #   @gl_background.tile_pixel_width, @gl_background.tile_pixel_height,
    #   @fps_scaler, @graphics_setting, @factions, @resolution_scale, false
    # )

    @buildings = {}
    @projectiles = {}

    @add_projectiles = []
    @remove_projectile_ids = []

    @add_destructable_projectiles = []
    @remove_destructable_projectile_ids = []
    @destructable_projectiles = {}

    # @enemy_projectiles = Array.new
    # @pickups = Array.new

    @add_ships = []
    @ships = {}
    @remove_ship_ids = []

    @add_buildings    = []
    @remove_building_ids = []



    @shipwrecks = {}
    @add_shipwrecks = []
    @remove_shipwreck_ids = []
    
    @effects = []
    @graphical_effects = []
    @add_graphical_effects = []

    @font = Gosu::Font.new((10 * ((@width_scale + @height_scale) / 2.0)).to_i)

    @ui_y = 0
    @footer_bar = FooterBar.new(self)
    reset_font_ui_y

    @key_pressed_map = {}

    # raise "@player.current_map_pixel_x.nil" if @player.current_map_pixel_x.nil?
    # raise "@player.current_map_pixel_y.nil" if @player.current_map_pixel_y.nil?


    # @center_target = @player
    
    

    @quest_data = QuestInterface.get_quests(@window, @save_file_path)

    # @pickups = values[:pickups]

    @messages = []
    @add_messages = []


    @viewable_pixel_offset_x, @viewable_pixel_offset_y = [0, 0]
    viewable_center_target = nil


    @viewable_offset_x = 0
    @viewable_offset_y = 0
    # # @boss_active = false
    # @boss = nil
    # @boss_killed = false

    # @window = self
    @menu = Menu.new(self, @width / 2, 10 * @height_scale, ZOrder::UI, @height_scale, {add_top_padding: true})
    @menu.add_item(
      :resume, "Resume",
      0, 0,
      lambda {|window, menu, id| window.block_all_controls = true; menu.disable },
      nil,
      {is_button: true}
    )
    @menu.add_item(
      :save_game, "Leave Map",
      0, 0,
      lambda do |window, menu, id|
        if !window.block_all_controls
          if are_enemies_near_player? && @player.is_alive
            @messages << MessageFlash.new("Enemies are too close!")
            menu.disable
          else
            window.block_all_controls = true
            window.save_inner_map_data
            window.exit_map = true
            menu.disable
          end
        end
      end,
      nil,
      {is_button: true}
    )
    @menu.add_item(
      :exit_to_main_menu, "Exit to Main Menu (lose partial progress!)",
      0, 0,
      lambda {|window, menu, id| menu.disable; window.activate_main_menu; }, 
      nil,
      {is_button: true}
    )
    @menu.add_item(
      :exit_to_desktop, "Exit to Desktop (lose partial progress!)",
      0, 0,
      lambda {|window, menu, id| window.exit_game; }, 
      nil,
      {is_button: true}
    )

    @exit_map_menu = Menu.new(self, @width / 2, 10 * @height_scale, ZOrder::UI, @height_scale, {add_top_padding: true})
    @exit_map_menu.add_item(
      nil, "Exit Map?",
      0, 0,
      lambda {|window, menu, id| },
      nil,
      {is_button: true}
    )
    @exit_map_menu.add_item(
      :exit_map, "Yes",
      0, 0,
      # Might be the reason why the mapping has to exist in the game window scope. Might not have access to ship loadout menu here.
      lambda do |window, menu, id|
        if !window.block_all_controls
          window.block_all_controls = true
          window.save_inner_map_data
          window.exit_map = true
        end
      end,
      nil,
      {is_button: true}
    )
    # This will close the window... which i guess is fine.
    @exit_map_menu.add_item(
      :cancel_map_exit, "No",
      0, 0,
      lambda do |window, menu, id|
        if !window.block_all_controls 
          window.block_all_controls = true
          window.player.cancel_map_exit
          menu.disable
        end
      end, 
      nil,
      {is_button: true}
    )
    @exit_map = false

    # END  MENU INIT

    # START SHIP LOADOUT INIT.
    # @refresh_player_ship = false
    @cursor_object = nil
    @ship_loadout_menu = ShipLoadoutSetting.new(self, @width, @height, get_center_font_ui_y, @height_scale, @height_scale, {scale: @average_scale})


    @player_death_logic_activated = false
    # @death_menu = Menu.new(self, @width / 2, 10 * @height_scale, ZOrder::UI, @height_scale, {add_top_padding: true})
    # @exit_map_menu.add_item(
    #   nil, "You have died",
    #   0, 0,
    #   nil,
    #   nil,
    #   {is_button: true}
    # )
    # @exit_map_menu.add_item(
    #   :exit_map, "Yes",
    #   0, 0,
    #   # Might be the reason why the mapping has to exist in the game window scope. Might not have access to ship loadout menu here.
    #   lambda do |window, menu, id|
    #     if !window.block_all_controls
    #       window.block_all_controls = true
    #       window.save_inner_map_data
    #       window.exit_map = true
    #     end
    #   end,
    #   nil,
    #   {is_button: true}
    # )
    # # This will close the window... which i guess is fine.
    # @exit_map_menu.add_item(
    #   :cancel_map_exit, "No",
    #   0, 0,
    #   lambda do |window, menu, id|
    #     if !window.block_all_controls 
    #       window.block_all_controls = true
    #       window.player.cancel_map_exit
    #       menu.disable
    #     end
    #   end, 
    #   nil,
    #   {is_button: true}
    # )






    # @object_attached_to_cursor = nil
    # END  SHIP LOADOUT INIT.
    @menus = [@ship_loadout_menu, @menu, @exit_map_menu]
    # LUIT.config({window: @window, z: 25})
    # @button = LUIT::Button.new(@window, :test, 450, 450, "test", 30, 30)
    @show_minimap = true
    @mini_map = nil# ScreenMap.new(@gl_background.map_name, @gl_background.map_tile_width, @gl_background.map_tile_height)

    @mouse_x = 0
    @mouse_y = 0
    @active = true
  end

  def are_enemies_near_player?
    found_enemies_near_player = false
    @ships.each do |ship_id, ship|
      # Next if ship is not hostile to player
      next if !ship.is_hostile_to?(@player.get_faction_id)
      found_enemies_near_player = true if Gosu.distance(@player.current_map_tile_x, @player.current_map_tile_y, ship.current_map_tile_x, ship.current_map_tile_y) < 5
      break if found_enemies_near_player
    end
    if found_enemies_near_player == false
      @buildings.each do |b_id, b|
        # Next if ship is not hostile to player
        next if !b.is_hostile_to?(@player.get_faction_id)
        found_enemies_near_player = true if Gosu.distance(@player.current_map_tile_x, @player.current_map_tile_y, b.current_map_tile_x, b.current_map_tile_y) < 5
        break if found_enemies_near_player
      end
    end

    return found_enemies_near_player
  end

  # Load new map, reset what needs to be reset.
  def load_map map_name
    puts "LOAD MAP : #{map_name}"
    @map_name = map_name
    @ship_loadout_menu = ShipLoadoutSetting.new(self, @width, @height, get_center_font_ui_y, @height_scale, @height_scale, {scale: @average_scale})
    @gl_background = GLBackground.new(@map_name, @height_scale, @height_scale, @width, @height, @resolution_scale, @graphics_setting)
    @menus = [@ship_loadout_menu, @menu, @exit_map_menu]
    # @factions = Faction.init_factions(@height_scale)

    GlobalVariables.set_inner_map(
      @gl_background.map_pixel_width, @gl_background.map_pixel_height,
      @gl_background.map_tile_width, @gl_background.map_tile_height,
      @gl_background.tile_pixel_width, @gl_background.tile_pixel_height,
    )
    @mini_map = ScreenMap.new(@gl_background.map_name, @gl_background.map_tile_width, @gl_background.map_tile_height)

    @quest_data, @ships, @buildings, @messages, @effects = QuestInterface.init_quests_on_map_load(@save_file_path, @quest_data, @gl_background.map_name, @ships, @buildings, @player, @messages, @effects, self, {debug: @debug})

    @player_perma_death = false
    @player = Player.new(nil, nil, 0, 120)
    @player_death_logic_activated = false
    # if rand(2) == 0
    #   if rand(2) == 0
    #     @player = Player.new(nil, nil, rand(@gl_background.map_tile_width), 0)
    #   else
    #     @player = Player.new(nil, nil, rand(@gl_background.map_tile_width), @gl_background.map_tile_height - 2)
    #   end
    # else
    #   if rand(2) == 0
    #     @player = Player.new(nil, nil, 0, rand(@gl_background.map_tile_height))
    #   else
    #     @player = Player.new(nil, nil, @gl_background.map_tile_width - 2, rand(@gl_background.map_tile_height))
    #   end
    # end
    @center_target = @player
    values = @gl_background.init_map(@center_target.current_map_tile_x, @center_target.current_map_tile_y, self)

    @buildings = {}
    @projectiles = {}

    @add_projectiles = []
    @remove_projectile_ids = []

    @add_destructable_projectiles = []
    @remove_destructable_projectile_ids = []
    @destructable_projectiles = {}

    @add_ships = []
    @ships = {}
    @remove_ship_ids = []

    @add_buildings    = []
    @remove_building_ids = []

    @shipwrecks = {}
    @add_shipwrecks = []
    @remove_shipwreck_ids = []
    
    @effects = []
    @graphical_effects = []
    @add_graphical_effects = []
    
    # puts "got values back from map:"
    # puts values[:buildings].first
    values[:buildings].each do |b|
      @buildings[b.id] = b
    end
    values[:ships].each do |ship|
      @ship[ship.id] = ship
    end


    @pointer = Cursor.new(@width, @height, @height_scale, @height_scale, @player)
    
    @font = Gosu::Font.new((10 * ((@width_scale + @height_scale) / 2.0)).to_i)

    @ui_y = 0
    @footer_bar = FooterBar.new(self)
    reset_font_ui_y

    @key_pressed_map = {}

  end

  def exit_hooks
    [
      @projectile_collision_manager,
      @destructable_projectile_collision_manager,
      @destructable_projectile_update_manager,
      @ship_collision_manager,
      @ship_update_manager,
      @projectile_update_manager,
      @building_update_manager,
      @shipwreck_update_manager
    ].each do |manager|
      manager.exit_hooks
    end
  end

  def exit_game
    @window.exit_game
  end

  def save_inner_map_data
    puts "save_inner_map_data"
    # Can save ship data as well.
    # if !@player.is_alive
    # end
    @gl_background.store_background_data(@buildings)
    Faction.save_factions(@factions)    
  end

  def save_game
    @window.save_game
  end

  def activate_main_menu
    @window.activate_main_menu
  end

  def enable
    @active = true
  end

  def disable
    @exit_map = false
    @exit_map_menu.disable
    @active = false
  end


  def key_id_lock id
    if @key_pressed_map.key?(id)
      return false
    else
      @key_pressed_map[id] = true
      return true
    end
  end

  def key_id_release id
    value = @key_pressed_map.delete(id)
  end

  def menus_active
    @menus.collect{|menu| menu.active }.include?(true)
  end

  def menus_disable
    @menus.each{|menu| menu.disable }
  end

  # # Switch button downs to this method
  # # This only triggers once during press. Use the other section for when we want it contunually triggered
  # def button_down(id)
  #   if @player.is_alive && !@game_pause && !@menu_open
  #     if id == Gosu::KB_LEFT_CONTROL && @player.ready_for_special?
  #     end
  #   end
  # end



  # required for LUIT objects, passes id of element
  def onClick element_id
    if @menu.active
      @menu.onClick(element_id)
    elsif @player.is_alive && @ship_loadout_menu.active
      @ship_loadout_menu.onClick(element_id)
    elsif @exit_map_menu.active
      @exit_map_menu.onClick(element_id)
    else
      @footer_bar.onClick(element_id)
      if @effects.any?
        @effects.each do |effect|
          effect.onClick(element_id)
        end
      end
    end
  end

  def self.reset(window, options = {})
    window = GameWindow.new(window.width, window.height, window.fullscreen?, options.merge({block_controls_until_button_up: true})).show
  end

  def button_up id
    @block_all_controls = false
    if id == Gosu::MS_RIGHT
      @player.deactivate_group_3
    end
    if id == Gosu::MS_LEFT
      @player.deactivate_group_2
    end
    if id == Gosu::KB_SPACE
      @player.deactivate_group_1
    end

    if id == Gosu::KB_LEFT_SHIFT
      @player.disable_boost
    end
    key_id_release(id)
  end

  def get_center_font_ui_y
    return_value = @center_ui_y
    @center_ui_y += 10 * @average_scale
    return return_value
  end

  def get_center_font_ui_x
    return @center_ui_x
  end

  def activate_player_death_logic
    ship_index = (ConfigSetting.get_setting(@save_file_path, "current_ship_index")).to_s
    ConfigSetting.set_mapped_setting(@save_file_path, ["player_fleet", ship_index], nil)
    @messages << MessageFlash.new("You have died. You can leave map, and keep playing if you have spare ships.")
  end

  def update mouse_x, mouse_y
    # puts "@player.is_alive: #{@player.is_alive} and @player_death_logic_activated: #{@player_death_logic_activated}"
    @add_messages.reject! {|m| @messages << m; true }
    if @player_death_logic_activated == false && !@player.is_alive
      @player_death_logic_activated = true
      activate_player_death_logic
    end


    if @fps_counter < 60
      @fps_log << Gosu.fps if Gosu.fps < 55
      @fps_counter += 1
    else
      if @fps_log.count > 0
        puts "FPS Logger: " + @fps_log.join(', ')
        @fps_log = []
      end
      @fps_counter = 0
    end
    @mouse_x = mouse_x
    @mouse_y = mouse_y
    
    @quest_data, @ships, @buildings, @messages, @effects = QuestInterface.update_quests(@save_file_path, @quest_data, @gl_background.map_name, @ships, @buildings, @player, @messages, @effects, self)

    Thread.new do
      @mini_map.update(@player.current_map_tile_x, @player.current_map_tile_y, @buildings, @ships) if @show_minimap
    end

    @add_graphical_effects.reject! do |graphical_effect|
      @graphical_effects << graphical_effect
      true
    end

    @add_projectiles.reject! do |projectile|
      @projectiles[projectile.id] = projectile
      true
    end

    @remove_projectile_ids.reject! do |projectile_id|
      @projectiles.delete(projectile_id)
      true
    end

    @add_ships.reject! do |ship|
      @ships[ship.id] = ship
      true
    end

    @remove_ship_ids.reject! do |ship_id|
      @ships.delete(ship_id)
      true
    end

    @add_shipwrecks.reject! do |shipwreck|
      @shipwrecks[shipwreck.id] = shipwreck
      true
    end

    @remove_shipwreck_ids.reject! do |shipwreck_id|
      @shipwrecks.delete(shipwreck_id)
      true
    end

    @add_buildings.reject! do |b|
      @buildings[b.id] = b
      true
    end

    @remove_building_ids.reject! do |b_id|
      @buildings.delete(b_id)
      true
    end

    @add_destructable_projectiles.reject! do |dp|
      @destructable_projectiles[dp.id] = dp
      true
    end

    @remove_destructable_projectile_ids.reject! do |dp_id|
      @destructable_projectiles.delete(dp_id)
      true
    end

    if @ship_loadout_menu.refresh_player_ship
      @player.refresh_ship
      @ship_loadout_menu.refresh_player_ship = false
    end

    @menu.update
    @exit_map_menu.update
    @ship_loadout_menu.update(mouse_x, mouse_y) if @ship_loadout_menu.active

    if !@game_pause && !menus_active && !@menu_open && !@menu.active
      @effects.reject! do |effect_group|
        @gl_background, @ships, @buildings, @player, @viewable_center_target, @viewable_pixel_offset_x, @viewable_pixel_offset_y = effect_group.update(@gl_background, @ships, @buildings, @player, @viewable_center_target, @viewable_pixel_offset_x, @viewable_pixel_offset_y)
        !effect_group.is_active
      end

      @graphical_effects.reject! do |effect|
        !effect.update(mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y)
      end

      if @collision_counter < 2
        @collision_counter += 1
      else
        @projectile_collision_manager.update(self, @projectiles, [@ships, @destructable_projectiles, {'player' => @player} ], [@buildings])
        @collision_counter = 0
      end

      if @destructable_collision_counter < 2
        @destructable_collision_counter += 1
      else
        @destructable_projectile_collision_manager.update(self, @destructable_projectiles, [@ships, {'player' => @player} ], [@buildings])
        @destructable_collision_counter = 0
      end

      @destructable_projectile_update_manager.update(self, @destructable_projectiles, mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y)
      @projectile_update_manager.update(self, @projectiles, mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y)

      @ship_update_manager.update(self, @ships, mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y, @ships.merge({'player' => @player}), @buildings, {on_ground: @pointer.on_ground})
      @ship_collision_manager.update(self, @ships.merge({@player.id => @player}), [@ships.merge({@player.id => @player})])
    end

    @pointer.update(mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y, @player, @viewable_pixel_offset_x, @viewable_pixel_offset_y) if @pointer

    if true#!@block_all_controls
      @messages.reject! { |message| !message.update(mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y) }

      if Gosu.button_down?(Gosu::KbEscape) && key_id_lock(Gosu::KbEscape)
        @player.cancel_map_exit if @exit_map_menu.active
        if menus_active
          menus_disable
        else
          @menu.enable
        end
      end

      @footer_bar.update

      if Gosu.button_down?(Gosu::KB_I) && key_id_lock(Gosu::KB_I)
        if @ship_loadout_menu.active
          @ship_loadout_menu.disable
        else
          if @player.is_alive
            @ship_loadout_menu.enable
          else
            @add_messages << MessageFlash.new("Dead Men touch no inventories!")            
          end
        end
      end

      if @player.exiting_map?
        @exit_map_menu.enable
      end

      if Gosu.button_down?(Gosu::KB_M) && key_id_lock(Gosu::KB_M)
        @show_minimap = !@show_minimap
      end

      if Gosu.button_down?(Gosu::KB_P) && key_id_lock(Gosu::KB_P)
        @game_pause = !@game_pause
      end

      results = @gl_background.update(@player.current_map_pixel_x, @player.current_map_pixel_y, @buildings, @pickups, @viewable_pixel_offset_x, @viewable_pixel_offset_y)
      if results[:buildings]
        results[:buildings].each do |b_id, b|
          @buildings[b.id] = b
        end
      end
      if !@game_pause && !menus_active
        @building_update_manager.update(self, @buildings, mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y, @player.x, @player.y, @player, @ships, @buildings, {on_ground: @pointer.on_ground})
      end
      # if Gosu.button_down?(Gosu::KB_O) && key_id_lock(Gosu::KB_O)
      #   GameWindow.resize(self, 1920, 1080, false)
      # end

      # if Gosu.button_down?(Gosu::KB_MINUS) && key_id_lock(Gosu::KB_MINUS)
      #   GameWindow.down_resolution(self)
      # end
      # if Gosu.button_down?(Gosu::KB_EQUALS) && key_id_lock(Gosu::KB_EQUALS)
      #   GameWindow.up_resolution(self)
      # end



      if !@game_pause && !menus_active  && !@player_perma_death
        result = @player.update(mouse_x, mouse_y, @player.current_map_pixel_x, @player.current_map_pixel_y, @pointer.current_map_pixel_x, @pointer.current_map_pixel_y)
        # puts "PLAYER RESULT"
        # puts result
        if !result[:is_alive]
          @player_perma_death = true
        end
        if result[:buildings]
          result[:buildings].each do |b|
            @buildings[b.id] = b
          end
        end
        if result[:shipwreck]
          # puts "PLAYER ADDING SHIPWRECK To list."
          @add_shipwrecks << result[:shipwreck]
          # @shipwrecks[result[:shipwreck].id] = result[:shipwreck]
        end
      end
      if @player.is_alive && !@game_pause && !menus_active
        @player.accelerate if Gosu.button_down?(Gosu::KB_UP)    || Gosu.button_down?(Gosu::GP_UP)      || Gosu.button_down?(Gosu::KB_W)
        @player.brake      if Gosu.button_down?(Gosu::KB_DOWN)  || Gosu.button_down?(Gosu::GP_DOWN)    || Gosu.button_down?(Gosu::KB_S)
        @player.reverse    if Gosu.button_down?(Gosu::KB_X)
        if Gosu.button_down?(Gosu::KB_TAB) && key_id_lock(Gosu::KB_TAB)
          @pointer.toggle_ground_or_air
        end

        if Gosu.button_down?(Gosu::KB_A) || Gosu.button_down?(Gosu::KB_LEFT)  || Gosu.button_down?(Gosu::GP_LEFT)
          @player.rotate_counterclockwise
        end

        if Gosu.button_down?(Gosu::KB_D)
          @player.rotate_clockwise
        end

        if !@block_all_controls
          if Gosu.button_down?(Gosu::MS_RIGHT)
            @player.attack_group_3(@pointer).each do |results|
              # puts "RESULTS HERE: #{}"
              results[:projectiles].each do |projectile|
                @projectiles[projectile.id] = projectile if projectile
              end
              results[:destructable_projectiles].each do |projectile|
                # @destructable_projectiles.push(projectile) if projectile
                @destructable_projectiles[projectile.id] = projectile if projectile
              end
              results[:graphical_effects].each do |effect|
                @graphical_effects.push(effect) if effect
              end
            end
          end

          if Gosu.button_down?(Gosu::MS_LEFT)
            @player.attack_group_2(@pointer).each do |results|
              results[:projectiles].each do |projectile|
                # @projectiles.push(projectile) if projectile
                @projectiles[projectile.id] = projectile if projectile
              end
              results[:destructable_projectiles].each do |projectile|
                # @destructable_projectiles.push(projectile) if projectile
                @destructable_projectiles[projectile.id] = projectile if projectile
              end
              results[:graphical_effects].each do |effect|
                @graphical_effects.push(effect) if effect
              end
            end
          end

          if Gosu.button_down?(Gosu::KB_SPACE)
            @player.attack_group_1(@pointer).each do |results|
              results[:projectiles].each do |projectile|
                # @projectiles.push(projectile) if projectile
                @projectiles[projectile.id] = projectile if projectile
              end
              results[:destructable_projectiles].each do |projectile|
                # @destructable_projectiles.push(projectile) if projectile
                @destructable_projectiles[projectile.id] = projectile if projectile
              end
              results[:graphical_effects].each do |effect|
                @graphical_effects.push(effect) if projectile
              end

            end
          end
        end

      end
      if !@game_pause && !menus_active && !@menu_open && !@menu.active
        @shipwreck_update_manager.update(self, @shipwrecks, nil, nil, @player.current_map_pixel_x, @player.current_map_pixel_y)
      end
    end
    return @exit_map
  end

  def draw
    @open_gl_executer.draw(@window, @gl_background, @player, @pointer, @buildings, @pickups) if @graphics_setting == :advanced
    @gl_background.draw(@player, player.current_map_pixel_x, player.current_map_pixel_y, @buildings, @pickups)


    @mini_map.draw if @show_minimap

    @pointer.draw
    @menu.draw
    @exit_map_menu.draw
    @ship_loadout_menu.draw
    @footer_bar.draw

    @player.draw(@viewable_pixel_offset_x, @viewable_pixel_offset_y) if @player.is_alive && !@ship_loadout_menu.active
    # if !menus_active && !@player.is_alive
      # @font.draw("You are dead!", @width / 2 - 50, @height / 2 - 55, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      # @font.draw("Press ESC to quit", @width / 2 - 50, @height / 2 - 40, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      # @font.draw("Press M to Restart", @width / 2 - 50, @height / 2 - 25, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    # end
    @font.draw("Paused", @width / 2 - 50, @height / 2 - 25, ZOrder::UI, 1.0, 1.0, 0xff_ffff00) if @game_pause
    @ships.each { |key, ship| ship.draw(@viewable_pixel_offset_x, @viewable_pixel_offset_y) }
    @shipwrecks.each { |ship_id, ship| ship.draw(@viewable_pixel_offset_x, @viewable_pixel_offset_y) }
    @projectiles.each { |key, projectile| projectile.draw(@viewable_pixel_offset_x, @viewable_pixel_offset_y) }
    @destructable_projectiles.each { |key, projectile| projectile.draw(@viewable_pixel_offset_x, @viewable_pixel_offset_y) }
    @buildings.each { |building_id, building| building.draw(@viewable_pixel_offset_x, @viewable_pixel_offset_y) }
    @messages.each_with_index do |message, index|
      message.draw(index)
    end
    @graphical_effects.each { |effect| effect.draw(@viewable_pixel_offset_x, @viewable_pixel_offset_y) }

    # @font.draw("Faction Relations:", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    # @factions.each do |faction|
    #   @font.draw("#{faction.id.upcase}: #{faction.display_factional_relation(@player.get_faction_id)}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    # end
    # @font.draw("projectiles count: #{@projectiles.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    if false &&@debug
      @font.draw("G-Effect: #{@graphical_effects.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Health: #{@player.health}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("STEAM: #{@player.ship.current_steam_capacity}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Ship count: #{@ships.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("projectiles count: #{@projectiles.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("destructable_proj: #{@destructable_projectiles.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("buildings count: #{@buildings.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Momentum: #{@player.ship.current_momentum.to_i}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("----------------------", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)

      @font.draw("Active Quests", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @quest_data.each do |quest_key, values|
        next if values["map_name"] != @gl_background.map_name
        if values['state'] == 'active'
          @font.draw("- #{quest_key}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
        end
      end
      @font.draw("Completed Quests", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @quest_data.each do |quest_key, values|
        next if values["map_name"] != @gl_background.map_name
        if values['state'] == 'complete'
          @font.draw("- #{quest_key}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
        end
      end

      if @effects.any?
        @font.draw("----------------------", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
        @font.draw("Effect: #{@effects.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      end

    end
    reset_font_ui_y
  end

  def get_font_ui_y
    return_value = @ui_y
    @ui_y += 15 
    return return_value
  end
  def reset_font_ui_y
    @ui_y = 10
  end


end