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
  EXTERIOR_MAP_HEIGHT = 200
  EXTERIOR_MAP_WIDTH  = 200
  # POINTS_X = 7
  VISIBLE_MAP_WIDTH = 26
  # outside of view padding

  EXTRA_MAP_WIDTH   = 2
  # POINTS_Y = 7

  # CAN SEE EDGE OF BLACK MAP AT PLAYER Y 583
  # 15 tiles should be on screen
  VISIBLE_MAP_HEIGHT = 26
  # outside of view padding
  EXTRA_MAP_HEIGHT   = 2
  # Scrolling speed - higher it is, the slower the map moves
  SCROLLS_PER_STEP = 50
  # TEMP USING THIS, CANNOT FIND SCROLLING SPEED
  SCROLLING_SPEED = 4

  # attr_accessor :player_position_x, :player_position_y
  attr_accessor :global_map_width, :global_map_height
  attr_accessor :screen_map_width, :screen_map_height
  attr_accessor :screen_tile_width, :screen_tile_height
  attr_accessor :current_map_center_x, :current_map_center_y

  # tile size is 1 GPS (location_x, location_y)
  # Screen size changes. At 900x900, it should be 900 (screen_width) / 15 (VISIBLE_MAP_WIDTH) = 60 pixels
  # OpenGL size (-1..1) should be (1.0 / 15.0 (VISIBLE_MAP_WIDTH)) - 1.0 

  def convert_screen_to_opengl x, y, w = nil, h = nil
    # puts "convert_screen_to_opengl"
    # puts "#{x} - #{y} - #{w} - #{h}"
    screen_to_opengl_increment_x = (-2.0 / (@screen_width.to_f))
    screen_to_opengl_increment_y = (-2.0 / (@screen_height.to_f))
    # puts "screen_to_opengl_increment: #{screen_to_opengl_increment_x} - #{screen_to_opengl_increment_y}"
    opengl_x   = (x * screen_to_opengl_increment_x) + 1
    opengl_y   = (y * screen_to_opengl_increment_y) + 1
    # opengl_x   = opengl_x * -1
    # opengl_y   = opengl_y * -1
    if w && h
      open_gl_w  = (w * screen_to_opengl_increment_x)
      open_gl_h  = (h * screen_to_opengl_increment_y)
      return {o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}
    else
      return {o_x: opengl_x, o_y: opengl_y}
    end
  end

  def clamp(comp_value, min, max)
    if comp_value > min && comp_value < max
      return comp_value
    elsif comp_value < min
      return min
    else
      return max
    end
  end

  def initialize player_x, player_y, screen_width, screen_height, width_scale, height_scale
    @time_alive = 0
    # @y_add_top_tracker = []
    # @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/earth.png", :tileable => true)

    # These are the width and length of each background tile
    @opengl_increment_y = 1 / (VISIBLE_MAP_HEIGHT.to_f / 4.0)
    @opengl_increment_x = 1 / (VISIBLE_MAP_WIDTH.to_f  / 4.0)

    @width_scale  = width_scale
    @height_scale = height_scale

    @map_inited = false

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

    # Keeping offsets in pos
    @gps_tile_offset_y = VISIBLE_MAP_HEIGHT / 2 + EXTRA_MAP_HEIGHT / 2
    @gps_tile_offset_x = VISIBLE_MAP_WIDTH/ 2 + EXTRA_MAP_WIDTH / 2

    # @global_map_height = EXTERIOR_MAP_HEIGHT
    # @global_map_width  = EXTERIOR_MAP_WIDTH
    # @player_position_x = EXTERIOR_MAP_HEIGHT / 2.0
    # @player_position_y = EXTERIOR_MAP_WIDTH  / 2.0
    # @current_map_center_y = EXTERIOR_MAP_HEIGHT / 2.0
    # @current_map_center_x = EXTERIOR_MAP_WIDTH  / 2.0
    # These are in screen units
    @current_map_center_x = player_x || 0
    @current_map_center_y = player_y || 0
    # Global units
    @gps_map_center_x =  player_x ? (player_x / (@screen_tile_width)).round : 0
    @gps_map_center_y =  player_y ? (player_y / (@screen_tile_height)).round : 0
    @map = JSON.parse(File.readlines("/Users/bendana/projects/line-em-up/line-em-up/maps/desert_v2_small.txt").first)
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

    @global_map_width =  @map["map_width"]
    @global_map_height = @map["map_height"]

    @screen_map_width  = (@global_map_width  * @screen_tile_width )
    @screen_map_height = (@global_map_height * @screen_tile_height)
    puts "@screen_map_height = (EXTERIOR_MAP_HEIGHT * @screen_tile_height)"
    puts "#{@screen_map_height} = (#{EXTERIOR_MAP_HEIGHT} * #{@screen_tile_height})"

    # @global_map_width = @map["map_width"]
    # @global_map_height = @map["map_height"]
    @map_data = @map["data"]
    @visual_map_of_visible_to_map = Array.new(VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT) { Array.new(VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH) { nil } }

    # @y_top_tracker    = nil
    # @y_bottom_tracker = nil

    # @x_right_tracker  = nil
    # @x_left_tracker   = nil

    if player_x && player_y

      init_map
    end

    @debug = false

    # puts "@map_data : #{@map_data[0][0]}" 
    # @visible_map = []
    # puts "TOP TRACKERL = player_y + (VISIBLE_MAP_HEIGHT / 2) + (EXTRA_MAP_HEIGHT / 2)"
    # puts "TOP TRACKERL = #{player_y} + (#{VISIBLE_MAP_HEIGHT} / 2) + (#{EXTRA_MAP_HEIGHT} / 2)"
    # raise 'stop'

    # @y_add_top_tracker << nil
    # puts @visible_map
  end

  # @current_map_center_x and @current_map_center_y must be defined at this point.
  def init_map
    puts "INIT MAP"
    @gps_map_center_x =  (@current_map_center_x / (@screen_tile_width)).round
    @gps_map_center_y =  (@current_map_center_y / (@screen_tile_height)).round

    # @y_top_tracker    = @gps_map_center_y + (VISIBLE_MAP_HEIGHT / 2) + (EXTRA_MAP_HEIGHT / 2)
    # # Fix map tester, then uncomment
    # @y_bottom_tracker = (@gps_map_center_y - (VISIBLE_MAP_HEIGHT / 2) - (EXTRA_MAP_HEIGHT / 2)) - 1
    # # @y_bottom_tracker = (@gps_map_center_y - (VISIBLE_MAP_HEIGHT / 2) - (EXTRA_MAP_HEIGHT / 2))

    # @x_right_tracker    = @gps_map_center_x + (VISIBLE_MAP_WIDTH / 2) + (EXTRA_MAP_WIDTH / 2)
    # # @x_left_tracker     = (@gps_map_center_x - (VISIBLE_MAP_WIDTH / 2) - (EXTRA_MAP_WIDTH / 2))
    # # Fix map tester, then uncomment
    # @x_left_tracker     = (@gps_map_center_x - (VISIBLE_MAP_WIDTH / 2) - (EXTRA_MAP_WIDTH / 2)) - 1

    puts "INITTED MAP SEETINGS"
    puts "@gps_map_center_x =  #{@gps_map_center_x}"
    puts "@gps_map_center_y =  #{@gps_map_center_y}"
    puts "ACTUAL: "
    puts "#{(@current_map_center_x / (@screen_tile_width))}"
    puts "#{(@current_map_center_y / (@screen_tile_height))}"

    # puts "@y_top_tracker    = #{@y_top_tracker}"
    # puts "@y_bottom_tracker = #{@y_bottom_tracker}"

    # puts "@x_right_tracker    = #{@x_right_tracker}"
    # puts "@x_left_tracker     = #{@x_left_tracker}  "
    # puts "@x_right_tracker: #{@x_right_tracker}"

    (0..VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT - 1).each_with_index do |visible_height, index_h|
      y_offset = visible_height - VISIBLE_MAP_HEIGHT / 2
      y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
      # @y_add_top_tracker << (player_y + y_offset)
      (0..VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
        x_offset = visible_width  - VISIBLE_MAP_WIDTH  / 2
        x_offset = x_offset - EXTRA_MAP_WIDTH / 2
        # REAL MAP DATA HERE
        # puts "MAP DATA HEREL #{@map_data.length} and  #{@map_data[0].length}"
        # puts "@map_data[@current_map_center_y + y_offset][@current_map_center_x + x_offset]"
        # puts "@map_data[#{@current_map_center_y} + #{y_offset}][#{@current_map_center_x} + #{x_offset}]"
        # puts "VISIBLE MAP #{index_h} X #{index_w} == @map_data[#{@gps_map_center_y + y_offset}][#{@gps_map_center_x + x_offset}]"
        @visible_map[index_h][index_w] = @map_data[@gps_map_center_y + y_offset][@gps_map_center_x + x_offset]
        @visual_map_of_visible_to_map[index_h][index_w] = "#{@gps_map_center_y + y_offset}, #{@gps_map_center_x + x_offset}"
        # TEST DATA HERE
        # if index_h % 2 == 0
        #   if index_w  % 2 == 0
        #     @visible_map[index_h][index_w] = {'height' => 1, 'terrain_index' => 2 }
        #   else
        #     @visible_map[index_h][index_w] = {'height' => 1, 'terrain_index' => 0 }
        #   end
        # else
        #   if index_w  % 2 == 0
        #     @visible_map[index_h][index_w] = {'height' => 1, 'terrain_index' => 3 }
        #   else
        #     @visible_map[index_h][index_w] = {'height' => 1, 'terrain_index' => 1 }
        #   end
        # end
      end
    end
    @map_inited = true
  end

  def print_visible_map
    if @debug
      puts "print_visible_map - #{@visual_map_of_visible_to_map[0].length} x #{@visual_map_of_visible_to_map.length}"
      @visual_map_of_visible_to_map.each do |y_row|
        output = "|"
        y_row.each do |x_row|
          output << x_row
          output << '|'
        end
        puts output
        puts "_" * 80
      end
    end
  end

  # I think this is dependent on the map being square
  def verify_visible_map
    if @map_inited && @debug

      @visual_map_of_visible_to_map.each_with_index do |y_row, index|
        print_visible_map if y_row.nil? || y_row.empty? || y_row.length != VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1
        raise "Y Column was nil" if y_row.nil? || y_row.empty?
        raise "Y Column size wasn't correct. Expected #{VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH}. GOT: #{y_row.length}" if y_row.length != VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH
      end

      puts "verify_visible_map"
      y_length = @visual_map_of_visible_to_map.length - 1
      x_length = @visual_map_of_visible_to_map[0].length - 1
      raise "MAP IS TOO SHORT Y: #{@visual_map_of_visible_to_map.length} != #{VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT}" if @visual_map_of_visible_to_map.length != VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT
      raise "MAP IS TOO SHORT X: #{@visual_map_of_visible_to_map[0].length} != #{VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH}" if  @visual_map_of_visible_to_map[0].length != VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH
      element = @visual_map_of_visible_to_map[0][0]
      int = 0
      outer_int = 0
      while element == "N/A" && outer_int <= x_length
        while element == "N/A" && int < @visual_map_of_visible_to_map.length - 1
          int += 1
          puts "OUTER INT #{outer_int}"
          element = @visual_map_of_visible_to_map[int][outer_int]
        end
        puts "INCREMENTING OUTER INT"
        outer_int += 1
        puts "HERE: #{outer_int}"
      end
      if element && element != "N/A"
        comp_y, do_nothing = element.split(', ').collect{|v| v.to_i}
        (1..y_length).each do |y|
          first_x_element = @visual_map_of_visible_to_map[y][0]
          next if first_x_element == "N/A"
          value_y, value_x = first_x_element.split(', ').collect{|v| v.to_i}
          (1..x_length).each do |x|
            element = @visual_map_of_visible_to_map[y][x]
            next if element == "N/A"
            do_nothing, comp_x = element.split(', ').collect{|v| v.to_i}
            if value_x + x == comp_x
              # All Good
            else
              print_visible_map
              raise "1ISSUE WITH MAP AT X value Y: #{y} and X: #{x} -> #{value_x + x} != #{comp_x}"
            end
            if value_y == comp_y + y - int
              # All Good
            else
              print_visible_map
              raise "2ISSUE WITH MAP AT Y Value Y: #{y} and X: #{x} -> #{value_y} != #{comp_y + y - int}"
            end
          end
        end
      else
        puts "START MAP NOT VERIFIABLE"
        print_visible_map
        puts "END   MAP NOT VERIFIABLE"
      end
    end
  end

  def update player_x, player_y
    raise "WRONG MAP WIDTH! Expected #{VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH} Got #{@visible_map[0].length}" if @visible_map[0].length != VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH
    raise "WRONG MAP HEIGHT! Expected #{VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT} Got #{@visible_map.length}" if @visible_map.length != VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT
 
    puts "BEFORE EVERYTING"
    # print_visible_map
    puts "BEFORE EVERYTING - V"
    verify_visible_map
    # offset_y = (VISIBLE_MAP_HEIGHT  / 2) + (EXTRA_MAP_HEIGHT / 2)
    # offset_x = (VISIBLE_MAP_WIDTH  / 2) + (EXTRA_MAP_WIDTH / 2)

    # raise "OFFSET IS OFF @y_top_tracker - offset_y != @gps_map_center_y: #{@y_top_tracker} - #{offset_y} != #{@gps_map_center_y}"       if @y_top_tracker     - offset_y != @gps_map_center_y
    # raise "OFFSET IS OFF @y_bottom_tracker + offset_y != @gps_map_center_y: #{@y_bottom_tracker} + #{offset_y} != #{@gps_map_center_y}" if @y_bottom_tracker  + offset_y != @gps_map_center_y
    # raise "OFFSET IS OFF @x_right_tracker - offset_x != @gps_map_center_x: #{@x_right_tracker} - #{offset_x} != #{@gps_map_center_x}"   if @x_right_tracker   - offset_x != @gps_map_center_x
    # raise "OFFSET IS OFF @x_left_tracker + offset_x != @gps_map_center_x: #{@x_left_tracker} + #{offset_x} != #{@gps_map_center_x}"     if @x_left_tracker    + offset_x != @gps_map_center_x

    puts "BEFORE EVERYTING"

    puts "@gps_map_center_y: #{@gps_map_center_y}"
    puts "@gps_map_center_x: #{@gps_map_center_x}"
    # puts "OFFSET Y : #{offset_y}"
    # puts "OFFSET X : #{offset_x}"



    # puts "MAP SIZE: #{@visible_map[0].length} X #{@visible_map.length}"
    # puts "SCREEN BACKGROUND UPDATE: #{player_x} - #{player_y}" if @time_alive % 100 == 0
    # puts "GPS    BACKGROUND UPDATE: #{@gps_map_center_x} - #{@gps_map_center_y}" if @time_alive % 100 == 0

    # print_visible_map if @time_alive % 300 == 0

    @time_alive += 1

    # puts "PLAYER: #{player_x} - #{player_y}"
    # MOVEMENT IS ON GPS COORDS, NEED TO CONVERT TO ONSCREEN COORDS
    @local_map_movement_y = player_y - @current_map_center_y
    # puts "@local_map_movement_y = player_y - @current_map_center_y"
    # puts "#{@local_map_movement_y} = #{player_y} -#{ @current_map_center_y}"
    @local_map_movement_x = player_x - @current_map_center_x

    # Clean variables did not work
    # clean_gps_map_center_y = @gps_map_center_y
    # clean_gps_map_center_x = @gps_map_center_x
    # clean_y_top_tracker    = @y_top_tracker

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
      puts "ADDING IN ARRAY 1"
      print_visible_map
      # y_offset = (VISIBLE_MAP_HEIGHT / 2) + EXTRA_MAP_HEIGHT / 2
      # y_top_edge = (@current_map_center_y + y_offset)
      # CEIL is the only way to get the top 1000 row of the map height.
      # Might just have to ... .round?
      # puts "TOP EDGE here: #{@y_top_tracker}"
      if @current_map_center_y < (@screen_map_height)
        # puts "CURRENT WAS LESS THAN EXTERNIOR: #{@current_map_center_y} - #{EXTERIOR_MAP_HEIGHT}"
        @gps_map_center_y += 1 # Should this be getting smaller... maybe amybe not
        # value = nil
        # @y_add_top_tracker << @y_top_tracker
        # Show edge of map
        if @gps_map_center_y + @gps_tile_offset_y > (@global_map_height)
          puts "ADDING IN EDGE OF MAP"
          @visual_map_of_visible_to_map.pop
          @visual_map_of_visible_to_map.unshift(Array.new(VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT) { "N/A" })

          @visible_map.pop
          @visible_map.unshift(Array.new(VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT) { {'height' => 2, 'terrain_index' => 3 } })
        else
          puts "ADDING NORMALLY"
          @visible_map.pop
          @visual_map_of_visible_to_map.pop
          # @y_add_top_tracker << (player_y + y_offset)
          new_array = []
          new_debug_array = []
          (0..VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
            x_index = @global_map_width - @gps_map_center_x + visible_width - @gps_tile_offset_x
            if x_index < @global_map_width && x_index >= 0
              # Flipping Y Axis when retrieving from map data
              y_index = (@global_map_height - ((@gps_map_center_y) + @gps_tile_offset_y))
              puts "(@global_map_height - ((@gps_map_center_y) + @gps_tile_offset_y)) - 1"
              puts "(#{@global_map_height} - ((#{@gps_map_center_y}) + #{@gps_tile_offset_y})) - 1"
              # (250 - ((126) + 9)) - 1
              puts y_index
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @global_map_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          # X is coming in on the wrong side?
          # new_array.reverse!

          @visible_map.unshift(new_array)

          @visual_map_of_visible_to_map.unshift(new_debug_array)

          verify_visible_map

          # value = "INSIDE MAP"
        end
        # puts "MAP ADDED at #{@current_map_center_y} w/ - top tracker: #{@y_top_tracker}"
        @current_map_center_y = @current_map_center_y + @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_y = @local_map_movement_y - @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_y = 0 if @local_map_movement_y > 0
      end
    end






    # Adding to bottom of map
    # Convert on screen movement to map
    if @local_map_movement_y <= -@screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
      puts "ADDING IN ARRAY 2"
      if @current_map_center_y > 0
        puts "PRE gps_map_center_y: #{@gps_map_center_y}"
        @gps_map_center_y -= 1
        # Have to increment by one, or else duplicating row
        local_gps_map_center_y = @gps_map_center_y + 1
        puts "POST gps_map_center_y: #{@gps_map_center_y}"

        # @gps_tile_offset_y = VISIBLE_MAP_HEIGHT / 2 + EXTRA_MAP_HEIGHT / 2
        # @gps_tile_offset_x = VISIBLE_MAP_WIDTH/ 2 + EXTRA_MAP_WIDTH / 2

        # Show edge of map 
        if local_gps_map_center_y - @gps_tile_offset_y <= 0
          @visible_map.shift
          @visual_map_of_visible_to_map.shift
          @visible_map.push(Array.new(VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH) { {'height' => 2, 'terrain_index' => 3 } })
          @visual_map_of_visible_to_map.push(Array.new(VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH) { "N/A" })
          # puts "HERE WHAT WAS IT? visible_map.last.length #{@visible_map.last.length}"
          # puts "HERE WHAT WAS IT? visible_map.last[0].length #{@visible_map.last[0].length}"
        else
          puts "ADDING NORMALLY - #{@current_map_center_y} -#{ @gps_tile_offset_y} > 0"
          @visible_map.shift
          @visual_map_of_visible_to_map.shift
          # @y_add_top_tracker << (player_y + y_offset)
          new_array = []
          new_debug_array = []
          (0..VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
            x_index = @global_map_width - @gps_map_center_x + visible_width - @gps_tile_offset_x
            if x_index < @global_map_width && x_index >= 0
              puts "(@global_map_height - ((local_gps_map_center_y ) - @gps_tile_offset_y)) - 1"
              puts "(#{@global_map_height} - ((#{local_gps_map_center_y }) - #{@gps_tile_offset_y})) - 1"
              puts "#{(@global_map_height - ((local_gps_map_center_y ) - @gps_tile_offset_y)) - 1}"
              # - 1 for array indexing. - WRONG
              # y_index = (@global_map_height - ((local_gps_map_center_y ) - @gps_tile_offset_y)) - 1
              y_index = (@global_map_height - ((local_gps_map_center_y ) - @gps_tile_offset_y))
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @global_map_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          # X is coming in on the wrong side?
          # new_array.reverse!

          @visible_map.push(new_array)

          @visual_map_of_visible_to_map.push(new_debug_array)

          verify_visible_map

          # value = "INSIDE MAP"
        end
        # puts "MAP ADDED at #{@current_map_center_y} w/ - top tracker: #{@y_top_tracker}"
        @current_map_center_y = @current_map_center_y - @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_y = @local_map_movement_y + @screen_tile_height# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_y = 0 if @local_map_movement_y > 0
      end
    end


    # Moving to the RIGHT
    if @local_map_movement_x >= @screen_tile_width
      puts "ADDING IN ARRAY 3 "
      print_visible_map
      if @current_map_center_x < (@screen_map_width)
        puts "PRE GPS MAP CENTER X: #{@gps_map_center_x}"
        @gps_map_center_x    += 1
        puts "POST GPS MAP CENTER X #{@gps_map_center_x}"

        if @gps_map_center_x + @gps_tile_offset_x > (@global_map_width)
          puts "ADDING IN RIGHT EDGE OF MAP"

          @visible_map.each do |row|
            row.pop
            row.unshift({'height' => 2, 'terrain_index' => 3 } )
          end
          @visual_map_of_visible_to_map.each do |y_row|
            y_row.pop
            y_row.unshift("N/A")
          end

        else
          puts "ASDDING NORMAL MAP EDGE:"

          @visible_map.each do |y_row|
            y_row.pop
          end
          @visual_map_of_visible_to_map.each do |y_row|
            y_row.pop
          end

          new_array       = []
          new_debug_array = []
          (0..VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT - 1).each_with_index do |visible_height, index_w|
            y_index = @global_map_height - @gps_map_center_y + visible_height - @gps_tile_offset_x
            # y_offset = visible_height  - VISIBLE_MAP_HEIGHT  / V
            # y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
            # y_index = @global_map_height - @gps_map_center_y + y_offset
            if y_index < @global_map_height && y_index >= 0
              # IMPLEMENT!!!
              x_index = (@global_map_width - ((@gps_map_center_x) + @gps_tile_offset_x))
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @global_map_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          new_array.each_with_index do |element, index|
            @visible_map[index].unshift(element)
          end
          new_debug_array.each_with_index do |element, index|
            @visual_map_of_visible_to_map[index].unshift(element)
          end
          verify_visible_map
        end
        # puts "MAP ADDED at #{@current_map_center_y} w/ - top tracker: #{@y_top_tracker}"
        @current_map_center_x = @current_map_center_x + @screen_tile_width# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_x = @local_map_movement_x - @screen_tile_width# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_x = 0 if @local_map_movement_x > 0
      end
    end
  

    # MOVING TO THE LEFT
    if @local_map_movement_x <= -@screen_tile_width# * @width_scale * 1.1
      puts "ADDING IN ARRAY 4"
    #   if @current_map_center_x > 0
    #     @x_right_tracker -= 1
    #     @x_left_tracker  -= 1
    #     # value = nil
    #     if @x_left_tracker < 0

    #       @visible_map.each do |row|
    #         row.shift
    #         row.push({'height' => 2, 'terrain_index' => 3 })
    #       end
    #     else
    #       @visible_map.each do |row|
    #         row.shift
    #         row.push({'height' => 1, 'terrain_index' => 1 + rand(2) })
    #       end
    #     end
    #     @current_map_center_x = @current_map_center_x - @screen_tile_width# / VISIBLE_MAP_HEIGHT.to_f
    #     @local_map_movement_x = @local_map_movement_x + @screen_tile_width# / VISIBLE_MAP_HEIGHT.to_f
    #     @gps_map_center_x    -= 1
    #   else
    #     @local_map_movement_x = 0 if @local_map_movement_x < 0
    #   end
      print_visible_map
      if @current_map_center_x < (@screen_map_width)
        puts "PRE GPS MAP CENTER X: #{@gps_map_center_x}"
        @gps_map_center_x    -= 1
        puts "POST GPS MAP CENTER X #{@gps_map_center_x}"

        if @gps_map_center_x - @gps_tile_offset_x < 0
          puts "ADDING IN RIGHT EDGE OF MAP"
          @visible_map.each do |row|
            row.shift
            row.push({'height' => 2, 'terrain_index' => 3 } )
          end
          @visual_map_of_visible_to_map.each do |y_row|
            y_row.shift
            y_row.push("N/A")
          end

        else
          puts "ASDDING NORMAL MAP EDGE:"

          @visible_map.each do |y_row|
            y_row.shift
          end
          @visual_map_of_visible_to_map.each do |y_row|
            y_row.shift
          end

          new_array       = []
          new_debug_array = []
          (0..VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT - 1).each_with_index do |visible_height, index_w|
            y_index = (@global_map_height - @gps_map_center_y + visible_height - @gps_tile_offset_x)
            # y_offset = visible_height  - VISIBLE_MAP_HEIGHT  / V
            # y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
            # y_index = @global_map_height - @gps_map_center_y + y_offset
            if y_index < @global_map_height && y_index >= 0
              # IMPLEMENT!!!
              x_index = (@global_map_width - ((@gps_map_center_x) - @gps_tile_offset_x)) - 1
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @global_map_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          new_array.each_with_index do |element, index|
            @visible_map[index].push(element)
          end
          new_debug_array.each_with_index do |element, index|
            @visual_map_of_visible_to_map[index].push(element)
          end
          verify_visible_map
        end
        @current_map_center_x = @current_map_center_x - @screen_tile_width# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_x = @local_map_movement_x + @screen_tile_width# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_x = 0 if @local_map_movement_x > 0
      end
    end

    puts "aFTER EVERYTING"
    print_visible_map
    verify_visible_map
    puts "aFTER EVERYTING"

    # offset_y = (VISIBLE_MAP_HEIGHT  / 2) + (EXTRA_MAP_HEIGHT / 2)
    # offset_x = (VISIBLE_MAP_WIDTH  / 2) + (EXTRA_MAP_WIDTH / 2)

    # raise "OFFSET IS OFF @y_top_tracker - offset_y != @gps_map_center_y: #{@y_top_tracker} - #{offset_y} != #{@gps_map_center_y}"       if @y_top_tracker     - offset_y != @gps_map_center_y
    # raise "OFFSET IS OFF @y_bottom_tracker + offset_y != @gps_map_center_y: #{@y_bottom_tracker} + #{offset_y} != #{@gps_map_center_y}" if @y_bottom_tracker  + offset_y != @gps_map_center_y
    # raise "OFFSET IS OFF @x_right_tracker - offset_x != @gps_map_center_x: #{@x_right_tracker} - #{offset_x} != #{@gps_map_center_x}"   if @x_right_tracker   - offset_x != @gps_map_center_x
    # raise "OFFSET IS OFF @x_left_tracker + offset_x != @gps_map_center_x: #{@x_left_tracker} + #{offset_x} != #{@gps_map_center_x}"     if @x_left_tracker    + offset_x != @gps_map_center_x

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

        # radius
        # The radius of the sphere.
        # slices
        # The number of subdivisions around the Z axis (similar to lines of longitude).
        # stacks
        # The number of subdivisions along the Z axis (similar to lines of latitude).
    # glMatrixMode(GL_MODELVIEW);
    # glLoadIdentity
    # # glutSolidSphere(600,1,2)
    # glutSolidSphere(1.0, 20, 16)

    
    # glEnable(GL_BLEND)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    glFrustum(-0.10, 0.10, -0.075, 0.075, 1, 100)
    # gluPerspective(45.0, 800 / 600 , 0.1, 100.0)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity

    # // Move the scene back so we can see everything
    # glTranslatef( 0.0f, 0.0f, -100.0f );
    # -10 is as far back as we can go.
    glTranslated(0, 0, -5)


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
    # puts "gps_offs_y = @local_map_movement_y / (@screen_tile_height )"
    # puts "#{gps_offs_y} = #{@local_map_movement_y} / (#{@screen_tile_height} )"
    screen_offset_x = @screen_tile_width  * gps_offs_x * -1
    screen_offset_y = @screen_tile_height * gps_offs_y * -1
    offset_result = convert_screen_to_opengl(screen_offset_x, screen_offset_y)
    opengl_offset_x = offset_result[:o_x]# >= @screen_tile_width ? 0 : offset_result[:o_x]
    opengl_offset_y = offset_result[:o_y]# >= @screen_tile_height ? 0 : offset_result[:o_y]

    # puts "OLD OPENGL: #{opengl_offset_y}"
    # opengl_offset_y = opengl_offset_y * -1
    # puts "NEW OPENGL: #{opengl_offset_y}"

    # puts "OFF_Y: #{@local_map_movement_y / (@screen_tile_height ) }= #{@local_map_movement_y} / (#{@screen_tile_height} )" 
    # offs_x = offs_x + 0.1

    # Cool lighting
    # glEnable(GL_LIGHTING)

    #   glLightfv(GL_LIGHT0, GL_AMBIENT, [0.5, 0.5, 0.5, 1])
    #   glLightfv(GL_LIGHT0, GL_DIFFUSE, [1, 1, 1, 1])
    #   glLightfv(GL_LIGHT0, GL_POSITION, [1, 1, 1,1])
    #   glLightfv(GL_LIGHT1, GL_AMBIENT, [0.5, 0.5, 0.5, 1])
    #   glLightfv(GL_LIGHT1, GL_DIFFUSE, [1, 1, 1, 1])
    #   glLightfv(GL_LIGHT1, GL_POSITION, [100, 100, 100,1])
  
    @enable_dark_mode = true
    if @enable_dark_mode
      glLightfv(GL_LIGHT6, GL_AMBIENT, [0.2, 0.2, 0.2, 1])
      glLightfv(GL_LIGHT6, GL_DIFFUSE, [0.2, 0.2, 0.2, 1])
      # Dark lighting effect?
      glLightfv(GL_LIGHT6, GL_POSITION, [0, 0, 0,-1])
      glEnable(GL_LIGHT6)
    end

    @test = false
    if @test



      # glEnable(GL_LIGHT0)
      # glEnable(GL_LIGHT1)
      if true

        glLightfv(GL_LIGHT1, GL_SPECULAR, [1.0, 1.0, 1.0, 1.0])
        glLightfv(GL_LIGHT1, GL_POSITION, [0, 0, 1.0, 1.0])
        glLightf(GL_LIGHT1, GL_CONSTANT_ATTENUATION, 1.5)
        glLightf(GL_LIGHT1, GL_LINEAR_ATTENUATION, 0.5)
        glLightf(GL_LIGHT1, GL_QUADRATIC_ATTENUATION, 0.2)


        glLightf(GL_LIGHT1, GL_SPOT_CUTOFF, 15.0)
        glLightfv(GL_LIGHT1, GL_SPOT_DIRECTION, [-1.0, -1.0, 0.0])
        glLightf(GL_LIGHT1, GL_SPOT_EXPONENT, 2.0)
        glEnable(GL_LIGHT1)
      end
      glMaterialfv(GL_FRONT, GL_SPECULAR, [1.0, 1.0, 1.0, 1.0])
      glMaterialfv(GL_FRONT, GL_SHININESS, [50.0])


      glShadeModel( GL_SMOOTH )

      # // Renormalize scaled normals so that lighting still works properly.
      glEnable( GL_NORMALIZE )
      glEnable(GL_COLOR_MATERIAL)

     glBegin(GL_TRIANGLES);
      # glTexCoord2d(info.left, info.top)
      glColor4d(0, 0, 1, 1)
      glVertex3f(-0.2, 0.2, 1); 
      # glTexCoord2d(info.left, info.bottom)
      glColor4d(0, 1, 0, 1)
      glVertex3f(-0.2, -0.2, 1); 
      # glTexCoord2d(info.right, info.top)
      glColor4d(1, 0, 1, 1)
      glVertex3f(0.2, 0, 3); 
      # glTexCoord2d(info.right, info.bottom)
      # glColor4d(1, 1, 1, 1)
      # glVertex3f(0.5, -0.5, 3); 
     glEnd
   end

    # START Documentation!
    #                                    # 3 These change colors. 
    #                                       # RGBA - The alpha parameter is a number between 0.0 (fully transparent) and 1.0 (fully opaque).
    #   glLightfv(GL_LIGHT2, GL_AMBIENT, [1, 1, 1, 1])
    #                                    # 3 These change colors. 
    #                                       # RGBA - The alpha parameter is a number between 0.0 (fully transparent) and 1.0 (fully opaque).
    #   glLightfv(GL_LIGHT2, GL_DIFFUSE, [1, 1, 1, 1])
    #   glLightfv(GL_LIGHT2, GL_SPECULAR, [1.0, 1.0, 1.0, 1.0]);

    #   # The vector has values x, y, z, and w.  If w is 1.0, we are defining a light at a point in space.  If w is 0.0, the light is at infinity.  As an example, try adding this code right after you enable the light:
    #   # w is not really a dimension but a scaling factor (used to get some matrix stuff easier done - means you can calculate translations by matrix multiplication instead of an addition)
    #   # kartesian coordiantes its:
    #   # x’=x/w
    #   # y’=y/w
    #   # z’=z/w
    #   glLightfv(GL_LIGHT2, GL_POSITION, [0, 0,0,1])

    #   glEnable(GL_LIGHT2)
    # END Documentation


    # SET MAX LIGHTS HERE
    # glGetIntegerv( GL_MAX_LIGHTS, 1 );

    if !@test
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
          # z = 0.5# - (0.2 / (x_element['height']))
          #testing
          info =  @infos[x_element['terrain_index']]
          # z = x_element['height']
          if x_element['corner_heights']
            z = x_element['corner_heights']
          else
            z = {'bottom_right' =>  1, 'bottom_left' =>  1, 'top_right' =>  1, 'top_left' =>  1}
          end

          # z = get_surrounding_average_tile_height(x_index, y_index)
          # puts "puts USING Z: #{z}"
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
            vert_pos = [opengl_coord_x - opengl_offset_x, opengl_coord_y - opengl_offset_y, z['top_left']]
            if vert_pos[0] >= -0.2 && vert_pos[0] <= 0.2 && vert_pos[1] >= -0.2 && vert_pos[1] <= 0.2 
              colors = [0.7, 0.7, 0.7, 0.1]
            else
              colors = [0.3, 0.3, 0.3, 0.1]
            end
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

            glTexCoord2d(info.left, info.bottom)
            vert_pos = [opengl_coord_x - opengl_offset_x, opengl_coord_y + opengl_increment_y - opengl_offset_y, z['bottom_left']]
            if vert_pos[0] >= -0.2 && vert_pos[0] <= 0.2 && vert_pos[1] >= -0.2 && vert_pos[1] <= 0.2 
              colors = [0.7, 0.7, 0.7, 0.1]
            else
              colors = [0.3, 0.3, 0.3, 0.1]
            end
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

            glTexCoord2d(info.right, info.top)
            vert_pos = [opengl_coord_x + opengl_increment_x - opengl_offset_x, opengl_coord_y - opengl_offset_y, z['top_right']]
            if vert_pos[0] >= -0.2 && vert_pos[0] <= 0.2 && vert_pos[1] >= -0.2 && vert_pos[1] <= 0.2 
              colors = [0.7, 0.7, 0.7, 0.1]
            else
              colors = [0.3, 0.3, 0.3, 0.1]
            end
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])

            glTexCoord2d(info.right, info.bottom)
            vert_pos = [opengl_coord_x + opengl_increment_x - opengl_offset_x, opengl_coord_y + opengl_increment_y - opengl_offset_y, z['bottom_right']]
            if vert_pos[0] >= -0.2 && vert_pos[0] <= 0.2 && vert_pos[1] >= -0.2 && vert_pos[1] <= 0.2 
              colors = [0.7, 0.7, 0.7, 0.1]
            else
              colors = [0.3, 0.3, 0.3, 0.1]
            end
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos[0], vert_pos[1], vert_pos[2])
          glEnd
        end
      end
    end
  end
end