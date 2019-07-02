require_relative 'screen_map_fixed_object.rb'
# require_relative 'rocket_launcher_pickup.rb'
require_relative '../lib/config_setting.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

class AIShip < ScreenMapFixedObject
  CONFIG_FILE = "#{CURRENT_DIRECTORY}/../config.txt"
  attr_accessor :grapple_hook_cooldown_wait
  attr_accessor :drawable_items_near_self
  attr_accessor :special_target_focus
  attr_reader :current_momentum
  # attr_accessor :drops
  MAX_HEALTH = 200
  AGRO_TILE_DISTANCE = 3
  PREFERRED_MIN_TILE_DISTANCE = 1
  PREFERRED_MAX_TILE_DISTANCE = 2
  FIRING_TILE_DISTANCE        = 10
  # in seconds
  # ANGRO MAX is 10 seconds
  AGRO_MAX = 10 * 60
  AGRO_DECREMENT = 1

  CLASS_TYPE = :ship

  # Just test out the tile part first.. or whatever
  def initialize(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options = {})
    validate_int([current_map_tile_x, current_map_tile_y],  self.class.name, __callee__)
    validate_float([current_map_pixel_x, current_map_pixel_y],  self.class.name, __callee__)

    options[:image] = BasicShip.get_image(BasicShip::ITEM_MEDIA_DIRECTORY)
    super(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options)

    @drops = ["HardpointObjects::BulletHardpoint", "HardpointObjects::BulletHardpoint", "HardpointObjects::BulletHardpoint"]

    @score = 0
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @grapple_hook_cooldown_wait = 0
    @angle = 90

    # hardpoint_data = Player.get_hardpoint_data('BasicShip')
    # hardpoint_data = {
    #   :hardpoint_data=>
    #   {
    #     "0" => "HardpointObjects::BulletHardpoint", "3"=>"HardpointObjects::BulletHardpoint", "1"=>"HardpointObjects::BulletHardpoint",
    #     "4"=>"HardpointObjects::BulletHardpoint", "5"=>"HardpointObjects::BulletHardpoint", "6"=>"HardpointObjects::BulletHardpoint",
    #     "2"=>"HardpointObjects::BulletHardpoint", "7"=>"HardpointObjects::BulletHardpoint", "8"=>"HardpointObjects::BasicEngineHardpoint",
    #     "10" => "HardpointObjects::AdvancedSteamCoreHardpoint"
    #   }
    # }
    hardpoint_data = {
      :hardpoint_data=>
      {
        "0" => "HardpointObjects::BulletHardpoint", "3"=>"HardpointObjects::BulletHardpoint", "1"=>"HardpointObjects::GrapplingHookHardpoint",
        "4"=>"HardpointObjects::DumbMissileHardpoint", "5"=>"HardpointObjects::DumbMissileHardpoint", "6"=>"HardpointObjects::DumbMissileHardpoint",
        "2"=>"HardpointObjects::BulletHardpoint", "7"=>"HardpointObjects::BulletHardpoint", "8"=>"HardpointObjects::BasicEngineHardpoint",
        "10" => "HardpointObjects::AdvancedSteamCoreHardpoint"
      }
    }
    # hardpoint_data = {
    #   :hardpoint_data=>
    #   {
    #     "0" => "HardpointObjects::GrapplingHookHardpoint", "3"=>"HardpointObjects::GrapplingHookHardpoint", "1"=>"HardpointObjects::GrapplingHookHardpoint",
    #     "4"=>"HardpointObjects::GrapplingHookHardpoint", "5"=>"HardpointObjects::GrapplingHookHardpoint", "6"=>"HardpointObjects::GrapplingHookHardpoint",
    #     "2"=>"HardpointObjects::GrapplingHookHardpoint", "7"=>"HardpointObjects::GrapplingHookHardpoint", "8"=>"HardpointObjects::BasicEngineHardpoint",
    #     "10" => "HardpointObjects::AdvancedSteamCoreHardpoint"
    #   }
    # }


    # hardpoint_data = {
    #   :hardpoint_data =>
    #   {
    #     "0": "HardpointObjects::GrapplingHookHardpoint",
    #     "1": "HardpointObjects::GrapplingHookHardpoint",
    #     "4": "HardpointObjects::DumbMissileHardpoint",
    #     "3": "HardpointObjects::DumbMissileHardpoint",
    #     "5": "HardpointObjects::MinigunHardpoint",
    #     "2": "HardpointObjects::DumbMissileHardpoint",
    #     "10": "HardpointObjects::AdvancedSteamCoreHardpoint",
    #     "7": "HardpointObjects::MinigunHardpoint",
    #     "6": "HardpointObjects::MinigunHardpoint",
    #     "8": "HardpointObjects::BasicEngineHardpoint",
    #     "9": "HardpointObjects::BasicEngineHardpoint"
    #   }
    # }

    @ship = BasicShip.new(@x, @y, get_draw_ordering, ZOrder::AIHardpoint, ZOrder::AIHardpointBase, @angle, self, hardpoint_data)
    @ship.x = @x
    @ship.y = @y
    @current_momentum = 0
    # @max_momentum = @ship.mass # speed here?

    if @debug
      @rotation_speed = 1.0
    else

      @rotation_speed = 2.0
    end

    @health = @ship.get_health
    # @armor = @ship.get_armor

    # 0 is north
    # Angle the broadsides at the target
    @firing_angle_preferences = [[240.0,300.0], [60.0,120.0]]
    # Find angle preference range here..
    # override default
    # Maybe implement calculations in the future here, to get most of hardpoint damage
    @ship.hardpoints.each do |hp|
      # hp.inspect
    end

    @distance_preference_max = PREFERRED_MAX_TILE_DISTANCE * @average_tile_size
    # Don't want to get boarded also
    @distance_preference_min = PREFERRED_MIN_TILE_DISTANCE * @average_tile_size

    @firing_distance = FIRING_TILE_DISTANCE * @average_tile_size

    @agro_map_pixel_distance = AGRO_TILE_DISTANCE * @average_tile_size
    @argo_target_map = {}
    @special_target_focus_id = options[:special_target_focus_id] if options[:special_target_focus_id]
    # @special_target_focus_type = options[:special_target_focus_type] if options[:special_target_focus_type]
    @special_target_focus = nil
    # stop
  end

  def get_speed
    return @ship.speed
  end
  
  def rotate_counterclockwise
    # puts "ROTATING COUNTER AI"
    increment = @rotation_speed
    if @angle + increment >= 360
      @angle = (@angle + increment) - 360
    else
      @angle += increment
    end
    @ship.angle = @angle
    # @ship.rotate_hardpoints_counterclockwise(increment.to_f)
    return 1
  end

  def rotate_clockwise
    # puts "ROTATING AI"
    increment = @rotation_speed
    if @angle - increment <= 0
      @angle = (@angle - increment) + 360
    else
      @angle -= increment
    end
    @ship.angle = @angle
    # @ship.rotate_hardpoints_clockwise(increment.to_f)
    return 1
  end

  def take_damage damage
    if @debug
      @ship.take_damage(damage * 6.0)
    else
      @ship.take_damage(damage)
    end
    # @health -= damage * @damage_reduction
  end

  def is_alive
    if @ship.is_alive
      return true
    else

      if rand(2) == 0
        file = "ship_dead_2.ogg"
      else
        file = "ship_dead_1.ogg"
      end


      sound = Gosu::Sample.new("#{SOUND_DIRECTORY}/#{file}")
      sound.play(@effects_volume, 1, false) 
      return false
    end
  end

  def use_steam usage
    return @ship.use_steam(usage)
  end

  def update_momentum
    if @current_momentum > 0.0
      speed = (@ship.mass / 10.0) * (@current_momentum / 10.0) / 90.0
      # puts "PLAYER UPDATE HERE - momentum ANGLE: #{@angle}"
      x_diff, y_diff, halt = self.movement(speed, @angle)
      if halt
        @current_momentum = 0
      else
        @current_momentum -= 1
        @current_momentum = 0 if @current_momentum < 0
      end
    elsif @current_momentum < 0.0
      speed = (@ship.mass / 10.0) * (@current_momentum / 10.0) / 90.0
      garbage1, garbage2, halt = self.movement(-speed, @angle + 180)
      if halt
        @current_momentum = 0
      else
        @current_momentum += 1
        @current_momentum = 0 if @current_momentum > 0
      end
    end
  end

  def accelerate
   # puts "AI ACCELLERATE: #{@ship.current_momentum} - current_steam: #{@ship.current_steam_capacity}"
    @ship.accelerate
  end
  def brake
    @ship.brake
  end
  def reverse
    @ship.reverse
  end

  def get_draw_ordering
    ZOrder::AIShip
  end

  def draw viewable_pixel_offset_x, viewable_pixel_offset_y
    # puts "DRAWING AI SHIP: #{@id} - #{@x} - #{@y}"
    # question = Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")

    # i2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
    # i2.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @height_scale, @height_scale)
    # puts "DRAWING SHIP: #{@id}"
    # @drawable_items_near_self.reject! { |item| item.draw }
    # puts "DRAWING SHIP - #{@x} - #{@y}"
    # @ship.front_hard_points.first.image_hardpoint.draw_rot(@x, @y, ZOrder::Hardpoint, @angle, 0.5, 0.5, @height_scale, @height_scale)
    # question.draw(@x, @y, 5000, @height_scale, @height_scale)
    @ship.draw(viewable_pixel_offset_x, viewable_pixel_offset_y)
  end

  # NEED to pass in other objects to shoot at.. and choose to shoot based on agro
  # enemies is relative.. can probably combine player and enemies.. No, player is used to calculate x
  def update mouse_x, mouse_y, player, air_targets = [], ground_targets = []
    validate_not_nil([mouse_x, mouse_y, player, air_targets, ground_targets], self.class.name, __callee__)
    # return {
    #   is_alive: true, projectiles: [], shipwreck: nil,
    #   destructable_projectiles: [], graphical_effects: []
    # }

    if @ship.current_momentum > 0.0
      # if @boost_active
      #   speed = @ship.boost_speed * (@current_momentum / (@ship.mass)) / 2.0
      # else
      speed = @ship.tiles_per_second * (@ship.current_momentum / (@ship.mass))
      # end
      ignore1, ignore2, halt = self.movement(speed, @angle)
      if halt
        @ship.current_momentum -= @ship.mass / 100.0
        @ship.current_momentum = 0 if @ship.current_momentum < 0
      end
    elsif @ship.current_momentum < 0.0
      speed = (0.6 * @ship.tiles_per_second) * (@ship.current_momentum / (@ship.mass))
      ignore1, ignore2, halt = self.movement(speed, @angle)
      if halt
        @ship.current_momentum -= @ship.mass / 100.0
        @ship.current_momentum = 0 if @ship.current_momentum < 0
      end
    end

    # puts "AI SHIP STARTING UPDATE: #{@id}"
    # START AGRO SECTION
    # @current_agro = current_agro - 0.1 if @current_agro > 0.0
    # need to remove from map when ship is destroyed.. maybe, would save memory space if that's important
    # just remove ship when argo reaches zero.
    @argo_target_map.each do |target_id, argo_level|
      @argo_target_map[target_id] = argo_level - AGRO_DECREMENT
      @argo_target_map.delete(target_id) if argo_level <= 0
    end

    projectiles = []
    destructable_projectiles = []
    graphical_effects = []
    local_max_agro = 0
    agro_target = nil
    agro_target_distance = nil

    if @special_target_focus && !@special_target_focus.is_alive
      @special_target_focus = nil
      @special_target_focus_id = nil
    end


    # # @special_target_focus_id = options[:special_target_focus_id] if options[:special_target_focus_id]
    # @special_target_focus_type = options[:special_target_focus_type] if options[:special_target_focus_type]
    # @special_target_focus = nil
    if @special_target_focus.nil?
      air_targets.each do |target|
        # Don't fire at self. don't fire at allies. Figure out ally logic
        next if target.id == self.id
        # Implement relationships.
        # next if target.allied
        # FOR TESTING, to keep them from murdering each other
        next if target.id != player.id
        next if target.id == player.id && !player.is_alive

        if @special_target_focus_id && @special_target_focus_id == target.id
          @special_target_focus = agro_target = target if @special_target_focus_id == target.id
          agro_target_distance = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, @special_target_focus.current_map_pixel_x, @special_target_focus.current_map_pixel_y)
        end
        break if @special_target_focus


        # check distance if not allied
        # if tile distance is less than agro distance, then you increase agro against that target
        # update max_agro
        # NEED TO ALSO INCREASE AGRO when taking damage from target.. and more so than just being within distance...
        distance_to_target = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, target.current_map_pixel_x, target.current_map_pixel_y)
        within_range = distance_to_target < @agro_map_pixel_distance
        if within_range
          @argo_target_map[target.id] = AGRO_MAX
        end
        if @argo_target_map[target.id] && @argo_target_map[target.id] > local_max_agro
          local_max_agro = @argo_target_map[target.id] 
          agro_target = target
          agro_target_distance = distance_to_target
        end
      end
    else
      agro_target = @special_target_focus
      agro_target_distance = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, @special_target_focus.current_map_pixel_x, @special_target_focus.current_map_pixel_y)
    end
    # END AGRO SECTION

    # START FIRING SECTION
    if agro_target && agro_target_distance < @firing_distance
      @ship.attack_group_1(@angle, @current_map_pixel_x, @current_map_pixel_y, agro_target).each do |results|
        results[:projectiles].each do |projectile|
          projectiles.push(projectile) if projectile
        end
        results[:destructable_projectiles].each do |projectile|
          destructable_projectiles.push(projectile) if projectile
        end
        results[:graphical_effects].each do |effect|
          graphical_effects.push(effect) if effect
        end
      end
      @ship.attack_group_2(@angle, @current_map_pixel_x, @current_map_pixel_y, agro_target).each do |results|
        results[:projectiles].each do |projectile|
          projectiles.push(projectile)
        end
        results[:destructable_projectiles].each do |projectile|
          destructable_projectiles.push(projectile) if projectile
        end
        results[:graphical_effects].each do |effect|
          graphical_effects.push(effect) if effect
        end
      end
     # puts "AI: TRYING TO FIRE GRAPPLE "
      @ship.attack_group_3(@angle, @current_map_pixel_x, @current_map_pixel_y, agro_target, {ai_block_attack_deactivation: true}).each do |results|
        # puts "GRAPPLE RESAULT:"
        # puts results
        results[:projectiles].each do |projectile|
          projectiles.push(projectile)
        end
        results[:destructable_projectiles].each do |projectile|
          destructable_projectiles.push(projectile) if projectile
        end
        results[:graphical_effects].each do |effect|
          graphical_effects.push(effect) if effect
        end
      end
    end
    # END FIRING SECTION



    # START MOVING SECTION
    destination_angle = nil
    if agro_target
      start_point = OpenStruct.new(:x => current_map_pixel_x,     :y => current_map_pixel_y)
      end_point   = OpenStruct.new(:x => agro_target.current_map_pixel_x, :y => agro_target.current_map_pixel_y)
      destination_angle = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
    end

    need_to_move = false
    if agro_target
      if agro_target_distance > @distance_preference_max
        # Move to player
        need_to_move = true
        is_within_preferred_angle = angle_is_within_angle_preferences([[359,1.0]], destination_angle)
        if is_within_preferred_angle
          # just keep accelerating
        else
          desired_angle, lowest_angle_diff = get_preferred_angle_and_rotational_diff([[359,1.0]], destination_angle)
          rotate_towards_destination(lowest_angle_diff)
        end
        # If not pointed at the target, then rotate towards it
        # if !(GeneralObject.angle_1to360((@angle - desired_angle)).abs <= @rotation_speed)
        # end
        accelerate

      elsif agro_target_distance < @distance_preference_min
        need_to_move = true
        # Move away from player
       # puts "IMPLEMENT REVERSE LATER FOR AI"
      end
    end
    # END MOVING SECTION

    # START ANGLING PREFERENCE SECTION
    if !need_to_move && agro_target
      # if don't need to move, check firing angle preference.
        # Reorienting angle to make 0 north
        # WHY IS DESTINATION ANGLE OFF? IT"S REVERSED
        
        # puts "DESTINATION ANGLE: #{destination_angle}"
        # if destination_angle is within one of the preferred angles?
        # puts "AI: destination_angle: #{destination_angle}"
        is_within_preferred_angle = angle_is_within_angle_preferences(@firing_angle_preferences, destination_angle)

        if is_within_preferred_angle 
          # Do not rotate
          # CHECK TO SEE IF ALLY SHIP IS WHITHIN ANGLE, MAY NEED TO MOVE TO GET CLEAR FIRING
        else
          # find_nearest_angle_group ..maybe? nearest preferred angle would suffice.
          desired_angle, lowest_angle_diff = get_preferred_angle_and_rotational_diff(@firing_angle_preferences, destination_angle)
          rotate_towards_destination(lowest_angle_diff)
        end
    end

    # END ANGLING PREFERENCE SECTION


    # START NORMAL PASSIVE BEHAVIOUR
    # IDK, patrol an area, guard a town, move randomly around the map, visit structures, pick up pickups.
    # START NORMAL PASSIVE BEHAVIOUR

    target_map_x = agro_target ? agro_target.current_map_pixel_x : nil
    target_map_y = agro_target ? agro_target.current_map_pixel_y : nil

    @ship.update(mouse_x, mouse_y, player, target_map_x, target_map_y)
    # puts "AI SHIP UPDATE: #{@id}"
    result = super(mouse_x, mouse_y, player)

    @ship.x = @x
    @ship.y = @y


    # update_momentum
    # puts "attack_results: "
    # puts attack_results.class.name
    # puts attack_results

    # attack_results: 
    # Array
    # {:projectiles=>[#<Bullet:0x00007fd57b17b800 @tile_pixel_width=112.5, @tile_pixel_height=112.5, @map_pixel_width=28125, @map_pixel_height=28125, @map_tile_width=250, @map_tile_height=250, @width_scale=1.875, @height_scale=1.875, @screen_pixel_width=900, @screen_pixel_height=900, @debug=true, @damage_increase=1, @average_scale=1.7578125, @id="38a6d435-ad58-4263-807e-cd040cbf5c30", @image=#######
    # , @time_alive=0, @image_width=9.375, @image_height=45.0, @image_size=210.9375, @image_radius=13.59375, @image_width_half=4.6875, @image_height_half=22.5, @inited=true, @x=-50, @y=-50, @x_offset=0, @y_offset=0, @current_map_pixel_x=14618, @current_map_pixel_y=13618, @current_map_tile_x=129, @current_map_tile_y=121, @angle=45.0, @radian=2.356194490192345, @health=1, @refresh_angle_on_updates=false, @speed=3, @end_image_angle=135.0, @current_image_angle=135.0>], :cooldown=>15}
      # factor_in_scale_speed = @speed * @average_scale

      # movement(factor_in_scale_speed, @angle) if factor_in_scale_speed != 0
    shipwreck = nil
    if !result
      shipwreck = Shipwreck.new(@current_map_pixel_x, @current_map_pixel_y, @current_map_tile_x, @current_map_tile_y, @ship, @current_momentum, @angle, @drops)
    end


    return {
      is_alive: result, projectiles: projectiles, shipwreck: shipwreck,
      destructable_projectiles: destructable_projectiles, graphical_effects: graphical_effects
    }
  end

  def use_steam usage
   # puts "AIT SHIP HERE"

      return true

  end
  def angle_is_within_angle_preferences preferred_angles, destination_angle
    is_within_preferred_angle = false
    # @firing_angle_preferences = [(240..300), (60..120)]
    preferred_angles.each do |ap|
      # NOTE: is_angle_between_two_angles is currently not working.. issues with the 0.. FIX IT HERE AND HOW
      is_within_preferred_angle = true if is_angle_between_two_angles?(destination_angle, ap[0] + @angle, ap[1] + @angle)
      # puts "is_angle_between_two_angles?(#{destination_angle + @angle}, #{ap[0] + @angle},#{ ap[1] + @angle}) WAS TRUE while angle was #{@angle}".upcase if is_within_preferred_angle

      # IS_ANGLE_BETWEEN_TWO_ANGLES?(412.2784989373889, 360.0,420.0) WAS TRUE WHILE ANGLE WAS 120
      # DESTINATION ANGLE: 292.2784989373889

      break if is_within_preferred_angle
    end
    return is_within_preferred_angle
  end

  # def drops
  #     [BulletLauncher, BulletLauncher, BulletLauncher]
  # end

  def get_preferred_angle_and_rotational_diff angle_preferences, destination_angle
    lowest_angle_diff = nil
    desired_angle = nil
    angle_preferences.each_with_index do |ap, index|
      local_nearest_angle, angle_diff = nearest_angle_with_diff(destination_angle, ap[0] + @angle, ap[1] + @angle)

      if lowest_angle_diff.nil? || angle_diff.abs < lowest_angle_diff.abs
        lowest_angle_diff = angle_diff
        desired_angle = local_nearest_angle
      end
    end
    return [desired_angle, lowest_angle_diff]
  end

  def rotate_towards_destination angle_diff
    if angle_diff > 0.0
      rotate_clockwise
    else
      rotate_counterclockwise
    end
  end
end