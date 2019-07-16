require_relative 'general_object.rb'
class Cursor < GeneralObject
  attr_accessor :x, :y, :image_width_half, :image_height_half
  attr_reader   :current_map_pixel_x, :current_map_pixel_y


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/crosshair.png")
  end

  
  def initialize screenx, screeny, width_scale, height_scale, owner
    @width_scale  = width_scale
    @height_scale = height_scale
    @screen_pixel_width  = screenx
    @screen_pixel_height = screeny
    @scale = (height_scale + width_scale) / 2
    @image = get_image
    @image_width  = @image.width  * width_scale
    @image_height = @image.height * height_scale
    @image_width_half  = @image_width  / 2
    @image_height_half = @image_height / 2
    @x = 0
    @y = 0

    @current_map_pixel_x = 0
    @current_map_pixel_y = 0

    @health_unit_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_cursor_unit.png")
    @owner_max_health = owner.max_health
    @owner_health     = owner.health
    # @health_angle_increments = 360.0 / (@owner_max_health / 10.0)
    @health_angle_increment = @owner_max_health / 25.0
    # @radius = @image_width_half + (@image_width_half / 10.0)
    @height_scaler_with_health_unit_image = @height_scale / 8.0


    @steam_unit_image      = Gosu::Image.new("#{MEDIA_DIRECTORY}/steam_cursor_unit.png")
    @steam_used_unit_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/steam_cursor_used_unit.png")
    @owner_steam_max_capacity     = owner.get_steam_max_capacity
    @owner_current_steam_capacity = owner.current_steam_capacity
    @steam_angle_increment        = @owner_steam_max_capacity / 25.0
    @health_colors = Gosu::Color.argb(0xee_ffffff)
    @steam_colors = Gosu::Color.argb(0x88_ffffff)

  #     puts "TEST123"
  #     puts [
  # @owner_steam_max_capacity,
  # @owner_current_steam_capacity,
  # @steam_angle_increment
  #     ]
