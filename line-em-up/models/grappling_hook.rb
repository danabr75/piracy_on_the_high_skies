require_relative 'general_object.rb'

class GrapplingHook < GeneralObject
  attr_reader :x, :y, :time_alive, :active
  attr_accessor :active

  COOLDOWN_DELAY = 30
  # MAX_SPEED      = 2
  # STARTING_SPEED = 0.0
  # INITIAL_DELAY  = 2
  # SPEED_INCREASE_FACTOR = 0.5
  DAMAGE = 0
  
  MAX_CURSOR_FOLLOW = 15

  def initialize(scale, object)
    @scale = scale

    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/grappling_hook.png").first.resize(0.1)
    # @image = Gosu::Image.new(image, :tileable => true)
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/grappling_hook.png")

    # chain = Magick::Image::read("#{MEDIA_DIRECTORY}/chain.png").first.resize(0.1)
    # @chain = Gosu::Image.new(chain, :tileable => true)
    @chain = Gosu::Image.new("#{MEDIA_DIRECTORY}/chain.png")

    @x = object.get_x - (object.get_width / 2)
    @y = object.get_y

    # @x = mouse_x
    # @y = mouse_y
    # @time_alive = 0
    @active = true
    @acquired_items = 0
  end

  def draw player
    # puts Gosu.milliseconds
    # puts @animation.size
    # puts 100 % @animation.size
    # puts "Gosu.milliseconds / 100 % @animation.size: #{Gosu.milliseconds / 100 % @animation.size}"
    # img.draw(@x, @y, ZOrder::Projectile, :add)
    # puts "11: #{@x} and #{@y}"
    # @image.draw(@x, @y, ZOrder::Projectile)
    @image.draw(@x - get_width / 2, @y - get_height / 2, ZOrder::Cursor, @scale, @scale)

    chain_x = @x
    chain_y = @y
    max_chain_length = 100
    counter = 0
    while Gosu.distance(chain_x, chain_y, player.x, player.y) > (35 * @scale) && counter < max_chain_length
      if chain_x > player.x
        difference = chain_x - player.x
        if difference > MAX_CURSOR_FOLLOW
          difference = MAX_CURSOR_FOLLOW
        end
        chain_x = chain_x - difference
      else
        # Cursor is right of the missle, missile needs to go right. chain_x needs to get bigger. chain_x is smaller than player.x
        difference = player.x - chain_x
        if difference > MAX_CURSOR_FOLLOW
          difference = MAX_CURSOR_FOLLOW
        end
        chain_x = chain_x + difference
      end

      if chain_y > player.y
        difference = chain_y - player.y
        if difference > MAX_CURSOR_FOLLOW
          difference = MAX_CURSOR_FOLLOW
        end
        chain_y = chain_y - difference
      else
        # Cursor is right of the missle, missile needs to go right. chain_y needs to get bigger. chain_y is smaller than player.y
        difference = player.y - chain_y
        if difference > MAX_CURSOR_FOLLOW
          difference = MAX_CURSOR_FOLLOW
        end
        chain_y = chain_y + difference
      end

      @chain.draw(chain_x - @chain.width / 2, chain_y - @chain.height / 2, ZOrder::Cursor, @scale, @scale)
      counter += 1
    end

    # img.draw_rect(@x, @y, 25, 25, @x + 25, @y + 25, :add)
  end

  def active
    @active && @acquired_items == 0
  end

  def deactivate
    @active = false
  end

  def activate
    @active = true
  end

  def get_max_cursor
    (MAX_CURSOR_FOLLOW * @scale).round
  end
  
  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    # if @time_alive > INITIAL_DELAY
    #   new_speed = STARTING_SPEED + (@time_alive * SPEED_INCREASE_FACTOR)
    #   new_speed = MAX_SPEED if new_speed > MAX_SPEED
    #   @y -= new_speed
    # end
    return_value = true
    if !self.active
      mouse_x = player.x
      mouse_y = player.y

      if Gosu.distance(@x, @y, player.x, player.y) < 35 * @scale
        return_value = false
      end

    end

    # Cursor is left of the missle, missile needs to go left. @x needs to get smaller. @x is greater than mouse_x
    if @x > mouse_x
      difference = @x - mouse_x
      if difference > get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
        difference = get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
      end
      @x = @x - difference
    else
      # Cursor is right of the missle, missile needs to go right. @x needs to get bigger. @x is smaller than mouse_x
      difference = mouse_x - @x
      if difference > get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
        difference = get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
      end
      @x = @x + difference
    end

    if @y > mouse_y
      difference = @y - mouse_y
      if difference > get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
        difference = get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
      end
      @y = @y - difference
    else
      # Cursor is right of the missle, missile needs to go right. @y needs to get bigger. @y is smaller than mouse_y
      difference = mouse_y - @y
      if difference > get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
        difference = get_max_cursor / (@acquired_items > 0 ? (@acquired_items + 2) : 1)
      end
      @y = @y + difference
    end

    # MOUSE X and MOUSE Y: 400 and 300
    # NEW Y AND X FOR GRAPPLE: 391 and 281
    # MOUSE X and MOUSE Y: 400 and 300
    # NEW Y AND X FOR GRAPPLE: 410 and 300



    # puts "GRAPPLING HOOK REUTRN: #{return_value}"
    return return_value
    # Return false when out of screen (gets deleted then)
    # @time_alive += 1
  end


  def collect_pickups(player, pickups)
    pickups.reject! do |pickup|
      if Gosu.distance(@x, @y, pickup.x, pickup.y) < 35 && pickup.respond_to?(:collected_by_player)

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
      if Gosu.distance(@x, @y, object.x, object.y) < 30
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


  def hit_object(object)
    return_value = nil
    if Gosu.distance(@x, @y, object.x, object.y) < 30
      @y = -50
      return_value = DAMAGE
    else
      return_value = 0
    end
    return return_value
  end


end