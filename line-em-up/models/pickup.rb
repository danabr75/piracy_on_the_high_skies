# require_relative 'background_fixed_object.rb'

# class Pickup < BackgroundFixedObject

#   def get_draw_ordering
#     ZOrder::Pickups
#   end

#   # Most classes will want to just override this
#   def draw viewable_pixel_offset_x,  viewable_pixel_offset_y
#     @image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, ZOrder::Pickups, @y, 0.5, 0.5, @height_scale, @height_scale)
#   end


#   def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
#     get_map_pixel_location_from_map_tile_location
#     return super(mouse_x, mouse_y, player, {persist_even_if_not_alive: true})
#   end
#  # COLLICION RETURNING DROPS: [#<HealthPack:0x00007f9e29953430 @tile_pixel_width=112.5, @tile_pixel_height=112.5, @map_pixel_width=28125, @map_pixel_height=28125, @map_tile_width=250, @map_tile_height=250, @width_scale=1.875, @height_scale=1.875, @screen_pixel_width=900, @screen_pixel_height=900, @debug=true, @damage_increase=1, @average_scale=1.7578125, @id="aa758e36-b929-4939-bf8d-89d9a9628abe", @i


#   def collected_by_player player
#     raise "Override me!"
#   end

# end