require_relative 'projectile.rb'
require 'gosu'
# require 'opengl'
# require 'glu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

# For opengl-bindings
# OpenGL.load_lib()

# GLUT.load_lib()


class GrapplingHook < Projectile
  MAX_SPEED      = 3
  STARTING_SPEED = 3
  INITIAL_DELAY  = 0.0
  SPEED_INCREASE_FACTOR = 2
  DAMAGE = 0
  AOE = 0
  MAX_TILE_LENGTH = 3
  
  # MAX_CURSOR_FOLLOW = 4
  # ADVANCED_HIT_BOX_DETECTION = true

  # Might not be necessary to override
  def initialize(current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options = {})
    super(current_map_pixel_x, current_map_pixel_y, destination_angle, start_point, end_point, angle_min, angle_max, angle_init, current_map_tile_x, current_map_tile_y, owner, options)
    @chain_image = get_chain_image
    if @image
      @chain_image_width  = @chain_image.width  * (@width_scale)
      @chain_image_height = @chain_image.height * (@height_scale)
      @chain_image_size   = @chain_image_width  * @chain_image_height / 2
      @chain_image_radius = (@chain_image_width  + @chain_image_height) / 4
    end
    @player_reference = nil
  end

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/grappling_hook.png")
  end
  def get_chain_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/hardpoints/grappling_hook_launcher/chain.png")
  end

  def drops
    [
      # Add back in once SE has been updated to display on map, not on screen.
      # SmallExplosion.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y, nil, {ttl: 2, third_scale: true}),
    ]
  end

  
  def update mouse_x, mouse_y, player
    @player_reference = player
    # puts "MISSILE: #{@health}"
    returned_to_player = false
    distance = Gosu.distance(player.current_map_pixel_x, player.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y)
    if @returning_to_player 
      if distance < player.get_radius
        returned_to_player = true
      end
    end

    if !@returning_to_player && distance >= MAX_TILE_LENGTH * @average_tile_size
      @returning_to_player = true
    end
    if @returning_to_player
      start_point = OpenStruct.new(:x => current_map_pixel_x,     :y => current_map_pixel_y)
      end_point   = OpenStruct.new(:x => player.current_map_pixel_x, :y => player.current_map_pixel_y)
      @angle = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
    end
    return !returned_to_player && super(mouse_x, mouse_y, player)
  end

  def draw
    if @player_reference
      start_point = OpenStruct.new(:x => current_map_pixel_x,     :y => current_map_pixel_y)
      end_point   = OpenStruct.new(:x => @owner.current_map_pixel_x, :y => @owner.current_map_pixel_y)
      angle_to_origin = self.class.angle_1to360(180.0 - calc_angle(start_point, end_point) - 90)
      # Reversing direction
      angle_to_origin = self.class.angle_1to360(angle_to_origin - 180)
      # distance = Gosu.distance(player.current_map_pixel_x, player.current_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y)
      # if @returning_to_player 
      #   if distance < player.get_radius
      #     returned_to_player = true
      #   end
      # end
      step = (Math::PI/180 * (angle_to_origin + 90))
      base = @chain_image_radius
      new_x = Math.cos(step) * base + @current_map_pixel_x
      new_y = Math.sin(step) * base + @current_map_pixel_y
      i = 0
      while i < 100 && Gosu.distance(@owner.current_map_pixel_x, @owner.current_map_pixel_y, new_x, new_y) > (@owner.get_radius / 2)
        x, y = GeneralObject.convert_map_pixel_location_to_screen(@player_reference, new_x, new_y, @screen_pixel_width, @screen_pixel_height)
        @chain_image.draw_rot(x, y, ZOrder::Projectile, -@current_image_angle, 0.5, 0.5, @width_scale, @height_scale)
        #
        step = (Math::PI/180 * (angle_to_origin + 90))
        new_x = Math.cos(step) * base + new_x
        new_y = Math.sin(step) * base + new_y
        i += 1
      end
    end


    # @chain_image.draw_rot(@x, @y, ZOrder::Projectile, -@current_image_angle, 0.5, 0.5, @width_scale, @height_scale)
    super()
  end

  def hit_objects(object_groups)
    # hit only ships, that aren't the owner
    return false
    raise "grapple hit"
    drops = []
    points = 0
    hit_object = false
    killed = 0
    object_groups.each do |group|
      group.each do |object|
        next if object.nil?
        # Don't hit yourself
        next if object.id == @id
        # Don't hit the ship that launched it
        next if object.id == @launched_from_id
        break if hit_object
        # don't hit a dead object
        if object.health <= 0
          next
        end
        # if Gosu.distance(@x, @y, object.x, object.y) < (self.get_size / 2)
        # maybe add advanced collision in when support multi-threads
        if false && self.class.get_advanced_hit_box_detection
          # Disabling advanced hit detection for now
          self_object = [[(@x - get_width / 2), (@y - get_height / 2)], [(@x + get_width / 2), (@y + get_height / 2)]]
          other_object = [[(object.x - object.get_width / 2), (object.y - object.get_height / 2)], [(object.x + object.get_width / 2), (object.y + object.get_height / 2)]]
          hit_object = rec_intersection(self_object, other_object)
        else
          # puts "HIT OBJECT DETECTION: proj-size: #{(self.get_size / 2)}"
          # puts "HIT OBJECT DETECTION:  obj-size: #{(self.get_size / 2)}"
          raise "OBJECT #{object.class.name} IN COLLISION DIDN'T HAVE COORD X" if @debug && !object.respond_to?(:current_map_pixel_x)
          raise "OBJECT #{object.class.name} IN COLLISION DIDN'T HAVE COORD Y" if @debug && !object.respond_to?(:current_map_pixel_y)
          raise "OBJECT #{object.class.name} IN COLLISION COORD X WAS NIL" if @debug && object.current_map_pixel_x.nil?
          raise "OBJECT #{object.class.name} IN COLLISION COORD Y WAS NIL" if @debug && object.current_map_pixel_y.nil?
          if @debug
            if self.get_radius.nil?
              raise "NO RADIUS FOUND FOR #{self.class.name}. Does it have an Image assigned? Is image nil? #{self.get_image.nil?} and is image nil? #{object.image.nil?}"
            end
            if object.get_radius.nil?
              raise "NO RADIUS FOUND FOR #{object.class.name}. Does it have an Image assigned? Is get image nil? #{object.get_image.nil?} and is image nil? #{object.image.nil?}"
            end
          end
          hit_object = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, object.current_map_pixel_x, object.current_map_pixel_y) < self.get_radius + object.get_radius
        end
        if hit_object
          # puts "COLLISION DETECTED!!!!! - #{self.class.name} - to #{object.class.name}"
          # puts "Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, object.current_map_pixel_x, object.current_map_pixel_y) < self.get_radius + object.get_radius"
          # puts "Gosu.distance(#{@current_map_pixel_x}, #{@current_map_pixel_y}, #{object.current_map_pixel_x}, #{object.current_map_pixel_y}) < #{self.get_radius} + #{object.get_radius}"
          # raise "STOP HERE"
          # hit_object = true
          if self.class.get_aoe <= 0
            if object.respond_to?(:health) && object.respond_to?(:take_damage)
              object.take_damage(self.class.get_damage * @damage_increase)
            end

            if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)

              object.drops.each do |drop|
                drops << drop
              end
            end

            if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:get_points)
              killed += 1
              points = points + object.get_points
            end
          end
        end
      end
    end
    if hit_object && self.class.get_aoe > 0
      object_groups.each do |group|
        group.each do |object|
          next if object.nil?
          if Gosu.distance(@x, @y, object.x, object.y) < self.class.get_aoe * @scale
            if object.respond_to?(:health) && object.respond_to?(:take_damage)
              object.take_damage(self.class.get_damage * @damage_increase)
            end

            if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)
              object.drops.each do |drop|
                drops << drop
              end
            end

            if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:get_points)
              killed += 1
              points = points + object.get_points
            end
          end
        end
      end
    end

    # Drop projectile explosions
    if hit_object
      if self.respond_to?(:drops)
        self.drops.each do |drop|
          drops << drop
        end
      end
    end

    @health = 0 if hit_object
    puts "COLLICION RETURNING DROPS: #{drops}" if drops.any?
    return {drops: drops, point_value: points, killed: killed}
  end

end
