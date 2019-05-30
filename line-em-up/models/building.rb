require_relative 'general_object.rb'

class Building < GeneralObject
  POINT_VALUE_BASE = 1
  attr_accessor :health, :armor, :x, :y
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

  def self.alt_draw_gl v1, v2, v3, v4
    @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
    @info = @image2.gl_tex_info

    # # result = convert_screen_to_opengl(@x, @screen_height - (@y), @image_width,  @image_height)
    # # puts "X and Y INDEX: #{x_index} - #{y_index}"
    # # puts "RESULT HERE: #{result}"
    # opengl_coord_x = o_x
    # opengl_coord_y = o_y
    # # opengl_coord_y = opengl_coord_y * -1
    # # opengl_coord_x = opengl_coord_x * -1
    # opengl_increment_x = o_w
    # opengl_increment_y = o_h
    # # puts "BULDING OPENGL = #{opengl_coord_x} - #{opengl_coord_y} - w and h: #{opengl_increment_x} - #{opengl_increment_y}"

    # z = @z || 1

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