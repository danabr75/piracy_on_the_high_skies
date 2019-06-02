require_relative 'general_object.rb'

require 'opengl'
require 'glut'

include OpenGL
include GLUT
include GLU # - defined gluProject

class Building < GeneralObject
  POINT_VALUE_BASE = 1
  attr_accessor :health, :armor, :x, :y, :z
  attr_accessor :x_offset, :y_offset


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png")
  end

  # X and Y are place on screen.
  # Location Y and X are where they are on GPS
  def initialize(scale, x, y, screen_width, screen_height, width_scale, height_scale, location_x = nil, location_y = nil, map_height = nil, map_width = nil, options = {})
    # puts "BUILDING NEW"
    super(scale, x, y, screen_width, screen_height, width_scale, height_scale, location_x, location_y, map_height, map_width, options)
    @health = 15
    @armor = 0
    @z = options[:z] || 1
    # raise "Z HERE: #{@z}"
    @x_offset = 0
    @y_offset = 0
    @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
    @info = @image2.gl_tex_info
  end

  def get_points
    return POINT_VALUE_BASE
  end

  def is_alive
    @health > 0
  end

  def take_damage damage
    @health -= damage
  end

  def drops
    rand_num = rand(10)
    if rand(10) == 9
      [HealthPack.new(@scale, @screen_width, @screen_height, @x, @y)]
    elsif rand(10) == 8
      [BombPack.new(@scale, @screen_width, @screen_height, @x, @y)]
    else
      [MissilePack.new(@scale, @screen_width, @screen_height, @x, @y)]
    end
  end

  def get_draw_ordering
    ZOrder::Building
  end

  def draw
    # puts "BUILDING DRAW - #{@z}"
    @image.draw((@x - get_width / 2) + @x_offset, (@y - get_height / 2) + @y_offset, @z, @width_scale, @height_scale)
  end


  # https://stackoverflow.com/questions/8491247/c-opengl-convert-world-coords-to-screen2d-coords
  # vec4 clipSpacePos = projectionMatrix * (viewMatrix * vec4(point3D, 1.0));
  # not sure if include_adjustments_for_not_exact_opengl_dimensions works yet or not
  # def self.convert_opengl_to_screen opengl_x, opengl_y, include_adjustments_for_not_exact_opengl_dimensions = false
  #   opengl_x = 1.2 / opengl_x if opengl_x != 0 && include_adjustments_for_not_exact_opengl_dimensions
  #   x = ((opengl_x + 1) / 2.0) * @screen_width.to_f
  #   opengl_y = 0.92 / opengl_y if opengl_y != 0 && include_adjustments_for_not_exact_opengl_dimensions
  #   y = ((opengl_y + 1) / 2.0) * @screen_height.to_f
  #   return [x, y]
  # end

  def convert_screen_to_opengl x, y, w = nil, h = nil
    opengl_x   = ((x / (@screen_width.to_f )) * 2.0) - 1
    opengl_x   = opengl_x * 1.2 # Needs to be boosted for some odd reason - Screen is not entirely 1..-1
    opengl_y   = ((y / (@screen_height.to_f)) * 2.0) - 1
    opengl_y   = opengl_y * 0.92
    if w && h
      open_gl_w  = ((w / (@screen_width.to_f )) * 2.0)
      open_gl_h  = ((h / (@screen_height.to_f )) * 2.0)
      return {o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}
    else
      return {o_x: opengl_x, o_y: opengl_y}
    end
  end

    # DRAWV4 - [0.25, 0.9807777777777098, 1.25]
    # RETURNING2: [562.5, 891.3499999999694, 1]

    # DRAWV4 - [0.25, 0.0, 1.25]
    # RETURNING2: [562.5, 450.0, 1]


    # OFFSCREEN

    # DRAWV4 - [0.25, -0.6684166666666838, 1.25]
    # RETURNING2: [562.5, 149.2124999999923, 1]

  def self.drawv4(ox, oy, oz, view_matrix, projection_matrix, viewport)
    @image3 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building_2.png")
    x, y, z = convert3DTo2D(ox, oy, oz, view_matrix, projection_matrix, viewport)
    @image3.draw(x, 900.0 - y, z, 2, 2)
  end

  # def self.drawv5(ox, oy, oz)
  #   oy = oy * -1.0
  #   @image3 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building_2.png")
  #   # puts "BUILDING DRAW - #{@z}"
  #   puts "DRAWV5 - #{[ox, oy, oz]}"
  #   # oy = oy * -1
  #   # x, y = get2dPoint(ox, oy, oz, view_matrix, projection_matrix, 900.0, 900.0)
  #   z = 1
  #   x = ((( ox + 1 ) / 2.0) * 900.0 ) / oz
  #   y = ((( oy + 1 ) / 2.0) * 900.0 ) / oz
  #   puts "RETURNING2: #{[x, y, z]}"
  #   @image3.draw(x, y, z, 2, 2)
  # end

         # gluProject(ox, oy, oz, mdl_mtx, prj_mtx, vport, &wx, &wy, &wz) 


  # def self.convert_opengl_to_screen opengl_x, opengl_y, opengl_z, include_adjustments_for_not_exact_opengl_dimensions = false
  #   # puts "INCOMING: #{[opengl_x, opengl_y, opengl_z]]}"
  #   # opengl_x = 1.2 / opengl_x if opengl_x != 0 && include_adjustments_for_not_exact_opengl_dimensions
  #   x = ((opengl_x + 1) / 2.0) * 900.0 #@screen_width.to_f
  #   # opengl_y = 0.92 / opengl_y if opengl_y != 0 && include_adjustments_for_not_exact_opengl_dimensions
  #   y = ((opengl_y + 1) / 2.0) * 900.0 #@screen_height.to_f
  #   # puts "PRE VALUE: #{[x, y, opengl_z]}"
  #   y = y / opengl_z
  #   x = x / opengl_z
  #   return [x, y]
  # end


  def self.alt_draw_gl v1, v2, v3, v4
    @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
    @info = @image2.gl_tex_info

    info = @info
    colors = [1, 1, 1, 1]
    glBindTexture(GL_TEXTURE_2D, info.tex_name)
    glBegin(GL_TRIANGLE_STRIP)
      glTexCoord2d(info.left, info.top)
      glColor4d(colors[0], colors[1], colors[2], colors[3])
      glVertex3d(v1[0], v1[1], v1[2])

      glTexCoord2d(info.left, info.bottom)
      glColor4d(colors[0], colors[1], colors[2], colors[3])
      glVertex3d(v2[0], v2[1], v2[2])

      glTexCoord2d(info.right, info.top)
      glColor4d(colors[0], colors[1], colors[2], colors[3])
      glVertex3d(v3[0], v3[1], v3[2])

      glTexCoord2d(info.right, info.bottom)
      glColor4d(colors[0], colors[1], colors[2], colors[3])
      glVertex3d(v4[0], v4[1], v4[2])
    glEnd
  end

  def self.alt_alt_draw_gl v1, v2, v3, v4

    @image3 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png")
    # @info = @image2.gl_tex_info


    x, y = convert_opengl_to_screen(v1[0], v1[0])

    @image3.draw((x - @image3.width / 2), (y - @image3.height / 2), ZOrder::Building, 2, 2)

    # info = @info
    # colors = [1, 1, 1, 1]
    # glBindTexture(GL_TEXTURE_2D, info.tex_name)
    # glBegin(GL_TRIANGLE_STRIP)
    #   glTexCoord2d(info.left, info.top)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(v1[0], v1[1], v1[2])

    #   glTexCoord2d(info.left, info.bottom)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(v2[0], v2[1], v2[2])

    #   glTexCoord2d(info.right, info.top)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(v3[0], v3[1], v3[2])

    #   glTexCoord2d(info.right, info.bottom)
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(v4[0], v4[1], v4[2])
    # glEnd
  end


  def draw_gl

    # result = convert_screen_to_opengl(@x, @screen_height - (@y), @image_width,  @image_height)
    # # puts "X and Y INDEX: #{x_index} - #{y_index}"
    # # puts "RESULT HERE: #{result}"
    # opengl_coord_x = result[:o_x]
    # opengl_coord_y = result[:o_y]
    # # opengl_coord_y = opengl_coord_y * -1
    # # opengl_coord_x = opengl_coord_x * -1
    # opengl_increment_x = result[:o_w]
    # opengl_increment_y = result[:o_h]
    # puts "BULDING OPENGL = #{opengl_coord_x} - #{opengl_coord_y} - w and h: #{opengl_increment_x} - #{opengl_increment_y}"

    # z = @z || 1

    # info = @info
    # colors = [1, 1, 1, 1]
    # glBindTexture(GL_TEXTURE_2D, info.tex_name)
    # glBegin(GL_TRIANGLE_STRIP)
    #   glTexCoord2d(info.left, info.top)
    #   vert_pos = [opengl_coord_x , opengl_coord_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

    #   glTexCoord2d(info.left, info.bottom)
    #   vert_pos = [opengl_coord_x , opengl_coord_y + opengl_increment_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

    #   glTexCoord2d(info.right, info.top)
    #   vert_pos = [opengl_coord_x + opengl_increment_x , opengl_coord_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

    #   glTexCoord2d(info.right, info.bottom)
    #   vert_pos = [opengl_coord_x + opengl_increment_x , opengl_coord_y + opengl_increment_y , z]
    #   glColor4d(colors[0], colors[1], colors[2], colors[3])
    #   glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])
    # glEnd
  end

  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    # puts "BUILDING UPDATE"
    if is_alive
    #   @y += @current_speed * scroll_factor
    #   @y < @screen_height + get_height
    # else
    #   false
    end
    true
  end
end