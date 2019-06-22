require_relative 'building.rb'

class Landwreck < Building
  def initialize current_map_tile_x, current_map_tile_y, item, current_scale, options
    @item = item
    @image = @item.class.get_tilable_image(@item.class::ITEM_MEDIA_DIRECTORY)
    @info = @image.gl_tex_info
    # @image = @item.class.get_image
    @current_scale = current_scale
    super(current_map_tile_x, current_map_tile_y, options)
  end


  def draw viewable_pixel_offset_x, viewable_pixel_offset_y
    #do nothing
  end

  def alt_draw vert0, vert1, vert2, vert3, general_height, viewMatrix, projectionMatrix, viewport

    # @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
    # @info = @image2.gl_tex_info

    # o_width =  vert0[0] - (vert0[0] - vert2[0])
    # o_height = vert2[1] + (vert2[1] - vert3[1])
    # o_width_quarter  =  0 #o_width  / 4.0
    # o_height_quarter =  0 #o_height / 4.0

    # info = @info
    # colors = [1, 1, 1, 1]
    # glBindTexture(GL_TEXTURE_2D, info.tex_name)
    # glBegin(GL_TRIANGLE_STRIP)
    #   # bottom left 
    #   glTexCoord2d(info.left, info.bottom)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert0[0] + o_width_quarter, vert0[1] + o_height_quarter, vert0[2])

    #   # Top Left
    #   glTexCoord2d(info.left, info.top)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert1[0] + o_width_quarter, vert1[1] - o_height_quarter, vert1[2])

    #   # bottom Right
    #   glTexCoord2d(info.right, info.bottom)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert2[0] - o_width_quarter, vert2[1] + o_height_quarter, vert2[2])

    #   # top right
    #   glTexCoord2d(info.right, info.top)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert3[0] - o_width_quarter, vert3[1] - o_height_quarter, vert3[2])
    # glEnd

    # # X and Y are updated 


    # # @x_offset, @y_offset
    # # @tile_pixel_width
    # # @tile_pixel_height
    # # o_width  = vert0[0] - (vert0[0] - vert2[0])
    # # o_height = vert2[1] + (vert2[1] - vert3[1])


    # # # PRE gps_map_center_y: 122
    # # # POST gps_map_center_y: 121
    # # # PIXEL: [13556, 13556]
    # # # GPS: [120, 120]
    # # # TILE PIXEL: [112.5, 112.5]
    # # # Landwreck O OFFSETS: [0.4376389805415412, -0.24449473427356722]

    # # o_x_offset = (@x_offset * o_width)  / (@tile_pixel_width )
    # # o_y_offset = (@y_offset * o_height) / (@tile_pixel_height)
    # # puts "Landwreck O OFFSETS: #{[o_x_offset, o_y_offset]}"

    # update_from_3D(vert0, vert1, vert2, vert3, general_height, viewMatrix, projectionMatrix, viewport)

    # @item.draw(0, 0, @current_scale)

    # # @image.draw((@x - get_width / 2) + @x_offset, (@y - get_height / 2) + @y_offset, 1, @width_scale, @height_scale)

    # # result = convert3DTo2D(o_x, o_y, o_z, viewMatrix, projectionMatrix, viewport)
    # # puts "RESULT"
    # # puts result
    # # raise "STOP"
  end
end