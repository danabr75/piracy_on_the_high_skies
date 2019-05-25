require 'gosu'
# # require 'opengl'
# # require 'glu'

# require 'opengl'
# require 'glut'

require 'opengl'
require 'glut'

include OpenGL
include GLUT
# For opengl-bindings
# OpenGL.load_lib()
# GLUT.load_lib()


class GLBackground
  # Height map size
  # MAP_HEIGHT_EDGE = 700
  # MAP_WIDTH_EDGE_RIGHT = 450
  # MAP_WIDTH_EDGE_LEFT  = 80
  EXTERIOR_MAP_HEIGHT = 500
  EXTERIOR_MAP_WIDTH  = 500
  # POINTS_X = 7
  VISIBLE_MAP_WIDTH = 15
  # outside of view padding

  EXTRA_MAP_WIDTH   = 3
  # POINTS_Y = 7

  # CAN SEE EDGE OF BLACK MAP AT PLAYER Y 583
  # 15 tiles should be on screen
  VISIBLE_MAP_HEIGHT = 15
  # outside of view padding
  EXTRA_MAP_HEIGHT   = 3
  # Scrolling speed - higher it is, the slower the map moves
  SCROLLS_PER_STEP = 50
  # TEMP USING THIS, CANNOT FIND SCROLLING SPEED
  SCROLLING_SPEED = 4

  # attr_accessor :player_position_x, :player_position_y
  attr_accessor :global_map_width, :global_map_height
  attr_accessor :screen_tile_width, :screen_tile_height

  # tile size is 1 GPS (location_x, location_y)
  # Screen size changes. At 900x900, it should be 900 (screen_width) / 15 (VISIBLE_MAP_WIDTH) = 60 pixels
  # OpenGL size (-1..1) should be (1.0 / 15.0 (VISIBLE_MAP_WIDTH)) - 1.0 

  def convert_screen_to_opengl x, y, w = nil, h = nil
    # puts "convert_screen_to_opengl"
    # puts "#{x} - #{y} - #{w} - #{h}"
    screen_to_opengl_increment_x = (2.0 / (@screen_width.to_f))
    screen_to_opengl_increment_y = (2.0 / (@screen_height.to_f))
    # puts "screen_to_opengl_increment: #{screen_to_opengl_increment_x} - #{screen_to_opengl_increment_y}"
    opengl_x   = (x * screen_to_opengl_increment_x) - 1
    opengl_y   = (y * screen_to_opengl_increment_y) - 1
    if w && h
      open_gl_w  = (w * screen_to_opengl_increment_x)
      open_gl_h  = (h * screen_to_opengl_increment_y)
      return {o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}
    else
      return {o_x: opengl_x, o_y: opengl_y}
    end
  end

  def initialize player_x, player_y, screen_width, screen_height, width_scale, height_scale
    @time_alive = 0
    @y_add_top_tracker = []
    # @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/earth.png", :tileable => true)

    # These are the width and length of each background tile
    @opengl_increment_y = 1 / (VISIBLE_MAP_HEIGHT.to_f / 4.0)
    @opengl_increment_x = 1 / (VISIBLE_MAP_WIDTH.to_f  / 4.0)

    @width_scale  = width_scale
    @height_scale = height_scale

    # background openGLK window size is 0.5 (-.25 .. .25)
    puts "screen_width: #{screen_width}"
    # IN OPENGL terms
    # @open_gl_screen_movement_increment_x = 1 / ((screen_width.to_f / VISIBLE_MAP_WIDTH.to_f)  - (screen_width.to_f / VISIBLE_MAP_WIDTH.to_f) / 4.0 )#(screen_width  / VISIBLE_MAP_WIDTH)  / 4
    # @open_gl_screen_movement_increment_y = 1 / ((screen_height.to_f / VISIBLE_MAP_HEIGHT.to_f)  - (screen_height.to_f / VISIBLE_MAP_HEIGHT.to_f) / 4.0 )#(screen_height / VISIBLE_MAP_HEIGHT) / 4

    # SCREEN COORD SYSTEM 480 x 480
    # @on_screen_movement_increment_x = ((screen_width.to_f  / VISIBLE_MAP_WIDTH.to_f)  / 2.0)     #(screen_width  / VISIBLE_MAP_WIDTH)  / 4
    # @on_screen_movement_increment_y = ((screen_height.to_f / VISIBLE_MAP_HEIGHT.to_f) / 2.0)     #(screen_height / VISIBLE_MAP_HEIGHT) / 4

    # OPENGL SYSTEM -1..1
    # @open_gl_screen_movement_increment_x = (1 / (@on_screen_movement_increment_x))  - (@on_screen_movement_increment_x / 2.0)
    # @open_gl_screen_movement_increment_y = (1 / (@on_screen_movement_increment_y))  - (@on_screen_movement_increment_y / 2.0)
    @open_gl_screen_movement_increment_x = (1 / (VISIBLE_MAP_WIDTH.to_f  )) / 2.0
    @open_gl_screen_movement_increment_y = (1 / (VISIBLE_MAP_HEIGHT.to_f )) / 2.0
 
    puts "SCREEN W AND H: #{screen_width} - #{screen_height}"
    puts "SCALES: #{width_scale} and #{height_scale}"
    # puts "MOVEMENT INCREMENTS: #{@on_screen_movement_increment_x} - #{@on_screen_movement_increment_y}"
    # raise "STOP HERE"
    # Need to convert on_screen to GPS
    # puts "INIT: @screen_movement_increment: #{@on_screen_movement_increment_x} - #{@on_screen_movement_increment_y}"


    # splits across middle 0  -7..0..7
    # new_x_index = x_index - (x_max / 2.0)
    # new_y_index = y_index - (y_max / 2.0)
    # convert to 
    # split across center index, divided by half of center abs / 2
    # (-7 / 3.5) / 2.0
    # (-1 / 3.5) / 2.0
    # -1

    # Replace scrolling meter
    @global_sized_terrain_width = (@opengl_increment_x * 2)


    @screen_width = screen_width
    @screen_height = screen_height
    @screen_height_half = @screen_height / 2
    @screen_width_half = @screen_width / 2

    @screen_tile_width  = @screen_width  / VISIBLE_MAP_WIDTH.to_f
    @screen_tile_height = @screen_height / VISIBLE_MAP_HEIGHT.to_f

    # @ratio = @screen_width.to_f / (@screen_height.to_f)

    # increment_x = (ratio / middle_x) * 0.97
    # # The zoom issue maybe, not quite sure why we need the Y offset.
    # increment_y = (1.0 / middle_y) * 0.75

    @scrolls = 0.0
    @visible_map = Array.new(VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT) { Array.new(VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH) { nil } }
    @local_map_movement_x = 0
    @local_map_movement_y = 0

    # @global_map_height = EXTERIOR_MAP_HEIGHT
    # @global_map_width  = EXTERIOR_MAP_WIDTH
    # @player_position_x = EXTERIOR_MAP_HEIGHT / 2.0
    # @player_position_y = EXTERIOR_MAP_WIDTH  / 2.0
    # @current_map_center_y = EXTERIOR_MAP_HEIGHT / 2.0
    # @current_map_center_x = EXTERIOR_MAP_WIDTH  / 2.0
    @current_map_center_x = player_x
    @current_map_center_y = player_y
    @map = JSON.parse(File.readlines("/Users/bendana/projects/line-em-up/line-em-up/maps/desert.txt").first)
    @terrains = @map["terrains"]
    @images = []
    @infos = []
    @image = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/earth.png", :tileable => true)
    @info = @image.gl_tex_info

    image = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/earth_0.png", :tileable => true)
    @images << image
    @infos << image.gl_tex_info

    @terrains.each do |terrain_path|
      image = Gosu::Image.new(terrain_path, :tileable => true)
      @images << image
      @infos  << image.gl_tex_info
    end
    image = Gosu::Image.new("/Users/bendana/projects/line-em-up/line-em-up/media/earth_3.png", :tileable => true)
    @images << image
    @infos << image.gl_tex_info

    @global_map_width =  EXTERIOR_MAP_WIDTH
    @global_map_height = EXTERIOR_MAP_HEIGHT
    # @global_map_width = @map["map_width"]
    # @global_map_height = @map["map_height"]
    @map_data = @map["data"]
    # puts "@map_data : #{@map_data[0][0]}" 
    # @visible_map = []
    # puts "TOP TRACKERL = player_y + (VISIBLE_MAP_HEIGHT / 2) + (EXTRA_MAP_HEIGHT / 2)"
    # puts "TOP TRACKERL = #{player_y} + (#{VISIBLE_MAP_HEIGHT} / 2) + (#{EXTRA_MAP_HEIGHT} / 2)"
    # raise 'stop'
    @y_top_tracker    = player_y + (VISIBLE_MAP_HEIGHT / 2) + (EXTRA_MAP_HEIGHT / 2)
    @y_bottom_tracker = player_y - (VISIBLE_MAP_HEIGHT / 2) - (EXTRA_MAP_HEIGHT / 2)
    (0..VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT - 1).each_with_index do |visible_height, index_h|
      y_offset = visible_height - VISIBLE_MAP_HEIGHT / 2
      y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
      @y_add_top_tracker << (player_y + y_offset)
      (0..VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
        x_offset = visible_width  - VISIBLE_MAP_WIDTH  / 2
        x_offset = x_offset - EXTRA_MAP_WIDTH / 2
        # REAL MAP DATA HERE
        # @visible_map[index_h][index_w] = @map_data[player_y + y_offset][player_x + x_offset]
        # TEST DATA HERE
        if index_h % 2 == 0
          if index_w  % 2 == 0
            @visible_map[index_h][index_w] = {'height' => rand, 'terrain_index' => 2 }
          else
            @visible_map[index_h][index_w] = {'height' => rand, 'terrain_index' => 0 }
          end
        else
          if index_w  % 2 == 0
            @visible_map[index_h][index_w] = {'height' => rand, 'terrain_index' => 3 }
          else
            @visible_map[index_h][index_w] = {'height' => rand, 'terrain_index' => 1 }
          end
        end
      end
    end
    @y_add_top_tracker << nil
    # puts @visible_map
  end

  def update player_x, player_y
    puts "BACKGROUND UPDATE: #{player_x} - #{player_y}" if @time_alive % 100 == 0
    @time_alive += 1

    # puts "PLAYER: #{player_x} - #{player_y}"
    # MOVEMENT IS ON GPS COORDS, NEED TO CONVERT TO ONSCREEN COORDS
    @local_map_movement_y = player_y - @current_map_center_y
    # puts "@local_map_movement_y = player_y - @current_map_center_y"
    # puts "#{@local_map_movement_y} = #{player_y} -#{ @current_map_center_y}"
    @local_map_movement_x = player_x - @current_map_center_x

    # puts "POST: local_map_movement_x: #{@local_map_movement_x}" 
    # puts "POST: local_map_movement_y: #{@local_map_movement_y}"


    # SCROLLS_PER_STEP !!!!! Need to factor in scale factor here!
    # NEED TO CONVERT ON SCREEN TO GPS MOVEMENTS
    # Need to fix this GPS to SCREEN CONVERTION - / 14 is a poor substitute    
    # ADDING TO THE TOP OF THE MAP. GPS will be EXTERIOR_MAP_HEIGHT if at the bottom.
    # puts "@y_add_top_tracker - #{@y_add_top_tracker}" if @time_alive % 100 == 0
    # puts "@y_add_top_tracker.length - #{@y_add_top_tracker.count}" if @time_alive % 100 == 0

    # 1 should be 1 GPS coord unit. No height scale should be on it.
    if @local_map_movement_y >= @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f# * @height_scale * 1.1
      puts "ADDING IN ARRAY 1 - local: #{@local_map_movement_y} > #{1.0 / VISIBLE_MAP_HEIGHT.to_f}"
      # y_offset = (VISIBLE_MAP_HEIGHT / 2) + EXTRA_MAP_HEIGHT / 2
      # y_top_edge = (@current_map_center_y + y_offset)
      # CEIL is the only way to get the top 1000 row of the map height.
      # Might just have to ... .round?
      # puts "TOP EDGE here: #{@y_top_tracker}"
      if @current_map_center_y < (@global_map_height) * @screen_tile_height
        # puts "CURRENT WAS LESS THAN EXTERNIOR: #{@current_map_center_y} - #{EXTERIOR_MAP_HEIGHT}"
        @y_top_tracker += 1
        @y_bottom_tracker += 1
        # value = nil
        # @y_add_top_tracker << @y_top_tracker
        # Show edge of map
        if @y_top_tracker > (@global_map_height)
          puts "ADDING IN EDGE OF MAP"
          @visible_map.pop
          # puts "@y_top_tracker > (EXTERIOR_MAP_HEIGHT - (EXTRA_MAP_HEIGHT / 2) - (VISIBLE_MAP_HEIGHT / 2))"
          # puts "#{@y_top_tracker} > (#{EXTERIOR_MAP_HEIGHT} - #{(EXTRA_MAP_HEIGHT / 2)} - #{(VISIBLE_MAP_HEIGHT / 2)})"
          @visible_map.unshift(Array.new(@global_map_height + EXTRA_MAP_HEIGHT) { {'height' => 1, 'terrain_index' => 3 } })
          # puts "EDGE MAP HERE: (EXTERIOR_MAP_HEIGHT - (EXTRA_MAP_HEIGHT / 2) - (VISIBLE_MAP_HEIGHT / 2))"
          # puts "#{(EXTERIOR_MAP_HEIGHT - (EXTRA_MAP_HEIGHT / 2) - (VISIBLE_MAP_HEIGHT / 2))} = (#{EXTERIOR_MAP_HEIGHT} - (#{EXTRA_MAP_HEIGHT} / 2) - (#{VISIBLE_MAP_HEIGHT} / 2))"
          # value = "EDGE MAP"
        else
          puts "ADDING NORMALLY"
          @visible_map.pop
          @visible_map.unshift(Array.new(@global_map_height + EXTRA_MAP_HEIGHT) { {'height' => rand, 'terrain_index' => 1 + rand(2) } })
          # value = "INSIDE MAP"
        end
        puts "MAP ADDED at #{@current_map_center_y} w/ - top tracker: #{@y_top_tracker}"
        @current_map_center_y = @current_map_center_y + @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_y = @local_map_movement_y - @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
      else
        # No need to load in new maps, but still need to advance the current_map_center coords.
        puts "MAP LIMIT REACHED, #{@current_map_center_y} was > #(@global_map_height * @screen_tile_height} -- local movement y: #{@local_map_movement_y}"
        # if @current_map_center_y < EXTERIOR_MAP_HEIGHT
        #   @current_map_center_y = @current_map_center_y + 1
        #   @local_map_movement_y = @local_map_movement_y - 1
        # else
          # Without this, you stick to the edge of the map?
          @local_map_movement_y = 0 if @local_map_movement_y > 0
          # @local_map_movement_y = 0
        # end
      end
    end






    # Adding to bottom of map
    # Convert on screen movement to map
    if @local_map_movement_y <= -@screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
      puts "ADDING IN ARRAY 2"
      if @current_map_center_y > 0
        @y_top_tracker -= 1
        @y_bottom_tracker -= 1
        # value = nil
        if @y_bottom_tracker < 0
          @visible_map.shift
          @visible_map.push Array.new(@global_map_width + EXTRA_MAP_WIDTH) { {'height' => rand, 'terrain_index' => 3 } }
          # value = "EDGE MAP"
        else
          @visible_map.shift
          @visible_map.push Array.new(@global_map_width + EXTRA_MAP_WIDTH) { {'height' => rand, 'terrain_index' => 1 + rand(2) } }
          # value = "INSIDE MAP"
        end
        # puts "MAP ADDED at #{@current_map_center_y} w/ #{value} - top tracker: #{@y_bottom_tracker}"
        @current_map_center_y = @current_map_center_y - @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_y = @local_map_movement_y - @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
      else
        @local_map_movement_y = 0 if @local_map_movement_y < 0
      end
    end








    # puts "@local_map_movement_y: #{@local_map_movement_y} and @on_screen_movement_increment_y: #{@on_screen_movement_increment_y}"
    # Need to fix this GPS to SCREEN CONVERTION - / 14 is a poor substitute
    # ADDING TO THE BOTTOM OF THE MAP.
    # if @local_map_movement_y <= -1.0# * @height_scale * 1.1
    #   if @y_bottom_tracker > 0
    #     @y_top_tracker -= 1
    #     @y_bottom_tracker += 1
    #     puts "ADDING IN ARRAY 2"
    #     @visible_map.shift
    #     @visible_map.push Array.new(VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH) { {'height' => rand, 'terrain_index' => rand(2) } }
    #     @current_map_center_y = @current_map_center_y - 1
    #     @local_map_movement_y = @local_map_movement_y + 1
    #   else
    #     puts "MAP LIMIT REACHED, #{@y_bottom_tracker} was  #{0}"
    #   end
    # end

    # Need to fix this GPS to SCREEN CONVERTION - / 14 is a poor substitute    
    if @local_map_movement_x >= 1.0# * @width_scale * 1.1
      puts "ADDING IN ARRAY 3"
      @visible_map.each do |row|
        row.pop
        row.unshift({ 'height' => rand, 'terrain_index' => rand(2) })
      end
      @current_map_center_x = player_x
      @local_map_movement_x = 0
      # raise "STOP"
    end
  

    # Need to fix this GPS to SCREEN CONVERTION - / 14 is a poor substitute    
    if @local_map_movement_x <= -1.0# * @width_scale * 1.1
      puts "ADDING IN ARRAY 4"
      @visible_map.each do |row|
        row.shift
        row.push({ 'height' => rand, 'terrain_index' => rand(2) })
      end
      @current_map_center_x = player_x
      @local_map_movement_x = 0
      # raise "STOP"
    end
  end

  
  # Not needed
  def draw(z)
    # # gl will execute the given block in a clean OpenGL environment, then reset
    # # everything so Gosu's rendering can take place again.
    # Gosu.gl(z) do
    #   glClearColor(0.0, 0.2, 0.5, 1.0)
    #   glClearDepth(0)
    #   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    #   exec_gl
    # end
  end
  
  # include Gl
  
  def exec_gl player_x, player_y
    player_x, player_y = [player_x.to_i, player_y.to_i]

    
    glDepthFunc(GL_GEQUAL)
    glEnable(GL_DEPTH_TEST)
    # glEnable(GL_BLEND)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    glFrustum(-0.10, 0.10, -0.075, 0.075, 1, 100)
    # gluPerspective(45.0, 800 / 600 , 0.1, 100.0)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    glTranslated(0, 0, -4)


#     # TEST

# VERT ONE: -0.25 X -0.1
# VERT TWO: -0.25 X 0.1
# VERT THREE: -0.083 X -0.1
# VERT FOUR: -0.083 X 0.1
# glEnable(GL_TEXTURE_2D)
# glBindTexture(GL_TEXTURE_2D, @info.tex_name)
# glBegin(GL_TRIANGLE_STRIP)
#     glTexCoord2d(@info.left, @info.top)
#     # puts "VERT ONE: #{opengl_x} X #{opengl_y}"
#     # edges of screen are 0.5?
#     # 0, 0 is center.
#     # 1, 1 is top RIGHT
#     # -1, 1, is TOP LEFT
#     # 1, -1 is BOTTOM RIGHT
#     # -1, -1, is bottom LEFT

#     # BOTTOM RIGHT VERT
#     glVertex3d(0.25, -0.25, 0.5)
#     glTexCoord2d(@info.left, @info.bottom)
#     # TOP RIGHT VERT
#     glVertex3d(0.25, 0.25, 0.5)
#     glTexCoord2d(@info.right, @info.top)
#     # BOTTOM LEFT VERT
#     glVertex3d(-0.25, -0.25, 0.5)
#     glTexCoord2d(@info.right, @info.bottom)
#     # TOP LEFT VERT
#     glVertex3d(-0.25, 0.25, 0.5)

#     # glVertex3d(-0.25, -0.1, 0.5)
#     # glTexCoord2d(@info.left, @info.bottom)
#     # glVertex3d(-0.25, 0.1, 0.5)
#     # glTexCoord2d(@info.right, @info.top)
#     # glVertex3d(-0.083, -0.1, 0.5)
#     # glTexCoord2d(@info.right, @info.bottom)
#     # glVertex3d(-0.083, 0.1, 0.5)

# glEnd

    # END TEST
    opengl_offsets = []

    # This is the width and height of each individual terrain segments.
                            # @screen_movement_increment_x == 8 
    # opengl_increment_y = 1 / (VISIBLE_MAP_HEIGHT.to_f / 4.0)
    # opengl_increment_y = @open_gl_screen_movement_increment_y
    # opengl_increment_x = 1 / (VISIBLE_MAP_WIDTH.to_f  / 4.0)
    # opengl_increment_x = @open_gl_screen_movement_increment_x

    # offs_y = 1.0 * @local_map_movement_y / (@screen_movement_increment_y)
    # offs_x = 1.0 * @local_map_movement_x / (@screen_movement_increment_x)
    gps_offs_y = @local_map_movement_y / (@screen_tile_height )
    gps_offs_x = @local_map_movement_x / (@screen_tile_width )
    screen_offset_x = @screen_tile_width  * gps_offs_x
    screen_offset_y = @screen_tile_height * gps_offs_y
    result = convert_screen_to_opengl(screen_offset_x, screen_offset_y)
    opengl_offset_x = result[:o_x]
    opengl_offset_y = result[:o_y]

    # puts "OFF_Y: #{@local_map_movement_y / (@screen_tile_height ) }= #{@local_map_movement_y} / (#{@screen_tile_height} )" 
    # offs_x = offs_x + 0.1

    glEnable(GL_TEXTURE_2D)
    tile_row_y_max = @visible_map.length - 1 #@visible_map.length - 1 - (EXTRA_MAP_HEIGHT)
    @visible_map.each_with_index do |y_row, y_index|
      tile_row_x_max = y_row.length - 1# y_row.length - 1 - (EXTRA_MAP_WIDTH)
      y_row.each_with_index do |x_element, x_index|

        # splits across middle 0  -7..0..7
        new_x_index = x_index - (tile_row_x_max / 2.0)
        new_y_index = y_index - (tile_row_y_max / 2.0)

        # Screen coords width and height here.
        screen_x = @screen_tile_width   * new_x_index
        screen_y = @screen_tile_height  * new_y_index

        result = convert_screen_to_opengl(screen_x, screen_y, @screen_tile_width, @screen_tile_height)
        # puts "X and Y INDEX: #{x_index} - #{y_index}"
        # puts "RESULT HERE: #{result}"
        opengl_coord_x = result[:o_x]
        opengl_coord_y = result[:o_y]
        # opengl_coord_y = opengl_coord_y * -1
        # opengl_coord_x = opengl_coord_x * -1
        opengl_increment_x = result[:o_w]
        opengl_increment_y = result[:o_h]



        # # convert to 
        # # split across center index, divided by half of center abs / 2
        # # (-7 / 3.5) / 2.0
        # # (-1 / 3.5) / 2.0
        # # -1
        # opengl_coord_x = (new_x_index / (tile_row_x_max / 2.0)) / 2
        # opengl_coord_y = (new_y_index / (tile_row_y_max / 2.0)) / 2
        # #we're reading the map as left to right, top down. So comes out as: -1, -1 (bottom left), but needs to be -1, 1 (TOP LEFT)
        # opengl_coord_y = opengl_coord_y * -1
        # opengl_coord_x = opengl_coord_x * -1


        

        # z = x_element['height']
        z = 0.5# - (0.2 / (x_element['height']))
        #testing
        info =  @infos[x_element['terrain_index']]
        # info =  @infos[x_index % 2]
        # info = @info

        glBindTexture(GL_TEXTURE_2D, info.tex_name)
        # -.5 ... +.5
        # puts "Z: #{z}"
        glBegin(GL_TRIANGLE_STRIP)
          # Apply scale factor here?
          # show_debug = false
          # if y_index == 0 && x_index == 0
          #   puts "TOP RIGHT"
          #   show_debug = true
          # elsif y_index == y_max && x_index == x_max
          #   puts "BOTTOM LEFT"
          #   show_debug = true
          # elsif y_index == 0 && x_index == x_max
          #   puts "TOP LEFT"
          #   show_debug = true
          # elsif y_index == y_max && x_index == 0
          #   puts "BOTTOM RIGHT"
          #   show_debug = true
          # end
          glTexCoord2d(info.left, info.top)
          # puts "V2 VERT ONE: #{opengl_coord_x} X #{opengl_coord_y}" if show_debug
          # BOTTOM RIGHT VERT
          glVertex3d(opengl_coord_x - opengl_offset_x, opengl_coord_y - opengl_offset_y, z)
          glTexCoord2d(info.left, info.bottom)
          # puts "V2 VERT TWO: #{opengl_coord_x} X #{opengl_coord_y + opengl_increment_y}" if show_debug
          # TOP RIGHT VERT
          glVertex3d(opengl_coord_x - opengl_offset_x, opengl_coord_y + opengl_increment_y - opengl_offset_y, z)
          glTexCoord2d(info.right, info.top)
          # puts "V2 VERT THREE: #{opengl_coord_x + @opengl_increment_x} X #{opengl_coord_y}" if show_debug
          # BOTTOM LEFT VERT
          glVertex3d(opengl_coord_x + opengl_increment_x - opengl_offset_x, opengl_coord_y - opengl_offset_y, z)
          glTexCoord2d(info.right, info.bottom)
          # puts "V2 VERT FOUR: #{opengl_coord_x + opengl_increment_x} X #{opengl_coord_y + opengl_increment_y}" if show_debug
          # BOTTOM LEFT VERT
          glVertex3d(opengl_coord_x + opengl_increment_x - opengl_offset_x, opengl_coord_y + opengl_increment_y - opengl_offset_y, z)
        glEnd
      end
    end
    # puts opengl_offsets
    # raise "STOP HERE"


  end
end