# TEST123
# 150.0
# 50.0
# 3.3333333333333335

    # TEST
    # @image2 = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/earth_3.png", :tileable => true)
    # @info2 = @image2.gl_tex_info

  end


  def draw
    @image.draw(@x - @image_width_half, @y - @image_height_half, ZOrder::Cursor, @height_scale, @height_scale)

    health_counter = 0.0
    # current_angle  = 11.0
    current_angle  = -165.0
    while @owner_health > 0 && health_counter <= @owner_health
      # draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
      @health_unit_image.draw_rot(@x, @y, ZOrder::Cursor, current_angle, 0.5, 4, @height_scaler_with_health_unit_image, @height_scaler_with_health_unit_image, @health_colors)

      health_counter += @health_angle_increment
      current_angle  += 6
    end

    steam_counter = 0.0
    current_angle  = 15.0
    while @owner_steam_max_capacity > 0 && steam_counter <= @owner_steam_max_capacity
      if steam_counter < @owner_steam_max_capacity - @owner_current_steam_capacity
        @steam_used_unit_image.draw_rot(@x, @y, ZOrder::Cursor, current_angle, 0.5, 4, @height_scaler_with_health_unit_image, @height_scaler_with_health_unit_image, @steam_colors)
      else
        @steam_unit_image.draw_rot(@x, @y, ZOrder::Cursor, current_angle, 0.5, 4, @height_scaler_with_health_unit_image, @height_scaler_with_health_unit_image, @steam_colors)
      end

      steam_counter += @steam_angle_increment
      current_angle += 6
    end
  end

  def draw_gl
    # # # Y is reversed?
    # result = convert_screen_to_opengl(@x, @screen_pixel_height - (@y), 10, 10)
    # opengl_coord_x = result[:o_x]
    # opengl_coord_y = result[:o_y]
    # opengl_increment_x = result[:o_w]
    # opengl_increment_y = result[:o_h]
    # # puts "CURSOR OPENGL = #{opengl_coord_x} - #{opengl_coord_y} - w and h: #{opengl_increment_x} - #{opengl_increment_y}"

    # # z = -10 makes us even at the x axis
    # z = -10

    # colors = [1, 0.5, 1, 1]
    # colors = [1, 0.5, 1, 1]
    # glBegin(GL_TRIANGLE_STRIP)
    #   vert_pos = [opengl_coord_x , opengl_coord_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

    #   vert_pos = [opengl_coord_x , opengl_coord_y + opengl_increment_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

    #   vert_pos = [opengl_coord_x + opengl_increment_x , opengl_coord_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

    #   vert_pos = [opengl_coord_x + opengl_increment_x , opengl_coord_y + opengl_increment_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])
    # glEnd
  end

  def get2dPoint(o_x, o_y, o_z, viewMatrix, projectionMatrix, screen_pixel_width, screen_pixel_height)
    viewProjectionMatrix = projectionMatrix * viewMatrix
    # //transform world to clipping coordinates
    point3D = viewProjectionMatrix.vector_mult([o_x, o_y, o_z]);
    x = Math.round((( point3D[0] + 1 ) / 2.0) * screen_width );
    # //we calculate -point3D.getY() because the screen Y axis is
    # //oriented top->down 
    y = Math.round((( 1 - point3D[1] ) / 2.0) * screen_height );
    # doesn't point3D[2] do anything? Depth?
    return [x, y];
  end


  def convert_screen_to_opengl x, y, w = nil, h = nil
    opengl_x   = ((x / (@screen_pixel_width.to_f )) * 2.0) - 1
    # opengl_x   = opengl_x * 1.2 # Needs to be boosted for some odd reason - Screen is not entirely 1..-1
    opengl_y   = ((y / (@screen_pixel_height.to_f)) * 2.0) - 1
    # opengl_y   = opengl_y * 0.92
    if w && h
      open_gl_w  = ((w / (@screen_pixel_width.to_f )) * 2.0)
      open_gl_h  = ((h / (@screen_pixel_height.to_f )) * 2.0)
      return {o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}
    else
      return {o_x: opengl_x, o_y: opengl_y}
    end
  end

  # THESE ARE ON-SCREEN COORDS, NOT OPENGL COORDS
  def convert_x_and_y_to_opengl_coords
    middle_x = @screen_pixel_width.to_f / 2.0

    middle_y = @screen_pixel_height.to_f / 2.0
    increment_x = 1.0 / middle_x
    # The zoom issue maybe, not quite sure why we need the Y offset.
    increment_y = (1.0 / middle_y)
    new_pos_x = (@x.to_f - middle_x) * increment_x
    new_pos_y = (@y.to_f - middle_y) * increment_y
    # Inverted Y
    new_pos_y = new_pos_y * -1

    return [new_pos_x, new_pos_y, increment_x, increment_y]
  end

  def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, owner, viewable_pixel_offset_x, viewable_pixel_offset_y
    @x = mouse_x
    @y = mouse_y

    # need to update these on ship refresh.. or right now
    @owner_max_health = owner.max_health
    @health_angle_increment = @owner_max_health / 25.0
    @owner_health     = owner.health

    @owner_steam_max_capacity     = owner.get_steam_max_capacity
    @owner_current_steam_capacity = owner.current_steam_capacity
    @steam_angle_increment        = @owner_steam_max_capacity / 25.0

    @current_map_pixel_x = player_map_pixel_x + (mouse_x * -1) +  (@screen_pixel_width  / 2) + viewable_pixel_offset_x
    @current_map_pixel_y = player_map_pixel_y + (mouse_y     ) -  (@screen_pixel_height / 2) + viewable_pixel_offset_y
    # puts "CURSOR X: #{@x}"
    # puts "CURSOR Y: #{@y}"
    new_pos_x, new_pos_y, increment_x, increment_y = convert_x_and_y_to_opengl_coords
    # puts "START CURSOR"
    # puts "  new_pos_x: #{new_pos_x}"
    # puts "  new_pos_y: #{new_pos_y}"
    # puts "  increment_x: #{increment_x}"
    # puts "  increment_y: #{increment_y}"
    # puts "END CURSOR"
  end

end