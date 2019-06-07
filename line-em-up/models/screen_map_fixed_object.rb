# A 2D object, can move around the map.
# Uses current_map_pixel_x and current_map_pixel_y for tracking.
# Only uses X and Y for pixel placement, not for location tracking. X and Y depend on where they are in relation to the player.
# Used by projectiles, enemies, tumbleweeds, etc.
class ScreenMapFixedObject < GeneralObject
 # def initialize(current_map_pixel_x, current_map_pixel_y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, options = {})
 # Use tile tracking so we know when to load them into the visible map
 def initialize(current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, options = {})
    # validate_array([], self.class.name, __callee__)
    # validate_string([], self.class.name, __callee__)
    # validate_float([], self.class.name, __callee__)
    # validate_int([], self.class.name, __callee__)
    # validate_not_nil([], self.class.name, __callee__)

    # validate_int([screen_pixel_width, screen_pixel_height, current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, map_pixel_width, map_pixel_height], self.class.name, __callee__)
    # validate_float([width_scale, height_scale], self.class.name, __callee__)
    # validate_not_nil([width_scale, height_scale, screen_pixel_width, screen_pixel_height, current_map_tile_x, current_map_tile_y, map_pixel_width, map_pixel_height], self.class.name, __callee__)

    # def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, map_pixel_width, map_pixel_height, map_tile_width, map_tile_height, tile_pixel_width, tile_pixel_height, options = {})
    super(options)
    # Only use ID in debug\test
    @current_map_pixel_x = current_map_pixel_x
    @current_map_pixel_y = current_map_pixel_y
    @current_map_tile_x  = current_map_tile_x
    @current_map_tile_y  = current_map_tile_y


    # Player might be in one tile, and weapon might stretch into another. Need to recalc, can't just use players location.
    # By default, starting in the center of the tile
    if @current_map_pixel_x.nil? || @current_map_pixel_y.nil?
      @current_map_pixel_x = ((@current_map_tile_x * @tile_pixel_width)  + @tile_pixel_width  / 2).to_i
      @current_map_pixel_y = ((@current_map_tile_y * @tile_pixel_height) + @tile_pixel_height / 2).to_i
    end


    # Validate that the object pixels and tiles match
    # within outer and inner bounds.
    # check x, starting from the left, going to the right
    # inner_x_bound: 14062.5 < 14175.0 (RuntimeError)
    outer_x_bound = (@tile_pixel_width * (@current_map_tile_x)) + @tile_pixel_width
                        # 14175.0 = (112.5 * (125)) + 112.5
    inner_x_bound = (@tile_pixel_width * (@current_map_tile_x))
    puts "inner_x_bound = (@tile_pixel_width * (@current_map_tile_x)) + @tile_pixel_width"
    puts "#{inner_x_bound} = (#{@tile_pixel_width} * (#{@current_map_tile_x})) + #{@tile_pixel_width}"
    # inner_x_bound: 14062.5 < 14175.0 (RuntimeError)
    # inner_x_bound = (@tile_pixel_width * (@map_tile_width - @current_map_tile_x)) + @tile_pixel_width
    # outer_x_bound = (@tile_pixel_width * (@map_tile_width - @current_map_tile_x))
    raise "@current_map_pixel_x > outer_x_bound: #{@current_map_pixel_x} > #{outer_x_bound}" if @current_map_pixel_x > outer_x_bound
    raise "@current_map_pixel_x < inner_x_bound: #{@current_map_pixel_x} < #{inner_x_bound}" if @current_map_pixel_x < inner_x_bound

    outer_y_bound = (@tile_pixel_height * @current_map_tile_y) + @tile_pixel_height
    inner_y_bound = (@tile_pixel_height * @current_map_tile_y)
    raise "@current_map_pixel_y > outer_y_bound: #{@current_map_pixel_y} > #{outer_y_bound}" if @current_map_pixel_x > outer_y_bound
    raise "@current_map_pixel_y < inner_y_bound: #{@current_map_pixel_y} < #{inner_y_bound}" if @current_map_pixel_y < inner_y_bound

    # For objects that don't take damage, they'll never get hit by anything due to having 0 health
    @health = 0
  end
end