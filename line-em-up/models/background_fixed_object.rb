# A 3D object. Currently Can't move around the map.
# Used location_x, location_y to occupy that tile on the background map
# Only uses X and Y for pixel placement. X and Y depend on where they are in relation to the player.
# Doesn't use X and Y for pixel placement, the background object will insert them.
# Used by buildings, pickups
class BackgroundFixedObject < GeneralObject

  def initialize(current_map_tile_x, current_map_tile_y, options = {})
    # validate_array([], self.class.name, __callee__)
    # validate_string([], self.class.name, __callee__)
    # validate_float([], self.class.name, __callee__)
    # validate_int([], self.class.name, __callee__)
    # validate_not_nil([], self.class.name, __callee__)

    # validate_int([screen_pixel_width, screen_pixel_height, current_map_tile_x, current_map_tile_y], self.class.name, __callee__)
    # validate_float([width_scale, height_scale], self.class.name, __callee__)
    # validate_not_nil([width_scale, height_scale, screen_pixel_width, screen_pixel_height, current_map_tile_x, current_map_tile_y], self.class.name, __callee__)

    super(options)

    @current_map_tile_x  = current_map_tile_x
    @current_map_tile_y  = current_map_tile_y

    get_map_pixel_location_from_map_tile_location

    # if options[:relative_y_padding]
      # puts "options[:relative_y_padding]: #{options[:relative_y_padding]}"
    # end

    # For objects that don't take damage, they'll never get hit by anything due to having 0 health
    @health = self.class.get_initial_health

    # @x_offset_base = relative_object_offset_x || 0
    # @y_offset_base = relative_object_offset_y || 0
  end

  def update mouse_x, mouse_y, player
    @time_alive += 1
    # Might not be necessary for buildings....
    convert_map_pixel_location_to_screen(player)
    # no need to update tile or pixel location
    # super(mouse_x, mouse_y, player)
    return is_alive
  end
end