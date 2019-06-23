require_relative 'building.rb'

class Landwreck < Building
  CLASS_TYPE = :landwreck

  attr_accessor :drops

  def initialize current_map_tile_x, current_map_tile_y, item, current_scale, angle = 0, drops = [], options = {}
    puts "LANDWRECK SCALE: #{current_scale}"
    @item = item
    @image = @item.class.get_tilable_image(@item.class::ITEM_MEDIA_DIRECTORY)
    @info = @image.gl_tex_info

    @drops = drops

    super(current_map_tile_x, current_map_tile_y, options)

    # if @image
    #   @image_width  = @image.width  * (@width_scale  || @average_scale)
    #   @image_height = @image.height * (@height_scale || @average_scale)
    #   @image_size   = @image_width  * @image_height / 2
    #   @image_radius = (@image_width  + @image_height) / 4

    #   @image_width_half  = @image_width  / 2
    #   @image_height_half = @image_height / 2
    # end
    @colors = [1, 1, 1, 1]

    @current_scale = current_scale * 1.5
    @current_angle = angle


    # result = GeneralObject.convert_screen_pixels_to_opengl(@screen_pixel_width, @screen_pixel_height, screen_x, screen_y, @tile_pixel_width, @tile_pixel_height)
    # # puts "X and Y INDEX: #{x_index} - #{y_index}"
    # # puts "RESULT HERE: #{result}"
    # @opengl_coord_x = result[:o_x]
    # @opengl_coord_y = result[:o_y]
    # # opengl_coord_y = opengl_coord_y * -1
    # # opengl_coord_x = opengl_coord_x * -1
    # @opengl_increment_x = result[:o_w]
    # @opengl_increment_y = result[:o_h]
    @health = 1

    @click_area = LUIT::ClickArea.new(@window, key, current_x, current_y, ZOrder::HardPointClickableLocation, @cell_width, @cell_height)

  end

  def update mouse_x, mouse_y, player
    # if is_on_screen?
    #   # Update from gl_background
    # else
    #   # lol don't need to update x and y if off screen.
    #   # convert_map_pixel_location_to_screen(player)
    #   get_map_pixel_location_from_map_tile_location
    # end
    return super(mouse_x, mouse_y, player)
  end

  def draw viewable_pixel_offset_x,  viewable_pixel_offset_y
    if @item.image
      @item.image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, ZOrder::Building, -@current_angle, 0.5, 0.5, @current_scale, @current_scale)
    end
  end

  # def draw viewable_pixel_offset_x, viewable_pixel_offset_y
  #   #do nothing
  # end

  def alt_alt_draw opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y, general_height
    # do nothing yet
  end

  # def alt_draw vert0, vert1, vert2, vert3, general_height, viewMatrix, projectionMatrix, viewport
  def alt_draw opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y, general_height
    # # opengl_increment_x_half = opengl_increment_x / 2.0
    # # opengl_increment_y_half = opengl_increment_y / 2.0
    # # @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
    # # @info = @image2.gl_tex_info

    # # o_width =  vert0[0] - (vert0[0] - vert2[0])
    # # o_height = vert2[1] + (vert2[1] - vert3[1])
    # # o_width_quarter  =  o_width  / 4.0
    # # o_height_quarter =  o_height / 4.0



    # info = @info
    # colors = @colors
    # glBindTexture(GL_TEXTURE_2D, info.tex_name)
    # glBegin(GL_TRIANGLE_STRIP)
    #   # bottom left 
    #   glTexCoord2d(info.left, info.bottom)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(opengl_coord_x, vopengl_coord_y, general_height)

    #   # Top Left
    #   glTexCoord2d(info.left, info.top)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(opengl_coord_x, opengl_coord_y, general_height

    #   # bottom Right
    #   glTexCoord2d(info.right, info.bottom)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(opengl_coord_x, opengl_coord_y, general_height)

    #   # top right
    #   glTexCoord2d(info.right, info.top)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(opengl_coord_x, opengl_coord_y, general_height)
    # glEnd

    # # # X and Y are updated 


    # # # @x_offset, @y_offset
    # # # @tile_pixel_width
    # # # @tile_pixel_height
    # # # o_width  = vert0[0] - (vert0[0] - vert2[0])
    # # # o_height = vert2[1] + (vert2[1] - vert3[1])


    # # # # PRE gps_map_center_y: 122
    # # # # POST gps_map_center_y: 121
    # # # # PIXEL: [13556, 13556]
    # # # # GPS: [120, 120]
    # # # # TILE PIXEL: [112.5, 112.5]
    # # # # Landwreck O OFFSETS: [0.4376389805415412, -0.24449473427356722]

    # # # o_x_offset = (@x_offset * o_width)  / (@tile_pixel_width )
    # # # o_y_offset = (@y_offset * o_height) / (@tile_pixel_height)
    # # # puts "Landwreck O OFFSETS: #{[o_x_offset, o_y_offset]}"

    # # update_from_3D(vert0, vert1, vert2, vert3, general_height, viewMatrix, projectionMatrix, viewport)

    # # @item.draw(0, 0, @current_scale)

    # # # @image.draw((@x - get_width / 2) + @x_offset, (@y - get_height / 2) + @y_offset, 1, @width_scale, @height_scale)

    # # # result = convert3DTo2D(o_x, o_y, o_z, viewMatrix, projectionMatrix, viewport)
    # # # puts "RESULT"
    # # # puts result
    # # raise "STOP"
  end
end