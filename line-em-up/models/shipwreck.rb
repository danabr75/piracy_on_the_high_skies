require_relative 'screen_map_fixed_object.rb'

class Shipwreck < ScreenMapFixedObject

  def initialize window, current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, ship, momentum, angle, drops = [], options = {}
   # puts "NEW SHIPWREKC: #{[current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, momentum, angle]}"
    @window = window
    @ship = ship
    @ship.turn_off_hardpoints
    @angle = angle
    @scale_start = 1.0
    @scale_end   = 0.7
    @current_scale = @scale_start
    # @scare_decrement = momentum * (@scale_start - @scale_end)
    @scare_decrement = 0.0018
    # WHAT If momentum is 0, which it often is..
    # puts "#{@scare_decrement} = #{momentum} * (#{@scale_start} - #{@scale_end})"
    # puts "@scare_decrement: #{@scare_decrement}"
    @current_momentum = momentum

    @drops = drops

    @persist = options[:persist] || false

    options[:no_image] = true

    @angle_direction = rand(2)
    if @angle_direction == 0
      @angle_direction = -1
    else
      @angle_direction = 1
    end

    @health = 1
    super(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options)
  end

  def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
    @ship.switch_to_destroyed_image(@ship.class::ITEM_MEDIA_DIRECTORY) if @current_scale == @scale_end
    super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
    building = nil
    @ship.x = @x
    @ship.y = @y
    if @time_alive > 0
      new_angle_offset = @angle_direction + @angle_direction * (@time_alive / 100.0)
      @angle = @angle + new_angle_offset
      @ship.angle = @angle
    end

    update_momentum if @current_momentum != 0
    if @current_scale != @scale_end
      @current_scale -= @scare_decrement
      @current_scale = @scale_end if @current_scale < @scale_end
    else
      # background fixed object = initialize(current_map_tile_x, current_map_tile_y, options = {})
      options = {}
      options[:current_map_pixel_x] = @current_map_pixel_x
      options[:current_map_pixel_y] = @current_map_pixel_y
      options[:persist] = @persist
      revised_scale = 1.0 - ((1.0 - @current_scale) / 2.0)
      if @drops.any? || @persist
        building = Buildings::Landwreck.new(@window, current_map_tile_x, current_map_tile_y, @ship, revised_scale, @angle, @drops, options)
      end
      @health = 0
    end
    return {is_alive: is_alive, building: building }
  end

  def draw viewable_pixel_offset_x, viewable_pixel_offset_y
    if @is_on_screen
      @ship.draw(viewable_pixel_offset_x, viewable_pixel_offset_y, @current_scale)
    end
  end

  def update_momentum
    if @current_momentum > 0.0
      speed = (@ship.mass / 10.0) * (@current_momentum / 10.0) / 90.0
      # puts "PLAYER UPDATE HERE - momentum ANGLE: #{@angle}"
      x_diff, y_diff, halt = self.movement(speed, @angle)
      if false #halt
        @current_momentum = 0
      else
        @current_momentum -= 1 * @fps_scaler
        @current_momentum = 0 if @current_momentum < 0
      end
    elsif @current_momentum < 0.0
      speed = (@ship.mass / 10.0) * (@current_momentum / 10.0) / 90.0
      garbage1, garbage2, halt = self.movement(-speed, @angle + 180)
      if false #halt
        @current_momentum = 0
      else
        @current_momentum += 1 * @fps_scaler
        @current_momentum = 0 if @current_momentum > 0
      end
    end
  end

end
