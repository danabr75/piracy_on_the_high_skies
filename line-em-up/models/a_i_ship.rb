require_relative 'screen_fixed_object.rb'
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
  MAX_HEALTH = 200
  AGRO_TILE_DISTANCE = 2
  # in seconds
  # ANGRO MAX is 10 seconds
  AGRO_MAX = 10 * 60
  AGRO_DECREMENT = 1

  # Just test out the tile part first.. or whatever
  def initialize(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options = {})
    validate_int([current_map_tile_x, current_map_tile_y],  self.class.name, __callee__)
    validate_float([current_map_pixel_x, current_map_pixel_y],  self.class.name, __callee__)

    options[:image] = BasicShip.get_image(BasicShip::SHIP_MEDIA_DIRECTORY)
    super(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options)

    @score = 0
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @grapple_hook_cooldown_wait = 0
    @angle = 0

    hardpoint_data = Player.get_hardpoint_data('BasicShip')
    @ship = BasicShip.new(@x, @y, get_draw_ordering, ZOrder::AIHardpoint, @angle, @id, hardpoint_data)
    @ship.x = @x
    @ship.y = @y
    @current_momentum = 0
    @max_momentum = @ship.mass # speed here?
    @rotation_speed = 2

    @health = @ship.get_health
    @armor = @ship.get_armor

    # Find angle preference range here..
    @ship.hardpoints.each do |hp|
      hp.inspect
    end

    @agro_map_pixel_distance = AGRO_TILE_DISTANCE * ((@tile_pixel_width + @tile_pixel_height) / 2.0)
    @argo_target_map = {}
    # stop
  end

  def rotate_counterclockwise
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
    @ship.take_damage(damage)
    # @health -= damage * @damage_reduction
  end

  def is_alive
    @ship.is_alive
    # health > 0
  end


  def move_left movement_x = 0, movement_y = 0
    # new_speed = (@speed  / (@mass.to_f)) * -1.5
    new_speed = (@speed  / (@mass.to_f)) * -100
    x_diff, y_diff = self.movement(new_speed, @angle + 90, false)
    return [movement_x - x_diff, movement_y - y_diff]
  end
  
  def move_right movement_x = 0, movement_y = 0
    # new_speed = (@speed  / (@mass.to_f)) * -1.5
    new_speed = (@speed  / (@mass.to_f)) * -100
    x_diff, y_diff = self.movement(new_speed, @angle - 90, false)
    return [movement_x - x_diff, movement_y - y_diff]
  end
  def accelerate movement_x = 0, movement_y = 0
    x_diff, y_diff = self.movement( @speed / (@mass.to_f), @angle, false)

    if @current_momentum <= @max_momentum
      @current_momentum += 1.2
    end
    # puts "PLAYER ACCELETATE:"
    # puts "[movement_x - x_diff, movement_y - y_diff]"
    # puts "[#{movement_x} - #{x_diff}, #{movement_y} - #{y_diff}]"
    return [(movement_x - x_diff), (movement_y - y_diff)]
  end
  
  def brake movement_x = 0, movement_y = 0
    # raise "ISSUE4" if @current_map_pixel_x.class != Integer || @current_map_pixel_y.class != Integer 
    # puts "ACCELERATE: #{movement_x} - #{movement_y}"
    x_diff, y_diff = self.movement( @speed / (@mass.to_f), @angle - 180, false)

    if @current_momentum >= -@max_momentum
      @current_momentum -= 2
    end

    return [(movement_x - x_diff), (movement_y - y_diff)]
  end

  def get_draw_ordering
    ZOrder::AIShip
  end

  def draw

    # i2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
    # i2.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @width_scale, @height_scale)
    # puts "DRAWING SHIP: #{@id}"
    # @drawable_items_near_self.reject! { |item| item.draw }
    # puts "DRAWING SHIP - #{@x} - #{@y}"
    # @ship.front_hard_points.first.image_hardpoint.draw_rot(@x, @y, ZOrder::Hardpoint, @angle, 0.5, 0.5, @width_scale, @height_scale)
    @ship.draw({test: true})
  end

  # NEED to pass in other objects to shoot at.. and choose to shoot based on agro
  # enemies is relative.. can probably combine player and enemies.. No, player is used to calculate x
  def update mouse_x, mouse_y, player, air_targets = [], ground_targets = []
    # @current_agro = current_agro - 0.1 if @current_agro > 0.0
    # need to remove from map when ship is destroyed.. maybe, would save memory space if that's important
    # just remove ship when argo reaches zero.
    @argo_target_map.each do |target_id, argo_level|
      @argo_target_map[target_id] = argo_level - AGRO_DECREMENT
      @argo_target_map.delete(target_id) if argo_level <= 0
    end


    # @argo_target_map = {}
    # puts "AI: front_hard_points.count #{@ship.front_hard_points.count}"
    # puts "AI2: front_hard_points #{@ship.front_hard_points.first}"

    projectiles = []
    local_max_agro = 0
    agro_target = nil

    air_targets.each do |target|
      # Don't fire at self. don't fire at allies. Figure out ally logic
      next if target.id == self.id
      # Implement relationships.
      # next if target.allied

      # check distance if not allied
      # if tile distance is less than agro distance, then you increase agro against that target
      # update max_agro
      within_range = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, target.current_map_pixel_x, target.current_map_pixel_y) < @agro_map_pixel_distance
      if within_range
        @argo_target_map[target.id] = AGRO_MAX
      end
      if @argo_target_map[target.id] && @argo_target_map[target.id] > local_max_agro
        local_max_agro = @argo_target_map[target.id] 
        agro_target = target
      end
    end

    if agro_target
      @ship.attack_group_1(@angle, @current_map_pixel_x, @current_map_pixel_y, agro_target).each do |results|
        results[:projectiles].each do |projectile|
          projectiles.push(projectile)
        end
      end
    end




    # increase aggro at target here, if enemy faction is within x tiles... agro distance needs to be a constant.


    @ship.update(mouse_x, mouse_y, player)
    # puts "AI UPDATE: #{@x} - #{@y}"
    result = super(mouse_x, mouse_y, player)
    @ship.x = @x
    @ship.y = @y
    # puts "attack_results: "
    # puts attack_results.class.name
    # puts attack_results

    # attack_results: 
    # Array
    # {:projectiles=>[#<Bullet:0x00007fd57b17b800 @tile_pixel_width=112.5, @tile_pixel_height=112.5, @map_pixel_width=28125, @map_pixel_height=28125, @map_tile_width=250, @map_tile_height=250, @width_scale=1.875, @height_scale=1.875, @screen_pixel_width=900, @screen_pixel_height=900, @debug=true, @damage_increase=1, @average_scale=1.7578125, @id="38a6d435-ad58-4263-807e-cd040cbf5c30", @image=#######
    # , @time_alive=0, @image_width=9.375, @image_height=45.0, @image_size=210.9375, @image_radius=13.59375, @image_width_half=4.6875, @image_height_half=22.5, @inited=true, @x=-50, @y=-50, @x_offset=0, @y_offset=0, @current_map_pixel_x=14618, @current_map_pixel_y=13618, @current_map_tile_x=129, @current_map_tile_y=121, @angle=45.0, @radian=2.356194490192345, @health=1, @refresh_angle_on_updates=false, @speed=3, @end_image_angle=135.0, @current_image_angle=135.0>], :cooldown=>15}



    return {is_alive: result, projectiles: projectiles }
  end

end