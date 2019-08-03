require_relative '../general_object.rb'
# require_relative 'rocket_launcher_pickup.rb'
require 'gosu'

# require 'opengl'
require 'glut'


# include OpenGL
# include GLUT

module PilotableShips
  class PilotableShip < GeneralObject
    RARITY_MAX   = 100
    ITEM_MEDIA_DIRECTORY = "#{MEDIA_DIRECTORY}/pilotable_ships/basic_ship"
    SPEED = 1
    ROTATION_SPEED = 1
    MAX_ATTACK_SPEED = 3.0

    IMAGE_SCALER = 5.0
    ABSTRACT_CLASS = true

    SLOT_TYPE = :ship

    ALLOWED_ARMOR_TYPES = [:basic_armor, :light_armor]

    attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive
    attr_reader :max_health

    attr_accessor :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
    attr_accessor :special_attack, :main_weapon, :drawable_items_near_self
    attr_accessor :hardpoints
    # attr_reader :rotation_speed
    # attr_reader :steam_max_capacity, :steam_rate_increase, :current_steam_capacity
    # attr_reader :mass, :boost_speed, :speed, :speed_steam_usage, :boost_speed_steam_usage
    # attr_reader :boost_mass
    attr_reader :steam_max_capacity

    attr_reader :current_steam_capacity, :tiles_per_second

    attr_accessor :current_momentum

    attr_reader :top_right_point, :top_left_point, :bottom_right_point, :bottom_left_point

      # @speed             = ((self.class::SPEED * @average_scale) + (acceleration_boost  * @average_scale)) / 3.0
      # @speed_steam_usage = @engine_steam_usage_increment
      # @boost_speed       = ((self.class::SPEED * @average_scale) + ((acceleration_boost * boost_speed_modifier)  * @average_scale)) / 3.0
      # @boost_speed_steam_usage = @engine_steam_usage_increment + @boost_steam_usage


    # MAX_HEALTH = 200
    # INIT_HEALTH = 200

    # FRONT_HARDPOINT_LOCATIONS = []
    # PORT_HARDPOINT_LOCATIONS = []
    # STARBOARD_HARDPOINT_LOCATIONS = []

    CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
    CONFIG_FILE = "#{CURRENT_DIRECTORY}/../../config.txt"
    attr_accessor :angle

    def self.get_hardpoint_data ship_index_string = ConfigSetting.get_setting(CURRENT_SAVE_FILE, "current_ship_index")
      hardpoint_data = ConfigSetting.get_mapped_setting(CURRENT_SAVE_FILE, ["player_fleet", ship_index_string, "hardpoint_locations"])
      return {hardpoint_data: hardpoint_data}
    end

    def self.display_name
      name.split("::").last
      # raise "PilotableShip1 override this interface method"
    end

    def self.get_hardpoint_image
      raise "PilotableShip2 OVERRIDE ME"
    end

    def self.description
      raise "PilotableShip3 OVERRIDE ME"
    end

    def self.value
      raise "PilotableShip4 OVERRIDE ME"
    end
    
    # BasicShip.new(width_scale, height_scale, screen_pixel_width, screen_pixel_height, options)
    def initialize(x, y, z, hardpoint_z, hardpoint_z_base, angle, owner, options = {})

      @always_show = options[:always_show] || false
      # puts "SHIP OWNER HERE"
      # puts owner.inspect
      # puts owner.class
      # puts "NEW OWNER CLASS: #{owner.class.name}"
      # puts owner.class
      # puts owner && owner.class.const_defined?(IS_A_FACTIONABLE)
      @owner_faction = owner.get_faction if owner.class.const_defined?(:IS_A_FACTIONABLE) && owner.class::IS_A_FACTIONABLE == true
      @faction_z = owner.class == Player ? ZOrder::FactionEmblem : ZOrder::AIFactionEmblem
      # puts "#{owner.class} GOT FACTION"
      # puts @owner_faction
      # @owner_class = owner.class

      # validate_array([], self.class.name, __callee__)
      # validate_string([], self.class.name, __callee__)
      # validate_float([], self.class.name, __callee__)
      # validate_int([], self.class.name, __callee__)
      if @debug
        # validate_not_nil([x, y, angle], self.class.name, __callee__)
        validate_not_nil([angle], self.class.name, __callee__)
      end

      # validate_int([x, y, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, angle], self.class.name, __callee__)
      # validate_float([width_scale, height_scale], self.class.name, __callee__)
      # validate_not_nil([x, y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height], self.class.name, __callee__)


      @x = x
      @y = y
      @z = z
      # @z_base = hardpoint_z_base
      # puts "ShIP THOUGHT THAT THIS WAS CONFIG_FILE: #{self.class::CONFIG_FILE}"
      @angle = angle
      media_path = self.class::ITEM_MEDIA_DIRECTORY
      path = media_path
      # @right_image = self.class.get_right_image(path)
      # @left_image = self.class.get_left_image(path)
      # @right_broadside_image = self.class.get_right_broadside_image(path)
      # @left_broadside_image = self.class.get_left_broadside_image(path)
      disable_hardpoint_angles = false
      if options[:use_large_image]
        @use_large_image = true
        disable_hardpoint_angles = true
        @image = self.class.get_large_image(path)
      else
        @image = self.class.get_image(path)
      end
      options[:image] = @image
    # def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height, options = {})
      super(options)
      # Top of screen
      # @min_moveable_height = options[:min_moveable_height] || 0
      # Bottom of the screen
      # @max_movable_height = options[:max_movable_height] || screen_pixel_height
      @score = 0
      @cooldown_wait = 0
      @secondary_cooldown_wait = 0
      @grapple_hook_cooldown_wait = 0
      @attack_speed = 3
      # @attack_speed = 3
      # if @debug
      #   @health = INIT_HEALTH * 10000
      # else
      @health     = options[:health] || self.class::HEALTH
      @max_health = self.class::HEALTH
      # end
      @armor = 0
      @rockets = 50
      # @rockets = 250
      @bombs = 3
      # @secondary_weapon = RocketLauncherPickup::NAME

      # @hard_point_items = [RocketLauncherPickup::NAME, 'cannon_launcher', 'cannon_launcher', 'bomb_launcher']
      @rocket_launchers = 0
      @bomb_launchers   = 0
      @cannon_launchers = 0
      # trigger_hard_point_load
      @damage_reduction = options[:handicap] ? options[:handicap] : 1
      invert_handicap = 1 - @damage_reduction
      @boost_increase = invert_handicap > 0 ? 1 + (invert_handicap * 1.25) : 1
      @damage_increase = invert_handicap > 0 ? 1 + (invert_handicap) : 1
      @kill_count = 0
      @main_weapon = nil
      @drawable_items_near_self = []

      @hide_hardpoints = options[:hide_hardpoints] || false

      # Load hardpoints from CONFIG FILE HERE, plug in launcher class !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      # get_config_save_settings = [self.class.name]

      # # ConfigSetting.set_mapped_setting(self.class::CONFIG_FILE, [BasicShip, 'front_hardpoint_locations', 1], 'launcher')
      # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '1'], 'launcher')
      # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '2'], 'launcher')
      # ConfigSetting.set_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '3'], 'launcher')
      # ConfigSetting.get_mapped_setting(PilotableShip::CONFIG_FILE, ['BasicShip', 'front_hardpoint_locations', '1'])

      # Update hardpoints location
      @armor_hardpoints      = {}
      @engine_hardpoints     = {}
      @steam_core_hardpoints = []
      @hardpoints = Array.new(self.class::HARDPOINT_LOCATIONS.length) {nil}
      # puts "self.class::HARDPOINT_LOCATIONS"
      # puts self.class::HARDPOINT_LOCATIONS.inspect
      self.class::HARDPOINT_LOCATIONS.each_with_index do |location, index|
        # puts "LOCATION DATA: #{location.inspect}"
        location_dup = location.dup
        item_klass_string = options[:hardpoint_data] ? options[:hardpoint_data][index.to_s] : nil

        found_errors = false
        begin
          item_klass = item_klass_string && item_klass_string != '' ? eval(item_klass_string) : nil
        rescue NameError, SyntaxError, NoMethodError => e
          found_errors = true
         # puts "ISSUE: #{e.class}"
          # puts e.backtrace
         # puts "ISSUE WITH: #{item_klass_string}"
         # puts "RAW DATA: #{options}"
        end
        raise "Finishing w/ errors" if found_errors

        raise "bad slot type" if location_dup[:slot_type].nil?
        raise "bad anlge"     if location_dup[:angle_offset].nil?


        # puts "INITING HARDPOINT CLASS: #{item_klass}"
        # puts "ANGLE OFFSET HERE: #{location_dup[:angle_offset]}"

        if [:engine, :generic].include?(location_dup[:slot_type]) && !item_klass.nil? && item_klass::SLOT_TYPE == :engine
          @engine_hardpoints[index] = item_klass
        end
        # puts "@engine_hardpoints.count; #{@engine_hardpoints.count}"



        # ADD BACK IN
        # HardpointObjects::SteamCoreHardpoint
        if [:steam_core].include?(location_dup[:slot_type]) && !item_klass.nil? && item_klass::SLOT_TYPE == :steam_core
          # puts "FOUND SCREAM CORE HERE: #{location_dup[:slot_type]} - #{item_klass::SLOT_TYPE}"
          @steam_core_hardpoints << item_klass
        end

        if [:armor].include?(location_dup[:slot_type]) && !item_klass.nil? && item_klass::SLOT_TYPE == :armor
          # puts 'ADIDNG ITEM KLASS HERE: ' 
          # puts item_klass.inspect
          # puts item_klass.to_s
          # puts "item_klass::SLOT_TYPE: #{item_klass::SLOT_TYPE}"
          @armor_hardpoints[index] = item_klass
        end

        # Always point engines toward the rear
        # if (location_dup[:slot_type] == :engine || location_dup[:slot_type] == :generic) && !item_klass.nil? &&  item_klass::SLOT_TYPE == :engine
        #   location_dup[:angle_offset] = 180
        # end

        if !item_klass.nil? && !item_klass::OVERRIDING_HARDPOINT_ANGLE.nil?
          location_dup[:angle_offset] = item_klass::OVERRIDING_HARDPOINT_ANGLE
        end

        # puts "ITEM CLASS " if owner.class == Player
       # puts "@engine_hardpoints.count: #{@engine_hardpoints.count}" if owner.class == Player
        options[:block_initial_angle] = true if disable_hardpoint_angles
        if location_dup[:slot_type] == :engine && item_klass && item_klass::SLOT_TYPE == :engine
          h_z  = hardpoint_z_base
          hb_z = nil
        else
          h_z  = hardpoint_z
          hb_z = hardpoint_z_base
        end
        if owner.class == Player
          z_projectile = ZOrder::PlayerProjectile
          if location_dup[:slot_type] == :armor && item_klass && item_klass::SLOT_TYPE == :armor
            hb_z = ZOrder::PlayerShipArmor
          end
        else
          z_projectile = ZOrder::AIProjectile
          if location_dup[:slot_type] == :armor && item_klass && item_klass::SLOT_TYPE == :armor
            hb_z = ZOrder::AIShipArmor
          end
        end
        
        # raise "Missing hb_z" if hb_z.nil?
        hp = Hardpoint.new(
          x, y, h_z, hb_z, location_dup[:x_offset].call(get_image, @height_scale_with_image_scaler),
          location_dup[:y_offset].call(get_image, @height_scale_with_image_scaler), item_klass, location_dup[:slot_type], @angle, location_dup[:angle_offset], owner, self, z_projectile, options
        )
        @hardpoints[index] = hp
      end

      # puts "@steam_core_hardpoints.count: #{@steam_core_hardpoints.count}"


      steam_max_capacity = 0.0
      steam_rate_increase = 0.0
      @steam_core_hardpoints.each do |steam_core_klass|
        steam_max_capacity    += steam_core_klass::STEAM_MAX_CAPACITY
        steam_rate_increase   += steam_core_klass::STEAM_RATE_INCREASE
      end
      @steam_original_max_capacity = steam_max_capacity
      @steam_max_capacity          = steam_max_capacity
      @steam_rate_increase         = steam_rate_increase
      @current_steam_capacity      = @steam_max_capacity

      # puts "STEAM POWER STATS:"
      # puts [@steam_original_max_capacity, @steam_max_capacity, @steam_rate_increase, @current_steam_capacity]

      engine_permanent_steam_usage     = 0.0
      engine_tiles_per_second_modifier = 1.0
      engine_rotation_modifier         = 1.0
      @engine_hardpoints.reject! do |index, klass|
        if (@current_steam_capacity - klass::PERMANENT_STEAM_USE) >= 0
          engine_permanent_steam_usage += klass::PERMANENT_STEAM_USE
          engine_rotation_modifier     = engine_rotation_modifier * klass::ROTATION_MODIFIER
          engine_tiles_per_second_modifier = engine_tiles_per_second_modifier * klass::TILES_PER_SECOND_MODIFIER
          @current_steam_capacity -= klass::PERMANENT_STEAM_USE
          false
        else
          # puts "NOT COUNTING ENGINE"
          @hardpoints[index].disable
          true
        end
      end
      # puts @armor_hardpoints.inspect
      @armor_damage_reduce = 1
      @armor_hardpoints.reject! do |index, klass|
        # puts "kalss: #{klass}"
        if (@current_steam_capacity - klass::PERMANENT_STEAM_USE) >= 0
          @armor_damage_reduce = @armor_damage_reduce * klass::DAMAGE_REDUCTION
          engine_permanent_steam_usage += klass::PERMANENT_STEAM_USE
          engine_rotation_modifier     = engine_rotation_modifier * klass::ROTATION_MODIFIER
          engine_tiles_per_second_modifier = engine_tiles_per_second_modifier * klass::TILES_PER_SECOND_MODIFIER
          @current_steam_capacity -= klass::PERMANENT_STEAM_USE
          false
        else
          # puts "NOT COUNTING ENGINE"
          @hardpoints[index].disable
          true
        end
      end


      @current_steam_capacity = 0


      @engine_permanent_steam_usage     = engine_permanent_steam_usage
      @engine_tiles_per_second_modifier = engine_tiles_per_second_modifier
      @engine_rotation_modifier         = engine_rotation_modifier

      options.delete(:hardpoint_data)



      @hardpoints.each_with_index do |hp, hp_index|
        hp.disable if hp.item && (!hp.has_valid_slot_type? || !hp.has_valid_slot_instance?(self.class))
      end

      @theta = nil


      @mass             = self.class::MASS
      @half_mass        = self.class::MASS / 2.0
      @momentum_rate    = self.class::MOMENTUM_RATE
      @current_momentum = options[:current_momentum] || 0

      if @engine_hardpoints.count > 0
        @tiles_per_second = (self.class::TILES_PER_SECOND * @engine_tiles_per_second_modifier) * @height_scale
        @rotation_speed    = self.class::ROTATION_SPEED * @engine_rotation_modifier #+ rotation_boost
      else
        @rotation_speed    = self.class::ROTATION_SPEED #+ rotation_boost
        @tiles_per_second = (self.class::TILES_PER_SECOND / 10.0) * @height_scale
      end

      @block_momentum_increase = false
      @block_momentum_decrease = false

      # @polygon_points = {}
      if !options[:block_initial_angle]
        @polygon_points     = []
        @center_point       = OpenStruct.new(:x => owner.current_map_pixel_x, :y => owner.current_map_pixel_y)
        # puts ":@image_width_half: #{@image_width_half} - #{@image_height_half}"
        @top_right_point    = OpenStruct.new(:x => owner.current_map_pixel_x + @image_width_half, :y => owner.current_map_pixel_y - @image_height_half)
        @top_right_angle    = self.class.angle_1to360(calc_angle(@center_point, @top_right_point) - 90)

        @top_left_point     = OpenStruct.new(:x => owner.current_map_pixel_x - @image_width_half, :y => owner.current_map_pixel_y - @image_height_half)
        @top_left_angle     = self.class.angle_1to360(calc_angle(@center_point, @top_left_point) - 90)

        @bottom_right_point = OpenStruct.new(:x => owner.current_map_pixel_x + @image_width_half, :y => owner.current_map_pixel_y + @image_height_half)
        @bottom_right_angle = self.class.angle_1to360(calc_angle(@center_point, @bottom_right_point) - 90)

        @bottom_left_point  = OpenStruct.new(:x => owner.current_map_pixel_x - @image_width_half, :y => owner.current_map_pixel_y + @image_height_half)
        @bottom_left_angle  = self.class.angle_1to360(calc_angle(@center_point, @bottom_left_point) - 90)

        # Radius should be the same for all points, it's just angles rectangles.
        @object_polygon_radius = Gosu.distance(owner.current_map_pixel_x, owner.current_map_pixel_y, owner.current_map_pixel_x + @image_width_half, owner.current_map_pixel_y + @image_height_half)
        # @object_polygon_radius = @object_polygon_radius * 0.9
      end
    end

    # is_point_inside_polygon

    def update_current_map_pixel_coords owner_map_pixel_x, owner_map_pixel_y
      # step = (Math::PI/180 * (360 -  @angle_from_center + @angle + 90)) + 90.0 + 45.0
      # point_map_pixel_x = Math.cos(step) * @object_polygon_radius + owner_map_pixel_x
      # point_map_pixel_y = Math.sin(step) * @object_polygon_radius + owner_map_pixel_y
      angle_correction = 5

      step = (Math::PI/180 * (360 -  @top_right_angle + @angle + 90 + angle_correction)) + 90.0 + 45.0
      point_map_pixel_x = Math.cos(step) * @object_polygon_radius + owner_map_pixel_x
      point_map_pixel_y = Math.sin(step) * @object_polygon_radius + owner_map_pixel_y
      @top_right_point    = OpenStruct.new(:x => point_map_pixel_x, :y => point_map_pixel_y)

      step = (Math::PI/180 * (360 -  @top_left_angle + @angle + 90 + angle_correction)) + 90.0 + 45.0
      point_map_pixel_x = Math.cos(step) * @object_polygon_radius + owner_map_pixel_x
      point_map_pixel_y = Math.sin(step) * @object_polygon_radius + owner_map_pixel_y
      @top_left_point    = OpenStruct.new(:x => point_map_pixel_x, :y => point_map_pixel_y)

      step = (Math::PI/180 * (360 -  @bottom_right_angle + @angle + 90 + angle_correction)) + 90.0 + 45.0
      point_map_pixel_x = Math.cos(step) * @object_polygon_radius + owner_map_pixel_x
      point_map_pixel_y = Math.sin(step) * @object_polygon_radius + owner_map_pixel_y
      @bottom_right_point    = OpenStruct.new(:x => point_map_pixel_x, :y => point_map_pixel_y)

      step = (Math::PI/180 * (360 -  @bottom_left_angle + @angle + 90 + angle_correction)) + 90.0 + 45.0
      point_map_pixel_x = Math.cos(step) * @object_polygon_radius + owner_map_pixel_x
      point_map_pixel_y = Math.sin(step) * @object_polygon_radius + owner_map_pixel_y
      @bottom_left_point    = OpenStruct.new(:x => point_map_pixel_x, :y => point_map_pixel_y)
    end

    def get_map_pixel_polygon_points
      [@top_right_point, @top_left_point, @bottom_right_point, @bottom_left_point]
    end

    def hit_objects owner, object_groups#, options)
      # puts "OWHNER: #{@owner.class}"
      # return if @owner.nil?
      hit_object = false
      # graphical_effects = []
      # is_thread = options[:is_thread] || false
      collided_object = nil
      if @health > 0
        object_groups.each do |group|
          break if hit_object
          group.each do |object_id, object|
            break if hit_object
            next if owner.id == object.id
            next if !object.is_alive
            # puts "OBJECTCLASS: #{object.class.name} against #{owner.class.name}"
            # puts "OBJECT.CLASS: #{object.class.name} - #{object.current_map_pixel_x} - #{object.current_map_pixel_y}"
            # puts "#{self.class.name} - #{@current_map_pixel_x} - #{owner.current_map_pixel_y}"
            hit_object = Gosu.distance(owner.current_map_pixel_x, owner.current_map_pixel_y, object.current_map_pixel_x, object.current_map_pixel_y) < (self.get_radius + object.get_radius) / 2.0
            collided_object = object if hit_object
            # puts "I, #{self.owner.class}, collided_object.class: #{collided_object.class} - radius where: #{self.get_radius} and #{object.get_radius}" if hit_object
            # puts "#{owner.id} HIT #{object.id}" if hit_object
            # puts "#{owner.id.class} HIT #{object.id.class}" if hit_object
          end
        end
      end


      if hit_object
        # puts "HIT OBJECT FROM PILOTABLE SHIP"
        end_point = OpenStruct.new(:x => owner.current_map_pixel_x,     :y => owner.current_map_pixel_y)
        start_point   = OpenStruct.new(:x => collided_object.current_map_pixel_x, :y => collided_object.current_map_pixel_y)
        destination_angle = GeneralObject.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
        # speed1 = @tiles_per_second * (@current_momentum / (@mass))
        speed1 = @tiles_per_second * (@mass / 100.0)
        # speed2 = collided_object.ship.tiles_per_second * (collided_object.ship.current_momentum / (collided_object.ship.mass))
        speed2 = collided_object.ship.tiles_per_second * (collided_object.ship.mass / 100.0)
        speed = (speed1 + speed2) / 2.0
        ignore1, ignore2, halt = owner.movement(speed, destination_angle)
        # @current_momentum = 0
       
        owner.brake(30)
        ignore1, ignore2, halt = collided_object.movement(speed, destination_angle - 180)
        collided_object.take_damage((@mass / 100), owner)
        owner.take_damage((collided_object.ship.mass / 100), collided_object)
        collided_object.brake(30)
        # collided_object.ship.current_momentum = 0
        # start_point = OpenStruct.new(:x => @attached_target.current_map_pixel_x,     :y => @attached_target.current_map_pixel_y)
        # end_point   = OpenStruct.new(:x => returning_to_object.current_map_pixel_x, :y => returning_to_object.current_map_pixel_y)
        # angle_to_origin = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
        # # Reversing direction
        # # angle_to_origin = self.class.angle_1to360(angle_to_origin - 180)
        # @attached_target.movement(@pull_strength, angle_to_origin)
        # @owner.movement(@pull_strength, angle_to_origin + 180)

      end

    end

    def rotation_speed
      # puts "ROTATION SPEED:"
      # puts "#{@rotation_speed * (1 - ((@current_momentum / 100.0) / 2.0 ))} = #{@rotation_speed} * 1 - (#{@current_momentum} / 100.0) / 2"
      # ROTATION SPEED:
      # -0.4780000000000078 = 0.45 * 1 - (92.80000000000078 / 100.0)
      @rotation_speed * (1 - ((@current_momentum / 100.0) / 2.0 ))
    end

    def accelerate rate = 1
      if @current_momentum <= @mass && !@block_momentum_increase
        # puts "case 1 : #{@momentum_rate} - #{rate}"
        @current_momentum += @momentum_rate * rate * @fps_scaler
        @current_momentum = @mass if @current_momentum > @mass
      end
    end

    def reverse rate = 1
      if @current_momentum >= -@half_mass && !@block_momentum_decrease
        @current_momentum -= @momentum_rate * rate * @fps_scaler
        @current_momentum = -@half_mass if @current_momentum < -@half_mass
      end
    end

    def brake rate = 1
      if @current_momentum > 0
        reverse(rate)
        if @current_momentum < 0
          @current_momentum = 0
        end
      elsif @current_momentum < 0
        accelerate(rate)
        if @current_momentum > 0
          @current_momentum = 0
        end
      end
      return true
    end

    def use_steam usage
      if usage < @current_steam_capacity
        @current_steam_capacity -= usage
        return true
      else
        return false
      end
    end

    def add_hard_point hard_point
    #   @hard_point_items << hard_point
    #   trigger_hard_point_load
    end

    def self.get_image_assets_path
      ITEM_MEDIA_DIRECTORY
    end

    # def self.get_right_broadside_image path
    #   Gosu::Image.new("#{path}/right_broadside.png")
    # end
    # def self.get_left_broadside_image path
    #   Gosu::Image.new("#{path}/left_broadside.png")
    # end
    def get_image
      @image
    end
    def self.get_image path
      Gosu::Image.new("#{path}/default.png")
    end

    def self.get_tilable_image path
      Gosu::Image.new("#{path}/default.png", :tileable => true)
    end

    def self.get_destroyed_image path
      Gosu::Image.new("#{path}/destroyed_default.png")
    end

    def self.get_large_image path
      Gosu::Image.new("#{path}/large.png")
    end

    # these should be get_init_*
    def self.get_mass
      self.class::MASS
    end
    def self.get_speed
      self.class::SPEED
    end

    # def get_armor
    #   self.class::ARMOR
    # end
    # def get_health
      # @health
    # end

    # def self.get_right_image path
    #   Gosu::Image.new("#{path}/right.png")
    # end
    
    # def self.get_left_image path
    #   Gosu::Image.new("#{path}/left.png")
    # end
    def self.get_image_path path
      "#{path}/default.png"
    end

    def get_image
      # puts "GET IMAGE"
      # if @right_broadside_mode
      #   return @right_broadside_image
      # elsif @left_broadside_mode
      #   return @left_broadside_image
      # else
        # puts "DEFAULT"
        # puts @image
        return @image
      # end
    end
    
    def get_image_path path
      "#{path}/default.png"
    end

    def take_damage damage
      @health -= damage * @damage_reduction * @armor_damage_reduce
    end


    def decrement_secondary_ammo_count count = 1
      # return case @secondary_weapon
      # when 'bomb'
      #   self.bombs -= count
      # else
      #   self.rockets -= count
      # end
    end

    def get_secondary_name
      # return case @secondary_weapon
      # when 'bomb'
      #   'Bomb'
      # else
      #   'Rocket'
      # end
    end

    def get_x
      @x
    end
    def get_y
      @y
    end

    def is_alive
      health > 0
    end

    NON_ATTACK_HARDPOINT_SLOTS = [:engine]

    def attack_group initial_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer_or_target, group, options = {}
      results = []
      @hardpoints.each do |hp|
        next if NON_ATTACK_HARDPOINT_SLOTS.include?(hp.slot_type)
        results << hp.attack(initial_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer_or_target, options) if hp.group_number == group && hp.item
      end
      # results = results.flatten
      results.reject!{|v| v.nil?}
      return results
    end

    def deactivate_group group_number
      # puts "deactivate_group: #{group_number}"
      @hardpoints.each do |hp|
        next if NON_ATTACK_HARDPOINT_SLOTS.include?(hp.slot_type)
        hp.stop_attack if hp.group_number == group_number
      end
    end

    def attack_group_1 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, options = {}
      return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 1, options)
    end

    def attack_group_2 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, options = {}
      return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 2, options)
    end

    def attack_group_3 initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, options = {}
      return attack_group(initial_angle, current_map_pixel_x, current_map_pixel_y, pointer, 3, options)
    end

    def deactivate_group_1
      deactivate_group(1)
    end

    def deactivate_group_2
      deactivate_group(2)
    end

    def deactivate_group_3
      deactivate_group(3)
    end

    def switch_to_destroyed_image path
      @image = self.class.get_destroyed_image(path)
    end

    def turn_off_hardpoints
      @hide_hardpoints = true
    end

    def draw viewable_pixel_offset_x = 0, viewable_pixel_offset_y = 0, scale_offset = 1, options = {}
      if @x && (@is_on_screen || @always_show)
        if @owner_faction
          @owner_faction.emblem.draw_rot(
            @x, @y, @faction_z,
            360 - @angle, 0.5, 0.5, @owner_faction.emblem_scaler, @owner_faction.emblem_scaler
          )
        end

        @drawable_items_near_self.reject! { |item| item.draw(viewable_pixel_offset_x, viewable_pixel_offset_y) }
        # puts "DRAWING HARDPOINTS"
        # puts "@starboard_hard_points: #{@starboard_hard_points.count}"
        if !@hide_hardpoints
          # puts "AI DRAWING HARDPOINT HERE" if options[:test]
          # puts "@front_hard_points.first x-y #{@front_hard_points.first.x} - #{@front_hard_points.first.y}" if options[:test]
          # puts "WHAT IS GOING ON HERE"
          # puts [@x, @y, @angle, viewable_pixel_offset_x, viewable_pixel_offset_y]
          @hardpoints.each { |item| item.draw(@x, @y, @angle, viewable_pixel_offset_x, viewable_pixel_offset_y) }
        end
        # puts "SHIP DRAW: #{@width_scale} - #{@height_scale} - #{scale_offset}"
                                                                                                    # SHIP DRAW: 2.6666666666666665 - 1.5 - 1
        @image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, @z, -@angle, 0.5, 0.5, @height_scale_with_image_scaler * scale_offset, @height_scale_with_image_scaler * scale_offset)
        # @image.draw_rot(@x, @y, ZOrder::Projectile, @current_image_angle, 0.5, 0.5, @height_scale, @height_scale)
      end
    end

    def draw_gl_list
      @drawable_items_near_self + [self]
    end

    def draw_gl
      raise "is this being used? maybe not"
      # # draw gl stuff
      # @drawable_items_near_self.each {|item| item.draw_gl }

      # @hardpoints.each { |item| item.draw_gl }

      # info = @image.gl_tex_info

      # # glDepthFunc(GL_GEQUAL)
      # # glEnable(GL_DEPTH_TEST)
      # # glEnable(GL_BLEND)

      # # glMatrixMode(GL_PROJECTION)
      # # glLoadIdentity
      # # perspective matrix
      # # glFrustum(-0.10, 0.10, -0.075, 0.075, 1, 100)

      # # glMatrixMode(GL_MODELVIEW)
      # # glLoadIdentity
      # # glTranslated(0, 0, -4)
    
      # z = @z
      
      # # offs_y = 1.0 * @scrolls / SCROLLS_PER_STEP
      # # offs_y = 1
      # new_width1, new_height1, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y - @image_height_half/2, @screen_pixel_width, @screen_pixel_height)
      # new_width2, new_height2, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x - @image_width_half/2, @y + @image_height_half/2, @screen_pixel_width, @screen_pixel_height)
      # new_width3, new_height3, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y - @image_height_half/2, @screen_pixel_width, @screen_pixel_height)
      # new_width4, new_height4, increment_x, increment_y = Player.convert_x_and_y_to_opengl_coords(@x + @image_width_half/2, @y + @image_height_half/2, @screen_pixel_width, @screen_pixel_height)

      # glEnable(GL_TEXTURE_2D)
      # glBindTexture(GL_TEXTURE_2D, info.tex_name)

      # glBegin(GL_TRIANGLE_STRIP)
      #   # glColor4d(1, 1, 1, get_draw_ordering)
      #   glTexCoord2d(info.left, info.top)
      #   # glVertex3f(new_width1, new_height1, z)

      #   # glColor4d(1, 1, 1, get_draw_ordering)
      #   glTexCoord2d(info.left, info.bottom)
      #   # glVertex3f(new_width2, new_height2, z)
      
      #   # glColor4d(1, 1, 1, get_draw_ordering)
      #   glTexCoord2d(info.right, info.top)
      #   # glVertex3f(new_width3, new_height3, z)

      #   # glColor4d(1, 1, 1, get_draw_ordering)
      #   glTexCoord2d(info.right, info.bottom)
      #   # glVertex3f(new_width4, new_height4, z)
      # glEnd
    end
    
    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, owner, target_map_pixel_x, target_map_pixel_y
      validate_not_nil([mouse_x, mouse_y], self.class.name, __callee__)

      update_current_map_pixel_coords(owner.current_map_pixel_x, owner.current_map_pixel_y)

      # Don't care about it alive or not, it's the owner that counts
      super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, {block_tile_from_pixel_update: true})

      # hp.attack(initial_ship_angle, current_map_pixel_x, current_map_pixel_y, pointer) 


      # puts "BEFORE MAX CAPACOTY: #{@steam_max_capacity}"
      capacity_diff = 0
      # if @current_momentum != 0 && @engine_permanent_steam_usage != 0
      if @engine_permanent_steam_usage != 0
        # If we want steam usage to be based on speed
        # @steam_max_capacity = @steam_original_max_capacity - (@engine_permanent_steam_usage * (@current_momentum.abs / (@mass)))
        @steam_max_capacity = @steam_original_max_capacity - @engine_permanent_steam_usage
        if @steam_max_capacity < 0
          # capacity_diff = 0 - @steam_max_capacity
          @steam_max_capacity = 0
          # puts "BLOCKLING INCREATE HERE!!!!"
          @block_momentum_increase = true if @current_momentum > 0
          @block_momentum_decrease = true if @current_momentum < 0
        else
          @block_momentum_increase = false
          @block_momentum_decrease = false
        end
      end
      # puts "AFTER MAX CAPACITY: #{@steam_max_capacity}"
      # @steam_max_capacity          = steam_max_capacity #- @engine_permanent_steam_usage

      # @steam_max_capacity  = steam_max_capacity
      # @steam_rate_increase = steam_rate_increase
      # @current_steam_capacity
      # puts "STARTED: #{@current_steam_capacity}"
      if @current_steam_capacity < @steam_max_capacity
        @current_steam_capacity += @steam_rate_increase
        # @steam_power = @steam_max_capacity if @current_steam_capacity > @steam_max_capacity - @engine_permanent_steam_usage
      end
      if @current_steam_capacity > @steam_max_capacity
        @current_steam_capacity = @steam_max_capacity
      end
      # puts "ENDED: #{@current_steam_capacity}"

      # Update list of weapons for special cases like beans. Could iterate though an association in the future.
      # @main_weapon.update(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y) if @main_weapon
      if !@hide_hardpoints
        @hardpoints.each do |hardpoint|
          # puts "UPDATING HARDPOINT HERE: #{self}"
          hardpoint.update(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, @angle, target_map_pixel_x, target_map_pixel_y)
        end
      end

      # @cooldown_wait -= 1              if @cooldown_wait > 0
      # @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
      # @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
      # @time_alive += 1 if self.is_alive
    end


  end
end
