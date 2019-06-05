require_relative 'general_object.rb'

class GrapplingHook < GeneralObject
  attr_reader :x, :y, :time_alive, :active, :angle, :end_point_x, :end_point_y
  attr_accessor :active

  COOLDOWN_DELAY = 45
  # MAX_SPEED      = 2
  # STARTING_SPEED = 0.0
  # INITIAL_DELAY  = 2
  # SPEED_INCREASE_FACTOR = 0.5
  DAMAGE = 0
  
  # MAX_CURSOR_FOLLOW = 15
  MAX_SPEED      = 20

  def cooldown_delay
    COOLDOWN_DELAY
  end

  def initialize(scale, screen_pixel_width, screen_pixel_height, object, mouse_x, mouse_y, options = {})
    # object.grapple_hook_cooldown_wait = COOLDOWN_DELAY
    @scale = scale

    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/grappling_hook.png").first.resize(0.1)
    # @image = Gosu::Image.new(image, :tileable => true)
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/grappling_hook.png")

    # chain = Magick::Image::read("#{MEDIA_DIRECTORY}/chain.png").first.resize(0.1)
    # @chain = Gosu::Image.new(chain, :tileable => true)
    @chain = Gosu::Image.new("#{MEDIA_DIRECTORY}/chain.png")

    @x = object.x - (@image.width / 2 * @scale)
    @y = object.y
    @end_point_x = mouse_x
    @end_point_y = mouse_y

    @active = true
    @acquired_items = 0
    start_point = OpenStruct.new(:x => @x, :y => @y)
    end_point   = OpenStruct.new(:x => @end_point_x, :y => @end_point_y)
    @angle = calc_angle(start_point, end_point)
    # @radian = calc_radian(start_point, end_point)
    @image_angle = @angle
    if @angle < 0
      @angle = 360 - @angle.abs
      @image_angle = (@angle - 90) * -1
    else
      @image_angle = (@angle - 90) * -1
    end

    @max_length = 7 * @scale
    @max_length_counter = 0
    @reached_end_point = false
    @reached_back_to_player = false
    @reached_max_length = false
    @image_width  = @image.width  * @scale
    @image_height = @image.height * @scale
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4
    @current_speed = (self.class.get_max_speed * @scale).round
    #Chain Image pre-calc
    @chain_height  = @chain.width * @scale
    @chain_width  = @chain.height * @scale
    @chain_size   = @chain_width  * @chain_height / 2
    @chain_radius = ((@chain_height + @chain_width) / 4) * @scale

    # @screen_pixel_width  = screen_width
    # @screen_pixel_height = screen_height
    # @off_screen = screen_height + screen_height
  end

  def draw player

    start_point = OpenStruct.new(:x => @x - get_width / 2, :y => @y - get_height / 2)
    # end_point   = OpenStruct.new(:x => player.x - (player.get_width / 2) + @chain.width / 2, :y => player.y - (player.get_height / 2))
    end_point   = OpenStruct.new(:x => player.x - (player.get_width / 2) + @chain.width, :y => player.y - (player.get_height / 2))
    chain_angle = calc_angle(start_point, end_point)
    if chain_angle < 0
      chain_angle = 360 - chain_angle.abs
    end

    # @image.draw_rot(@x - get_width / 2 - get_height / 2, @y, ZOrder::Cursor, @image_angle, 0.5, 0.5, @width_scale, @height_scale)
    # @image.draw_rot(@x - get_width / 2 - get_height / 2, @y, ZOrder::Cursor, (@angle - 90) * -1, 0.5, 0.5, @width_scale, @height_scale)
    @image.draw_rot(@x, @y, ZOrder::Cursor, @image_angle, 0.5, 0.5, @width_scale, @height_scale)

    chain_x = @x# - (get_width / 2)  - (@chain.width / 2)
    chain_y = @y# - (get_height / 2)  - (@chain.height / 2)
    loop_count = 0
    max_loop_count = 250
    # Subtracting 5, to get close to player coords
    while Gosu.distance(chain_x,  chain_y, player.x, player.y) > (@chain_radius + player.get_radius) && loop_count < max_loop_count
      vx = 0
      vy = 0
      vx = 5 * Math.cos(chain_angle * Math::PI / 180)

      vy = 5 * Math.sin(chain_angle * Math::PI / 180)
      vy = vy * -1
        # Because our y is inverted
        # vy = vy - ((new_speed / 3) * 2)

      chain_x = chain_x + vx
      chain_y = chain_y + vy
      @chain.draw(chain_x - @chain_width / 2, chain_y - @chain_height / 2, ZOrder::Cursor, @width_scale, @height_scale)
      loop_count += 1
    end
  end

  def get_chain_height
    @chain_height
  end

  def get_chain_width
    @chain_width
  end

  def get_chain_size
    @chain_size
  end

  def get_chain_radius
    @chain_radius
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

  # def self.get_max_cursor_follow scale
    
  # end
  
  def update player = nil
    # puts "GRAP UPDATE:#{@reached_max_length} and #{@max_length_counter}"
    if !@reached_end_point
      current_angle = @angle
    end
    if @reached_end_point || @reached_max_length
      # Recalc back to player
      start_point = OpenStruct.new(:x => @x - get_width / 2, :y => @y - get_height / 2)
      end_point   = OpenStruct.new(:x => player.x - (player.get_width / 2), :y => player.y)
      angle = calc_angle(start_point, end_point)
      # radian = calc_radian(start_point, end_point)
      if angle < 0
        angle = 360 - angle.abs
      end
      current_angle = angle
    end
    # new_speed = 0
    # if @time_alive > self.class.get_initial_delay
    new_speed = @current_speed
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

    if !@reached_max_length
      @reached_max_length = true if @max_length_counter >= @max_length
    end

    if !@reached_max_length
      @max_length_counter += 1
      # Not stopping on the mouse end_point
      # @reached_end_point = true if Gosu.distance(@x - get_width / 2,  @y - get_height / 2, @end_point_x, @end_point_y) < self.get_radius * @scale
    end

    if @reached_end_point || @reached_max_length
      @reached_back_to_player = true if Gosu.distance(@x - get_width / 2,  @y - get_height / 2, player.x, player.y) < ((self.get_radius * 2) * @scale)
    end


    return !@reached_back_to_player
  end


  def collect_pickups(player, pickups)
    pickups.reject! do |pickup|
      # puts "PICKUP GET RADIUS: #{pickup.get_radius}"
      if Gosu.distance(@x, @y, pickup.x, pickup.y) < ((self.get_radius) + (pickup.get_radius)) * 1.2 && pickup.respond_to?(:collected_by_player)

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


end