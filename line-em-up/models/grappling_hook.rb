require_relative 'general_object.rb'

class GrapplingHook < GeneralObject
  attr_reader :x, :y, :time_alive, :active, :angle, :end_point_x, :end_point_y
  attr_accessor :active

  COOLDOWN_DELAY = 30
  # MAX_SPEED      = 2
  # STARTING_SPEED = 0.0
  # INITIAL_DELAY  = 2
  # SPEED_INCREASE_FACTOR = 0.5
  DAMAGE = 0
  
  # MAX_CURSOR_FOLLOW = 15
  MAX_SPEED      = 20

  def initialize(scale, object, mouse_x, mouse_y)
    @scale = scale

    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/grappling_hook.png").first.resize(0.1)
    # @image = Gosu::Image.new(image, :tileable => true)
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/grappling_hook.png")

    # chain = Magick::Image::read("#{MEDIA_DIRECTORY}/chain.png").first.resize(0.1)
    # @chain = Gosu::Image.new(chain, :tileable => true)
    @chain = Gosu::Image.new("#{MEDIA_DIRECTORY}/chain.png")

    @x = object.get_x - (object.get_width / 2)
    @y = object.get_y
    @end_point_x = mouse_x
    @end_point_y = mouse_y

    @active = true
    @acquired_items = 0
    start_point = OpenStruct.new(:x => @x - get_width / 2, :y => @y - get_height / 2)
    end_point   = OpenStruct.new(:x => @end_point_x, :y => @end_point_y)
    @angle = calc_angle(start_point, end_point)
    @radian = calc_radian(start_point, end_point)
    if @angle < 0
      @angle = 360 - @angle.abs
    end
    @max_length = 100 * @scale
    @reached_end_point = false
    @reached_back_to_player = false
  end

  def draw player
    @image.draw(@x - get_width / 2, @y - get_height / 2, ZOrder::Cursor, @scale, @scale)

    # chain_x = @x
    # chain_y = @y
    # counter = 0



    # puts "STARTING LOOP CHAIN #{chain_x} and #{chain_y}  vs   player: #{player.x} and #{player.y}"
    # while Gosu.distance(chain_x, chain_y, player.x, player.y) > (1) && counter < max_chain_length
    #   puts "DRAWING CHAIN: #{chain_x} and #{chain_y}"
    #   new_speed = 1 * @scale

    #   vx = 0
    #   vy = 0
    #   if new_speed > 0
    #     vx = ((new_speed / 3) * 1) * Math.cos(@angle * Math::PI / 180)

    #     vy = ((new_speed / 3) * 1) * Math.sin(@angle * Math::PI / 180)
    #     vy = vy * -1
    #     # Because our y is inverted
    #     vy = vy - ((new_speed / 3) * 2)
    #   end

    #   if chain_x > player.x
    #     chain_x = chain_x - vx
    #   else
    #     chain_x = chain_x + vx
    #   end
    #   if chain_y > player.y
    #     chain_y = chain_y - vy
    #   else
    #     chain_y = chain_y + vy
    #   end



    #   @chain.draw(chain_x - @chain.width / 2, chain_y - @chain.height / 2, ZOrder::Cursor, @scale, @scale)
    #   counter += 1
    # end
    # puts "ENDING LOOP"

    # img.draw_rect(@x, @y, 25, 25, @x + 25, @y + 25, :add)
  end

  def active
    @active# && @acquired_items == 0
  end

  def deactivate
    @active = false
  end

  def activate
    @active = true
  end

  def self.get_max_cursor_follow scale
    (MAX_CURSOR_FOLLOW * scale).round
  end
  
  def update width, height, player = nil
    puts "GRAP UPDATE: #{@angle}"
    if !@reached_end_point
      current_angle = @angle
    end
    if @reached_end_point 
      # Recalc back to player
      start_point = OpenStruct.new(:x => @x - get_width / 2, :y => @y - get_height / 2)
      end_point   = OpenStruct.new(:x => player.x, :y => player.y)
      @angle = calc_angle(start_point, end_point)
      @radian = calc_radian(start_point, end_point)
      if @angle < 0
        @angle = 360 - @angle.abs
      end
      current_angle = @angle
    end
    # new_speed = 0
    # if @time_alive > self.class.get_initial_delay
    new_speed = (self.class.get_max_speed * @scale) # if new_speed > self.class.get_max_speed
    new_speed = new_speed.fdiv(@acquired_items + 1) if @acquired_items > 0 && @reached_end_point
    # new_speed = new_speed * @scale
    # end

    vx = 0
    vy = 0
    if new_speed > 0
      vx = new_speed * Math.cos(current_angle * Math::PI / 180)

      vy = new_speed * Math.sin(current_angle * Math::PI / 180)
      vy = vy * -1
      # Because our y is inverted
      # vy = vy - ((new_speed / 3) * 2)
    end

    @x = @x + vx
    @y = @y + vy

    @reached_end_point = true if Gosu.distance(@x - get_width / 2,  @y - get_height / 2, @end_point_x, @end_point_y) < self.get_radius * @scale
    if @reached_end_point
      @reached_back_to_player = true if Gosu.distance(@x - get_width / 2,  @y - get_height / 2, player.x, player.y) < self.get_radius * @scale
    end
    # raise "HERE WE GO" if @reached_end_point

    # After reached target, reverse the angle

    return !@reached_back_to_player
  end


  def collect_pickups(player, pickups)
    pickups.reject! do |pickup|
      if Gosu.distance(@x, @y, pickup.x, pickup.y) < 35 * @scale && pickup.respond_to?(:collected_by_player)

        pickup.collected_by_player(player)
        if pickup.respond_to?(:get_points)
          player.score += pickup.get_points
        end
        @acquired_items += 1
        true
      else
        false
      end
    end
  end



  def hit_objects(objects)
    drops = []
    objects.each do |object|
      if Gosu.distance(@x, @y, object.x, object.y) < self.get_radius * @scale
        # Missile destroyed
        # @y = -100
        if object.respond_to?(:health) && object.respond_to?(:take_damage)
          object.take_damage(DAMAGE)
        end

        if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)
          # puts "CALLING THE DROP"
          object.drops.each do |drop|
            drops << drop
          end
        end

      end
    end
    return {drops: drops, point_value: 0}
  end


  # def hit_object(object)
  #   return_value = nil
  #   if Gosu.distance(@x, @y, object.x, object.y) < 30
  #     @y = -50
  #     return_value = DAMAGE
  #   else
  #     return_value = 0
  #   end
  #   return return_value
  # end


end