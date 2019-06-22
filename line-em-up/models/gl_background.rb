# Class Needs to be renamed.. 

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
  # HAVE TO BE EVEN NUMBERS
  VISIBLE_MAP_WIDTH = 8
  # outside of view padding

  # HAVE TO BE EVEN NUMBERS
  EXTRA_MAP_WIDTH   = 4
  # POINTS_Y = 7

  # CAN SEE EDGE OF BLACK MAP AT PLAYER Y 583
  # 15 tiles should be on screen
  # HAVE TO BE EVEN NUMBERS
  VISIBLE_MAP_HEIGHT = 8
  # outside of view padding
  # HAVE TO BE EVEN NUMBERS
  EXTRA_MAP_HEIGHT   = 4
  # Scrolling speed - higher it is, the slower the map moves
  SCROLLS_PER_STEP = 50
  # TEMP USING THIS, CANNOT FIND SCROLLING SPEED
  SCROLLING_SPEED = 4

  # attr_accessor :player_position_x, :player_position_y
  attr_accessor :map_tile_width, :map_tile_height
  attr_accessor :map_pixel_width, :map_pixel_height
  attr_accessor :tile_pixel_width, :tile_pixel_height
  attr_accessor :current_map_pixel_center_x, :current_map_pixel_center_y
  attr_reader :gps_map_center_x, :gps_map_center_y
  attr_reader :map_name

  # tile size is 1 GPS (location_x, location_y)
  # Screen size changes. At 900x900, it should be 900 (screen_pixel_width) / 15 (VISIBLE_MAP_WIDTH) = 60 pixels
  # OpenGL size (-1..1) should be (1.0 / 15.0 (VISIBLE_MAP_WIDTH)) - 1.0 

  # This is incorrect.. the map isn't 1..-1 in openGL.. it's more like 0.5..-0.5
  # 225.0, 675.0, 450.0 , 450.0
  # screen_to_opengl_increment: -0.0022222222222222222 - -0.0022222222222222222
  # outputs: {:o_x=>0.5, :o_y=>-0.5, :o_w=>-1.0, :o_h=>-1.0}


  # not sure if include_adjustments_for_not_exact_opengl_dimensions works yet or not
  # def convert_opengl_to_screen opengl_x, opengl_y, include_adjustments_for_not_exact_opengl_dimensions = false
  #   opengl_x = 1.2 / opengl_x if opengl_x != 0 && include_adjustments_for_not_exact_opengl_dimensions
  #   x = ((opengl_x + 1) / 2.0) * @screen_pixel_width.to_f
  #   opengl_y = 0.92 / opengl_y if opengl_y != 0 && include_adjustments_for_not_exact_opengl_dimensions
  #   y = ((opengl_y + 1) / 2.0) * @screen_pixel_height.to_f
  #   return [x, y]
  # end

  #   convert_screen_to_opengl
  # 225.0, 675.0, 450.0 , 450.0
  # RETURNING: {:o_x=>-0.5, :o_y=>0.5, :o_w=>0.0, :o_h=>0.0}
  # def convert_screen_to_opengl x, y, w = nil, h = nil, include_adjustments_for_not_exact_opengl_dimensions = false
  #   # puts "IT's SET RIUGHT HERE2!!: #{@screen_pixel_height} - #{y}"
  #   opengl_x   = ((x / (@screen_pixel_width.to_f )) * 2.0) - 1
  #   # opengl_x   = opengl_x * 1.2 if include_adjustments_for_not_exact_opengl_dimensions
  #   opengl_y   = ((y / (@screen_pixel_height.to_f)) * 2.0) - 1
  #   # opengl_y   = opengl_y * 0.92 if include_adjustments_for_not_exact_opengl_dimensions
  #   if w && h
  #     open_gl_w  = ((w / (@screen_pixel_width.to_f )) * 2.0)
  #     # open_gl_w = open_gl_w - opengl_x
  #     open_gl_h  = ((h / (@screen_pixel_height.to_f )) * 2.0)
  #     # open_gl_h = open_gl_h - opengl_y
  #     # puts "RETURNING: #{{o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}}"
  #     return {o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}
  #   else
  #     # puts "RETURNING: #{{o_x: opengl_x, o_y: opengl_y}}"
  #     return {o_x: opengl_x, o_y: opengl_y}
  #   end
  # end


  def initialize width_scale, height_scale, screen_pixel_width, screen_pixel_height
    @debug = true
    # @debug = false

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
    # IN OPENGL terms
    # @open_gl_screen_movement_increment_x = 1 / ((screen_pixel_width.to_f / VISIBLE_MAP_WIDTH.to_f)  - (screen_pixel_width.to_f / VISIBLE_MAP_WIDTH.to_f) / 4.0 )#(screen_pixel_width  / VISIBLE_MAP_WIDTH)  / 4
    # @open_gl_screen_movement_increment_y = 1 / ((screen_pixel_height.to_f / VISIBLE_MAP_HEIGHT.to_f)  - (screen_pixel_height.to_f / VISIBLE_MAP_HEIGHT.to_f) / 4.0 )#(screen_pixel_height / VISIBLE_MAP_HEIGHT) / 4

    # SCREEN COORD SYSTEM 480 x 480
    # @on_screen_movement_increment_x = ((screen_pixel_width.to_f  / VISIBLE_MAP_WIDTH.to_f)  / 2.0)     #(screen_pixel_width  / VISIBLE_MAP_WIDTH)  / 4
    # @on_screen_movement_increment_y = ((screen_pixel_height.to_f / VISIBLE_MAP_HEIGHT.to_f) / 2.0)     #(screen_pixel_height / VISIBLE_MAP_HEIGHT) / 4

    # OPENGL SYSTEM -1..1
    # @open_gl_screen_movement_increment_x = (1 / (@on_screen_movement_increment_x))  - (@on_screen_movement_increment_x / 2.0)
    # @open_gl_screen_movement_increment_y = (1 / (@on_screen_movement_increment_y))  - (@on_screen_movement_increment_y / 2.0)
    @open_gl_screen_movement_increment_x = (1 / (VISIBLE_MAP_WIDTH.to_f  )) / 2.0
    @open_gl_screen_movement_increment_y = (1 / (VISIBLE_MAP_HEIGHT.to_f )) / 2.0
 
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


    @screen_pixel_width = screen_pixel_width
    # puts "IT's SET RIUGHT HERE!!: #{@screen_pixel_width}"
    @screen_pixel_height = screen_pixel_height
    @screen_pixel_height_half = @screen_pixel_height / 2
    @screen_pixel_width_half = @screen_pixel_width / 2

    @tile_pixel_width  = @screen_pixel_width  / VISIBLE_MAP_WIDTH.to_f
    # puts "WHAT IS GOING ON HERE:"
    # puts "@tile_pixel_width  = @screen_pixel_width  / VISIBLE_MAP_WIDTH.to_f"
    # puts "#{@tile_pixel_width}  = #{@screen_pixel_width}  / #{VISIBLE_MAP_WIDTH.to_f}"
    @tile_pixel_height = @screen_pixel_height / VISIBLE_MAP_HEIGHT.to_f

    # @ratio = @screen_pixel_width.to_f / (@screen_pixel_height.to_f)

    # increment_x = (ratio / middle_x) * 0.97
    # # The zoom issue maybe, not quite sure why we need the Y offset.
    # increment_y = (1.0 / middle_y) * 0.55

    @scrolls = 0.0
    @visible_map = Array.new(VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT) { Array.new(VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH) { nil } }
    @local_map_movement_x = 0
    @local_map_movement_y = 0

    # Keeping offsets in pos
    @gps_tile_offset_y = VISIBLE_MAP_HEIGHT / 2 + EXTRA_MAP_HEIGHT / 2
    @gps_tile_offset_x = VISIBLE_MAP_WIDTH/ 2 + EXTRA_MAP_WIDTH / 2

    # @map_tile_height = EXTERIOR_MAP_HEIGHT
    # @map_tile_width  = EXTERIOR_MAP_WIDTH
    # @player_position_x = EXTERIOR_MAP_HEIGHT / 2.0
    # @player_position_y = EXTERIOR_MAP_WIDTH  / 2.0
    # @current_map_pixel_center_y = EXTERIOR_MAP_HEIGHT / 2.0
    # @current_map_pixel_center_x = EXTERIOR_MAP_WIDTH  / 2.0
    # These are in screen units
    @current_map_pixel_center_x = nil# player_x || 0
    @current_map_pixel_center_y = nil#player_y || 0
    # Global units
    @gps_map_center_x = nil # player_x ? (player_x / (@tile_pixel_width)).round : 0
    @gps_map_center_y = nil # player_y ? (player_y / (@tile_pixel_height)).round : 0
    @map_name = "desert_v2_small"
    @map = JSON.parse(File.readlines("/Users/bendana/projects/line-em-up/line-em-up/maps/#{@map_name}.txt").first)
    @map_objects = JSON.parse(File.readlines("/Users/bendana/projects/line-em-up/line-em-up/maps/#{@map_name}_map_objects.txt").join('').gsub("\n", ''))
    @active_map_objects = []

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

    @map_tile_width =  @map["map_width"]
    @map_tile_height = @map["map_height"]

    @map_pixel_width  = (@map_tile_width  * @tile_pixel_width ).to_i
    @map_pixel_height = (@map_tile_height * @tile_pixel_height).to_i
    # puts "@map_pixel_height = (EXTERIOR_MAP_HEIGHT * @tile_pixel_height)"
    # puts "#{@map_pixel_height} = (#{EXTERIOR_MAP_HEIGHT} * #{@tile_pixel_height})"

    # @map_tile_width = @map["map_width"]
    # @map_tile_height = @map["map_height"]
    @map_data = @map["data"]
    if @debug
      @map_data.each_with_index do |e, y|
        e.each_with_index do |v, x|
          @map_data[y][x] = @map_data[y][x].merge({'gps_y' => (@map_tile_height - y) - 1, 'gps_x' => (@map_tile_width - x) - 1 })
        end
      end
    end
    @visual_map_of_visible_to_map = Array.new(VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT) { Array.new(VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH) { nil } }

    # @y_top_tracker    = nil
    # @y_bottom_tracker = nil

    # @x_right_tracker  = nil
    # @x_left_tracker   = nil

    # if player_x && player_y
    #   raise "This case is no longer supported. Can't return objects like buildings from initialize"
    #   init_map
    # end


    if @debug
      @font = Gosu::Font.new(20)
    end

    # puts "@map_data : #{@map_data[0][0]}" 
    # @visible_map = []
    # puts "TOP TRACKERL = player_y + (VISIBLE_MAP_HEIGHT / 2) + (EXTRA_MAP_HEIGHT / 2)"
    # puts "TOP TRACKERL = #{player_y} + (#{VISIBLE_MAP_HEIGHT} / 2) + (#{EXTRA_MAP_HEIGHT} / 2)"
    # raise 'stop'

    # @y_add_top_tracker << nil
    # puts @visible_map
  end

  def recenter_map center_target
    raise "did not work"
    @gps_map_center_x  = center_target.current_map_tile_x
    @gps_map_center_y  = center_target.current_map_tile_x

    (0..VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT - 1).each_with_index do |visible_height, index_h|
      y_offset = visible_height - VISIBLE_MAP_HEIGHT / 2
      y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
      # @y_add_top_tracker << (player_y + y_offset)
      (0..VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
        x_offset = visible_width  - VISIBLE_MAP_WIDTH  / 2
        x_offset = x_offset - EXTRA_MAP_WIDTH / 2
        y_index = @gps_map_center_y + y_offset
        x_index = @gps_map_center_x + x_offset
        @visible_map[index_h][index_w] = @map_data[y_index][x_index]
        @visual_map_of_visible_to_map[index_h][index_w] = "#{y_index}, #{x_index}"
      end
    end
    @current_map_pixel_center_x = center_target.current_map_pixel_x
    @current_map_pixel_center_y = center_target.current_map_pixel_y

    @local_map_movement_y = @current_map_pixel_center_x
    @local_map_movement_x = @current_map_pixel_center_y
  end

  # @current_map_pixel_center_x and @current_map_pixel_center_y must be defined at this point.
  # Shouldn't use center here.. should use player center..
  def init_map current_target_tile_x, current_target_tile_y
    # puts "INIT MAP"
    @gps_map_center_x = current_target_tile_x
    @gps_map_center_y = current_target_tile_y

    # @gps_map_center_x =  (@current_map_pixel_center_x / (@tile_pixel_width)).round
    # @gps_map_center_y =  (@current_map_pixel_center_y / (@tile_pixel_height)).round

    buildings = []
    ships = []
    pickups = []
    projectiles = []
    # puts "@map_objects"
    # puts @map_objects.inspect

    (0..VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT - 1).each_with_index do |visible_height, index_h|
      y_offset = visible_height - VISIBLE_MAP_HEIGHT / 2
      y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
      # @y_add_top_tracker << (player_y + y_offset)
      (0..VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
        x_offset = visible_width  - VISIBLE_MAP_WIDTH  / 2
        x_offset = x_offset - EXTRA_MAP_WIDTH / 2
        y_index = @gps_map_center_y + y_offset
        x_index = @gps_map_center_x + x_offset
        @visible_map[index_h][index_w] = @map_data[y_index][x_index]
        @visual_map_of_visible_to_map[index_h][index_w] = "#{y_index}, #{x_index}"
      end
    end

    # When do we delete it from map objects... 
    if @map_objects["buildings"]
      datas = @map_objects["buildings"]
      datas.each do |y_value, data|
        # puts "building DATA - #{y_index} - #{x_index}"
        # puts "y_value: #{y_value}, data: #{data}"
        data.each do |x_value, elements|
          elements.each do |element|
            klass = eval(element["klass_name"])
            buildings << klass.new(x_value.to_i, y_value.to_i, {z: @map_data[y_value.to_i][x_value.to_i]['height']})
          end
        end
      end
    end

    # puts "ENEMEIS: #{@map_objects["ships"].count}"
    if @map_objects["ships"]
      datas = @map_objects["ships"]
      datas.each do |y_value, data|
        # puts "building DATA - #{y_index} - #{x_index}"
        # puts "y_value: #{y_value}, data: #{data}"
        data.each do |x_value, elements|
          elements.each do |element|
            klass = eval(element["klass_name"])
            # IF pixels exist in the future, load pixels.... If so, need to multiply pixels by scale., and then divide by scale before saving.
            ships << klass.new(nil, nil, x_value.to_i, y_value.to_i)
          end
        end
      end
    end
    @map_inited = true
    # @only return active objects?
    # Except enemies, cause they can have movement outside of the visible map?
    puts "RETURING BUILDINGS: #{buildings.count}"
    puts "RETURING ships: #{ships.count}"
    return {ships: ships, pickups: pickups, buildings: buildings}
  end

  # def convert_gps_to_screen
  # end

  # How to draw enemies that can move? Projectiles and enemies
  def update_objects_relative_to_map local_map_movement_x, local_map_movement_y, objects, tile_movement_x, tile_movement_y
    delete_index = []
    objects.each_with_index do |object, index|
      # Objects will move themselves across tiles
      if tile_movement_x
        object.x = object.x + tile_movement_x
      end
      # object.x_offset = local_map_movement_x

      if tile_movement_y
        object.y = object.y + tile_movement_y
      end
      # object.y_offset = local_map_movement_y

      object.update_offsets(local_map_movement_x, local_map_movement_y)
    end

    # delete_index.each do |i|
    #   objects.delete_at(i)
    # end

    return objects
  end


  # bUILDING LOCATION ON TRIGGER : 126 - 125
  # RESULTS HERE: [825.0, 525.0]
  # Don't factor in x or y offset here.
  def gps_tile_coords_to_center_screen_coords tile_x, tile_y
    raise "STOP USING ME"
    # @gps_map_center_y
    # @gps_map_center_x

    x_offset = (VISIBLE_MAP_WIDTH  / 2.0)
    y_offset = (VISIBLE_MAP_HEIGHT / 2.0)
    if tile_x < @gps_map_center_x - x_offset && tile_x > @gps_map_center_x + x_offset
      return nil
    else
      # location - Left GPS edge of map. Should be in Integers
      distance_from_left = (@gps_map_center_x + x_offset) - (tile_x)
      puts "distance_from_left = tile_x - (@gps_map_center_x + x_offset)"
      puts "#{distance_from_left} = #{tile_x} - (#{@gps_map_center_x} + #{x_offset})"

      # bUILDING LOCATION ON TRIGGER : 126 - 125
      # distance_from_left = tile_x - (@gps_map_center_x - x_offset) - 1
      # 5.0 = 126 - (124 - 4.0) - 1

      # Not sure if the
      distance_from_top  = tile_y - (@gps_map_center_y - y_offset)

      x = (distance_from_left * @tile_pixel_width ) + @tile_pixel_width  / 2.0
      y = (distance_from_top  * @tile_pixel_height) + @tile_pixel_height / 2.0
      return [x, y]
    end
  end

  # This is printing out in the wrong order. 249, 249 is reading as 0,0
  # This is confusing.
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
    # Doesn't work with recenter function
    if @map_inited && @debug

      @visual_map_of_visible_to_map.each_with_index do |y_row, index|
        # print_visible_map if y_row.nil? || y_row.empty? || y_row.length != VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1
        raise "Y Column was nil" if y_row.nil? || y_row.empty?
        raise "Y Column size wasn't correct. Expected #{VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH}. GOT: #{y_row.length}" if y_row.length != VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH
      end

      # puts "verify_visible_map"
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
          element = @visual_map_of_visible_to_map[int][outer_int]
        end
        outer_int += 1
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
        # puts "START MAP NOT VERIFIABLE"
        # print_visible_map
        # puts "END   MAP NOT VERIFIABLE"
      end
    end
  end


  def update center_target_map_pixel_movement_x, center_target_map_pixel_movement_y, buildings, pickups, projectiles, viewable_pixel_offset_x, viewable_pixel_offset_y
    raise "WRONG MAP WIDTH! Expected #{VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH} Got #{@visible_map[0].length}" if @visible_map[0].length != VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH
    raise "WRONG MAP HEIGHT! Expected #{VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT} Got #{@visible_map.length}" if @visible_map.length != VISIBLE_MAP_HEIGHT + EXTRA_MAP_HEIGHT

    if @debug
      # puts "@gps_map_center_y: #{@gps_map_center_y}, @gps_map_center_x: #{@gps_map_center_x}"
    end

    @time_alive += 1

    # viewable_pixel_offset_x, viewable_pixel_offset_y

    @current_map_pixel_center_x = center_target_map_pixel_movement_x if @current_map_pixel_center_x.nil?
    @current_map_pixel_center_y = center_target_map_pixel_movement_y if @current_map_pixel_center_y.nil?

    # puts "PLAYER: #{player_x} - #{player_y} against #{@current_map_pixel_center_x} - #{@current_map_pixel_center_y}"
    @local_map_movement_y = (center_target_map_pixel_movement_y + viewable_pixel_offset_y) - @current_map_pixel_center_y
    # puts "@local_map_movement_y = #{@local_map_movement_y}"
    # puts "#{@local_map_movement_y} = #{player_y} -#{ @current_map_pixel_center_y}"
    @local_map_movement_x = (center_target_map_pixel_movement_x + viewable_pixel_offset_x) - @current_map_pixel_center_x
    # puts "HERE:#{ @local_map_movement_x} = (#{center_target_map_pixel_movement_x} + #{viewable_offset_x}) - #{@current_map_pixel_center_x}"
    # puts "@local_map_movement_x = #{@local_map_movement_x}"

    # player.relative_object_offset_x = @local_map_movement_x
    # player.relative_object_offset_y = @local_map_movement_y

    tile_movement = false

    tile_movement_x = nil
    tile_movement_y = nil

    # 1 should be 1 GPS coord unit. No height scale should be on it.
    if @local_map_movement_y >= @tile_pixel_height# / VISIBLE_MAP_HEIGHT.to_f# * @height_scale * 1.1
      puts "ADDING IN ARRAY 1"
      tile_movement = true
      if @current_map_pixel_center_y < (@map_pixel_height)
        # puts "CURRENT WAS LESS THAN EXTERNIOR: #{@current_map_pixel_center_y} - #{EXTERIOR_MAP_HEIGHT}"
        @gps_map_center_y += 1 # Should this be getting smaller... maybe amybe not
        # value = nil
        # @y_add_top_tracker << @y_top_tracker
        # Show edge of map
        if @gps_map_center_y + @gps_tile_offset_y > (@map_tile_height)
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
            x_index = @map_tile_width - @gps_map_center_x + visible_width - @gps_tile_offset_x
            if x_index < @map_tile_width && x_index >= 0
              # Flipping Y Axis when retrieving from map data
              y_index = (@map_tile_height - ((@gps_map_center_y) + @gps_tile_offset_y))
              # puts "(@map_tile_height - ((@gps_map_center_y) + @gps_tile_offset_y)) - 1"
              # puts "(#{@map_tile_height} - ((#{@gps_map_center_y}) + #{@gps_tile_offset_y})) - 1"
              # (250 - ((126) + 9)) - 1
              # puts y_index
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @map_tile_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          # X is coming in on the wrong side?
          # new_array.reverse!

          @visible_map.unshift(new_array)

          @visual_map_of_visible_to_map.unshift(new_debug_array)

          # verify_visible_map

          # value = "INSIDE MAP"
        end
        # puts "MAP ADDED at #{@current_map_pixel_center_y} w/ - top tracker: #{@y_top_tracker}"
        tile_movement_y       = -@tile_pixel_height
        @current_map_pixel_center_y = @current_map_pixel_center_y + @tile_pixel_height# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_y = @local_map_movement_y - @tile_pixel_height# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_y = 0 if @local_map_movement_y > 0
      end
    end






    # Adding to bottom of map
    # Convert on screen movement to map
    if @local_map_movement_y <= -@tile_pixel_height# / VISIBLE_MAP_HEIGHT.to_f
      puts "ADDING IN ARRAY 2"
      tile_movement = true
      if @current_map_pixel_center_y > 0
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
          # puts "ADDING NORMALLY - #{@current_map_pixel_center_y} -#{ @gps_tile_offset_y} > 0"
          @visible_map.shift
          @visual_map_of_visible_to_map.shift
          # @y_add_top_tracker << (player_y + y_offset)
          new_array = []
          new_debug_array = []
          (0..VISIBLE_MAP_WIDTH + EXTRA_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
            x_index = @map_tile_width - @gps_map_center_x + visible_width - @gps_tile_offset_x
            if x_index < @map_tile_width && x_index >= 0
              # puts "(@map_tile_height - ((local_gps_map_center_y ) - @gps_tile_offset_y)) - 1"
              # puts "(#{@map_tile_height} - ((#{local_gps_map_center_y }) - #{@gps_tile_offset_y})) - 1"
              # puts "#{(@map_tile_height - ((local_gps_map_center_y ) - @gps_tile_offset_y)) - 1}"
              # - 1 for array indexing. - WRONG
              # y_index = (@map_tile_height - ((local_gps_map_center_y ) - @gps_tile_offset_y)) - 1
              y_index = (@map_tile_height - ((local_gps_map_center_y ) - @gps_tile_offset_y))
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @map_tile_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          # X is coming in on the wrong side?
          # new_array.reverse!

          @visible_map.push(new_array)

          @visual_map_of_visible_to_map.push(new_debug_array)

          # verify_visible_map

          # value = "INSIDE MAP"
        end
        # puts "MAP ADDED at #{@current_map_pixel_center_y} w/ - top tracker: #{@y_top_tracker}"
        tile_movement_y       = @tile_pixel_height
        @current_map_pixel_center_y = @current_map_pixel_center_y - @tile_pixel_height# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_y = @local_map_movement_y + @tile_pixel_height# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_y = 0 if @local_map_movement_y > 0
      end
    end


    # Moving to the RIGHT
    # if @local_map_movement_x >= @tile_pixel_width 
    #   puts "TEST HERE: #{@gps_map_center_x} - #{@map_tile_width}"
    # end
    if @local_map_movement_x >= @tile_pixel_width && !(@gps_map_center_x >= @map_tile_width - 1)
      puts "ADDING IN ARRAY 3 "
      puts "!(@gps_map_center_x >= @map_tile_width)"
      puts "!(#{@gps_map_center_x} >= #{@map_tile_width})"
      puts "#{!(@gps_map_center_x >= @map_tile_width)}"
      tile_movement = true
      # print_visible_map
      if @current_map_pixel_center_x < (@map_pixel_width)
        puts "PRE GPS MAP CENTER X: #{@gps_map_center_x}"
        @gps_map_center_x    += 1
        puts "POST GPS MAP CENTER X #{@gps_map_center_x}"

        if @gps_map_center_x + @gps_tile_offset_x > (@map_tile_width)
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
            y_index = @map_tile_height - @gps_map_center_y + visible_height - @gps_tile_offset_x
            # y_offset = visible_height  - VISIBLE_MAP_HEIGHT  / V
            # y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
            # y_index = @map_tile_height - @gps_map_center_y + y_offset
            if y_index < @map_tile_height && y_index >= 0
              # IMPLEMENT!!!
              x_index = (@map_tile_width - ((@gps_map_center_x) + @gps_tile_offset_x))
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @map_tile_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          new_array.each_with_index do |element, index|
            @visible_map[index].unshift(element)
          end
          new_debug_array.each_with_index do |element, index|
            @visual_map_of_visible_to_map[index].unshift(element)
          end
          # verify_visible_map
        end
        # puts "MAP ADDED at #{@current_map_pixel_center_y} w/ - top tracker: #{@y_top_tracker}"
        tile_movement_x       = @tile_pixel_height
        @current_map_pixel_center_x = @current_map_pixel_center_x + @tile_pixel_width# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_x = @local_map_movement_x - @tile_pixel_width# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_x = 0 if @local_map_movement_x > 0
      end
    end
  

    # MOVING TO THE LEFT
    if @local_map_movement_x <= -@tile_pixel_width# * @width_scale * 1.1
      puts "ADDING IN ARRAY 4"
      # print_visible_map
      if @current_map_pixel_center_x < (@map_pixel_width)
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
            y_index = (@map_tile_height - @gps_map_center_y + visible_height - @gps_tile_offset_x)
            # y_offset = visible_height  - VISIBLE_MAP_HEIGHT  / V
            # y_offset = y_offset - EXTRA_MAP_HEIGHT / 2
            # y_index = @map_tile_height - @gps_map_center_y + y_offset
            if y_index < @map_tile_height && y_index >= 0
              # IMPLEMENT!!!
              x_index = (@map_tile_width - ((@gps_map_center_x) - @gps_tile_offset_x)) - 1
              new_array << @map_data[y_index][x_index]
              new_debug_array << "#{y_index}, #{x_index}"
            else
              # puts "ARRAY 1 - X WAS OUT OF BOUNDS - #{clean_gps_map_center_x + x_offset}"
              new_debug_array << "N/A"
              new_array << {'height' => 2, 'terrain_index' => 3 }
            end
            # puts "VISIBLE_MAX 0 X #{index_w} = @map_data[#{( @map_tile_height - @y_top_tracker )}][#{clean_gps_map_center_x + x_offset}]"
          end

          new_array.each_with_index do |element, index|
            @visible_map[index].push(element)
          end
          new_debug_array.each_with_index do |element, index|
            @visual_map_of_visible_to_map[index].push(element)
          end
          # verify_visible_map
        end
        tile_movement_x       = -@tile_pixel_height
        @current_map_pixel_center_x = @current_map_pixel_center_x - @tile_pixel_width# / VISIBLE_MAP_HEIGHT.to_f
        @local_map_movement_x = @local_map_movement_x + @tile_pixel_width# / VISIBLE_MAP_HEIGHT.to_f
      else
        # Without this, you stick to the edge of the map?
        @local_map_movement_x = 0 if @local_map_movement_x > 0
      end
    end

    # puts "aFTER EVERYTING"
    # print_visible_map
    verify_visible_map
    # puts "aFTER EVERYTING"
    # Reject here or in game_window, if off of map? Still need to update enemies that can move while off-screen

    # ADD BACK IN AFTER MAP FIXED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # Not buildings though, they are updated elsewhere - in exec_gl
    # projectiles = update_objects_relative_to_map(@local_map_movement_x, @local_map_movement_y, projectiles, tile_movement_x, tile_movement_y)
    # projectiles.reject!{|p| p == false }

    # raise "OFFSET IS OFF @y_top_tracker - offset_y != @gps_map_center_y: #{@y_top_tracker} - #{offset_y} != #{@gps_map_center_y}"       if @y_top_tracker     - offset_y != @gps_map_center_y
    # raise "OFFSET IS OFF @y_bottom_tracker + offset_y != @gps_map_center_y: #{@y_bottom_tracker} + #{offset_y} != #{@gps_map_center_y}" if @y_bottom_tracker  + offset_y != @gps_map_center_y
    # raise "OFFSET IS OFF @x_right_tracker - offset_x != @gps_map_center_x: #{@x_right_tracker} - #{offset_x} != #{@gps_map_center_x}"   if @x_right_tracker   - offset_x != @gps_map_center_x
    # raise "OFFSET IS OFF @x_left_tracker + offset_x != @gps_map_center_x: #{@x_left_tracker} + #{offset_x} != #{@gps_map_center_x}"     if @x_left_tracker    + offset_x != @gps_map_center_x
    return {pickups: pickups, buildings: buildings, projectiles: projectiles}
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
  NEAR_VALUE = 1
  FAR_VALUE  = 12
  NDC_X_LENGTH  = 0.1
  NDC_Y_LENGTH  = 0.1
  
  # player param is soley used for debugging
  def exec_gl player, player_x, player_y, projectiles, buildings, pickups
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

    
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    # void glFrustum( GLdouble left,
    #   GLdouble right,
    #   GLdouble bottom,
    #   GLdouble top,
    #   GLdouble nearVal,
    #   GLdouble farVal);

    # nearVal = 1
    # farVal = 100
    glFrustum(-NDC_X_LENGTH, NDC_X_LENGTH, -NDC_Y_LENGTH, NDC_Y_LENGTH, NEAR_VALUE, FAR_VALUE)
    # gluPerspective(45.0, 800 / 600 , 0.1, 100.0)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity

    # // Move the scene back so we can see everything
    # glTranslatef( 0.0f, 0.0f, -100.0f );
    # -10 is as far back as we can go.
    glTranslated(0, 0, -FAR_VALUE)


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
    gps_offs_y = @local_map_movement_y / (@tile_pixel_height )
    gps_offs_x = @local_map_movement_x / (@tile_pixel_width )
    # puts "gps_offs_y = @local_map_movement_y / (@tile_pixel_height )"
    # puts "#{gps_offs_y} = #{@local_map_movement_y} / (#{@tile_pixel_height} )"
    screen_offset_x = @tile_pixel_width  * gps_offs_x * -1
    screen_offset_y = @tile_pixel_height * gps_offs_y * -1
    # puts "@screen_pixel_width, @screen_pixel_height, screen_offset_x, screen_offset_y"
    # puts [@screen_pixel_width, @screen_pixel_height, screen_offset_x, screen_offset_y  ]
    offset_result = GeneralObject.convert_screen_pixels_to_opengl(@screen_pixel_width, @screen_pixel_height, screen_offset_x, screen_offset_y)
    opengl_offset_x = offset_result[:o_x]# >= @tile_pixel_width ? 0 : offset_result[:o_x]
    opengl_offset_y = offset_result[:o_y]# >= @tile_pixel_height ? 0 : offset_result[:o_y]
    # raise "SHOUD NOT BE NIL" if opengl_offset_x.nil? || opengl_offset_y.nil?

    # puts "OLD OPENGL: #{opengl_offset_y}"
    # opengl_offset_y = opengl_offset_y * -1
    # puts "NEW OPENGL: #{opengl_offset_y}"

    # puts "OFF_Y: #{@local_map_movement_y / (@tile_pixel_height ) }= #{@local_map_movement_y} / (#{@tile_pixel_height} )" 
    # offs_x = offs_x + 0.1

    # Cool lighting
    # glEnable(GL_LIGHTING)

    #   glLightfv(GL_LIGHT0, GL_AMBIENT, [0.5, 0.5, 0.5, 1])
    #   glLightfv(GL_LIGHT0, GL_DIFFUSE, [1, 1, 1, 1])
    #   glLightfv(GL_LIGHT0, GL_POSITION, [1, 1, 1,1])
    #   glLightfv(GL_LIGHT1, GL_AMBIENT, [0.5, 0.5, 0.5, 1])
    #   glLightfv(GL_LIGHT1, GL_DIFFUSE, [1, 1, 1, 1])
    #   glLightfv(GL_LIGHT1, GL_POSITION, [100, 100, 100,1])
  
    # @enable_dark_mode = true
    @enable_dark_mode = false

    if @enable_dark_mode
      # glLightfv(GL_LIGHT6, GL_AMBIENT, [0.5, 0.5, 0.5, 1])
      # glLightfv(GL_LIGHT6, GL_DIFFUSE, [0.5, 0.5, 0.5, 1])
      # # Dark lighting effect?
      # glLightfv(GL_LIGHT6, GL_POSITION, [0, 0, 0,-1])
      # glEnable(GL_LIGHT6)
    else
      # glLightfv(GL_LIGHT6, GL_AMBIENT, [1, 1, 1, 1])
      # glLightfv(GL_LIGHT6, GL_DIFFUSE, [1, 1, 1, 1])
      # # Dark lighting effect?
      # glLightfv(GL_LIGHT6, GL_POSITION, [0, 0, 0,-1])
      # glEnable(GL_LIGHT6)
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
    # @test = true

    # gluProject(world_coords[0], world_coords[1], world_coords[2],
    # modelview.data(), projection.data(),
    # screen_coords.data(), screen_coords.data() + 1, screen_coords.data() + 2);

    if !@test
      glEnable(GL_TEXTURE_2D)
      # Not sure the next 3 methods do anything
      # glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE )
      # glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE )
      # glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE)
      tile_row_y_max = @visible_map.length #@visible_map.length - 1 - (EXTRA_MAP_HEIGHT)
      @visible_map.each_with_index do |y_row, y_index|
        tile_row_x_max = y_row.length # y_row.length - 1 - (EXTRA_MAP_WIDTH)
        y_row.each_with_index do |x_element, x_index|
          # puts "element - #{x_index} #{y_index} "

          # splits across middle 0  -7..0..7 if visible map is 15
          new_x_index = x_index - (tile_row_x_max / 2.0)
          new_y_index = y_index - (tile_row_y_max / 2.0)

          # Screen coords width and height here.
          screen_x = @tile_pixel_width   * new_x_index
          # puts "screen_x = @tile_pixel_width   * new_x_index"
          # puts "#{screen_x} = #{@tile_pixel_width}   * #{new_x_index}"
          screen_y = @tile_pixel_height  * new_y_index
          # puts "screen_y = @tile_pixel_height  * new_y_index"
          # puts "#{screen_y} = #{@tile_pixel_height}  * #{new_y_index}"

          # result = convert_screen_to_opengl(screen_x, screen_y, @tile_pixel_width, @tile_pixel_height)
          result = GeneralObject.convert_screen_pixels_to_opengl(@screen_pixel_width, @screen_pixel_height, screen_x, screen_y, @tile_pixel_width, @tile_pixel_height)
          # puts "X and Y INDEX: #{x_index} - #{y_index}"
          # puts "RESULT HERE: #{result}"
          opengl_coord_x = result[:o_x]
          opengl_coord_y = result[:o_y]
          # opengl_coord_y = opengl_coord_y * -1
          # opengl_coord_x = opengl_coord_x * -1
          opengl_increment_x = result[:o_w]
          opengl_increment_y = result[:o_h]

          # raise "SHOUD NOT BE NIL" if opengl_coord_x.nil? || opengl_coord_y.nil?
          # raise "SHOUD NOT BE NIL" if opengl_increment_x.nil? || opengl_increment_y.nil?
          # puts "NEW DATA TILE OPENGL DATA: #{[opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y]}"

          # result = convert_screen_to_opengl(screen_x, screen_y, @tile_pixel_width, @tile_pixel_height)
          # opengl_coord_x = result[:o_x]
          # opengl_coord_y = result[:o_y]
          # # opengl_coord_y = opengl_coord_y * -1
          # # opengl_coord_x = opengl_coord_x * -1
          # opengl_increment_x = result[:o_w]
          # opengl_increment_y = result[:o_h]

          # raise "SHOUD NOT BE NIL" if opengl_coord_x.nil? || opengl_coord_y.nil?
          # raise "SHOUD NOT BE NIL" if opengl_increment_x.nil? || opengl_increment_y.nil?
          # puts "ORIGINAL DATA TILE OPENGL DATA: #{[opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y]}"

          # NEW DATA TILE OPENGL DATA: [-1.0, -1.0, 0.25, 0.25]
          # ORIGINAL DATA TILE OPENGL DATA: [-1.25, -2.25, 0.25, 0.25]

          # NEW DATA TILE OPENGL DATA: [-1.0, -1.0, 0.25, 0.25]
          # ORIGINAL DATA TILE OPENGL DATA: [-1.0, -2.25, 0.25, 0.25]
          # NEW DATA TILE OPENGL DATA: [-1.0, -1.0, 0.25, 0.25]
          # ORIGINAL DATA TILE OPENGL DATA: [-0.75, -2.25, 0.25, 0.25]
          # NEW DATA TILE OPENGL DATA: [-1.0, -1.0, 0.25, 0.25]
          # ORIGINAL DATA TILE OPENGL DATA: [-0.5, -2.25, 0.25, 0.25]
          # NEW DATA TILE OPENGL DATA: [-1.0, -1.0, 0.25, 0.25]
          # ORIGINAL DATA TILE OPENGL DATA: [-0.25, -2.25, 0.25, 0.25]
          # NEW DATA TILE OPENGL DATA: [-1.0, -1.0, 0.25, 0.25]
          # ORIGINAL DATA TILE OPENGL DATA: [0.0, -2.25, 0.25, 0.25]
          # NEW DATA TILE OPENGL DATA: [-1.0, -1.0, 0.25, 0.25]
          # ORIGINAL DATA TILE OPENGL DATA: [0.25, -2.25, 0.25, 0.25]

          
          info =  @infos[x_element['terrain_index']]

          if x_element['corner_heights']
            z = x_element['corner_heights']
          else
            z = {'bottom_right' =>  1, 'bottom_left' =>  1, 'top_right' =>  1, 'top_left' =>  1}
          end

          if @debug
            # puts "x_element: #{x_element}"
            # puts "CONVERTING OPENGL TO SCREEN"
            # puts "OX: #{opengl_coord_x - opengl_offset_x} = #{opengl_coord_x} - #{opengl_offset_x}"
            # puts "OY: #{opengl_coord_y - opengl_offset_y} = #{opengl_coord_y} - #{opengl_offset_y}"
            # x, y = convert_opengl_to_screen(opengl_coord_x - opengl_offset_x, opengl_coord_y - opengl_offset_y)
            # puts "@font: x, y = #{x}, #{y}"

            # get2dPoint(o_x, o_y, o_z, viewMatrix, projectionMatrix, screen_pixel_width, screen_pixel_height)
            # result = get2dPoint(x, y , x_element["height"], glGetFloatv(GL_MODELVIEW_MATRIX), glGetFloatv(GL_PROJECTION_MATRIX), @screen_pixel_width, @screen_pixel_height)
            # @font.draw("X #{x_element["gps_x"]} & Y #{x_element["gps_y"]}", result[0], @screen_pixel_height - result[1], ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
          end

# XELEMENT: {"height"=>0.570810370974101, "terrain_index"=>0, "corner_heights"=>{"top_left"=>0.5, "top_right"=>0.75, "bottom_left"=>0.75, "bottom_right"=>1.25}, "gps_y"=>128, "gps_x"=>128}
# {"height"=>0.570810370974101, "terrain_index"=>0, "corner_heights"=>{"top_left"=>0.5, "top_right"=>0.75, "bottom_left"=>0.75, "bottom_right"=>1.25}, "gps_y"=>128, "gps_x"=>128}

          glBindTexture(GL_TEXTURE_2D, info.tex_name)

          lights = [{pos: [0,0], brightness: 0.4, radius: 0.5}]
          # Too slow.. FPS droppage
          # projectiles.each do |p|
            # Needs to be updated from x y to map x and map y
            # results = convert_screen_to_opengl(p.x, p.y, nil, nil, true)
            # lights << {pos: [(results[:o_x]), (results[:o_y] * -1)], brightness: 0.3, radius: 0.5}
          # end

          if @enable_dark_mode
            default_colors = [0.3, 0.3, 0.3, 0.3]
          else
            default_colors = [1, 1, 1, 1]
          end
          # left-top, left-bottom, right-top, right-bottom
          vert_pos1, vert_pos2, vert_pos3, vert_pos4 = [nil,nil,nil,nil]
          glBegin(GL_TRIANGLE_STRIP)
            glTexCoord2d(info.left, info.top)
            vert_pos1 = [opengl_coord_x - opengl_offset_x, opengl_coord_y - opengl_offset_y, z['top_left']]
            colors = @enable_dark_mode ? apply_lighting(default_colors, vert_pos, lights) : default_colors
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos1[0], vert_pos1[1], vert_pos1[2])



            glTexCoord2d(info.left, info.bottom)
            vert_pos2 = [opengl_coord_x - opengl_offset_x, opengl_coord_y + opengl_increment_y - opengl_offset_y, z['bottom_left']]
            colors = @enable_dark_mode ? apply_lighting(default_colors, vert_pos, lights) : default_colors
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos2[0], vert_pos2[1], vert_pos2[2])

            glTexCoord2d(info.right, info.top)
            vert_pos3 = [opengl_coord_x + opengl_increment_x - opengl_offset_x, opengl_coord_y - opengl_offset_y, z['top_right']]
            colors = @enable_dark_mode ? apply_lighting(default_colors, vert_pos, lights) : default_colors
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos3[0], vert_pos3[1], vert_pos3[2])

            glTexCoord2d(info.right, info.bottom)
            vert_pos4 = [opengl_coord_x + opengl_increment_x - opengl_offset_x, opengl_coord_y + opengl_increment_y - opengl_offset_y, z['bottom_right']]
            colors = @enable_dark_mode ? apply_lighting(default_colors, vert_pos, lights) : default_colors
            glColor4d(colors[0], colors[1], colors[2], colors[3])
            glVertex3d(vert_pos4[0], vert_pos4[1], vert_pos4[2])
          glEnd


          # Both these buildings and pickups drawing methods work. Building is more attached to the terrain.
          # Building draw the tile here
          # Pickups update the x and y coords, and then the pickup draws itself.
          buildings.each do |building|
            next if building.current_map_tile_x != x_element['gps_x'] || building.current_map_tile_y != x_element['gps_y']
            if building.respond_to?(:alt_alt_draw)
              # puts "UPDATING BUILDING ALT ALT"
              building.update_from_3D(vert_pos1, vert_pos2, vert_pos3, vert_pos4, x_element['height'], glGetFloatv(GL_MODELVIEW_MATRIX), glGetFloatv(GL_PROJECTION_MATRIX), glGetFloatv(GL_VIEWPORT))

              # building.alt_draw(opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y, x_element['height'])

              # building.alt_draw(opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y, x_element['height'])
            else
              building.class.tile_draw_gl(vert_pos1, vert_pos2, vert_pos3, vert_pos4)
            end
            # building.update_from_3D(vert_pos1, vert_pos2, vert_pos3, vert_pos4, x_element['height'], glGetFloatv(GL_MODELVIEW_MATRIX), glGetFloatv(GL_PROJECTION_MATRIX), glGetFloatv(GL_VIEWPORT))
          end

          pickups.each do |pickup|
            next if pickup.current_map_tile_x != x_element['gps_x'] || pickup.current_map_tile_y != x_element['gps_y']
            pickup.update_from_3D(vert_pos1, vert_pos2, vert_pos3, vert_pos4, x_element['height'], glGetFloatv(GL_MODELVIEW_MATRIX), glGetFloatv(GL_PROJECTION_MATRIX), glGetFloatv(GL_VIEWPORT))
          end

          
          if player.current_map_tile_x == x_element['gps_x'] && player.current_map_tile_y == x_element['gps_y']
            # puts "XELEMENT of Current Player: #{x_element}"
            # XELEMENT of Current Player: {"height"=>0.23451606664978608, "terrain_index"=>0,
            #   "corner_heights"=>{"top_left"=>0.0, "top_right"=>0.0, "bottom_left"=>0.0, "bottom_right"=>0.25},
            #   "gps_y"=>122, "gps_x"=>115}
          end

          error = glGetError
          if error != 0
            puts "FOUND ERROR: #{error}"
          end

        end
      end
    end
  end
 
  # def get2dPoint(o_x, o_y, o_z, viewMatrix, projectionMatrix, screen_pixel_width, screen_pixel_height)
  #   puts "viewMatrix"
  #   viewMatrix.matrix_to_s
  #   puts "projectionMatrix"
  #   projectionMatrix.matrix_to_s
  #   viewProjectionMatrix = projectionMatrix * viewMatrix;
  #   # //transform world to clipping coordinates
  #   puts "viewProjectionMatrix"
  #   puts viewProjectionMatrix.matrix_to_s
  #   puts "VECTOR HERE: #{[o_x, o_y, o_z]}"
  #   point3D = viewProjectionMatrix.vector_mult([o_x, o_y, o_z, 0.999])
  #   x = ((( point3D[0] + 1 ) / 2.0) * screen_width )
  #   x = x / point3D[3]
  #   # //we calculate -point3D.getY() because the screen Y axis is
  #   # //oriented top->down 
  #   y = ((( 1 - point3D[1] ) / 2.0) * screen_height )
  #   y = y / point3D[3]
  #   # doesn't point3D[2] do anything? Depth?
  #   puts "RETURNING: #{[x, y]}"
  #   return [x, y];
  # end

# def orldToScreen(vector = [1,2,3], )
#     {
#       Matrix4 model, proj;
#       int[] view = new int[4];

#       GL.GetFloat(GetPName.ModelviewMatrix, out model);
#       GL.GetFloat(GetPName.ProjectionMatrix, out proj);
#       GL.GetInteger(GetPName.Viewport, view);

#       double wx = 0, wy = 0, wz = 0;

#       int d = Glu.gluProject
#                       (
#                         p.X, 
#                         p.Y, 
#                         p.Z, 
#                         model, 
#                         proj, 
#                         view, 
#                         ref wx, 
#                         ref wy, 
#                         ref wz
#                       );

#       return new Point((int)wx, (int)wy);
#     }
# int gluProject
#   (
#    float objx, 
#    float objy, 
#    float objz, 
#    Matrix4 modelMatrix, 
#    Matrix4 projMatrix, 
#    int[] viewport, 
#    ref double winx, 
#    ref double winy, 
#    ref double winz
#   )
#   {
#       Vector4 _in;
#       Vector4 _out;

#       _in.X = objx;
#       _in.Y = objy;
#       _in.Z = objz;
#       _in.W = 1.0f;
#       //__gluMultMatrixVecd(modelMatrix, in, out); // Commented out by code author
#       //__gluMultMatrixVecd(projMatrix, out, in);  // Commented out by code author
#       //TODO: check if multiplication is in right order
#       _out = Vector4.Transform(_in, modelMatrix);
#       _in = Vector4.Transform(_out, projMatrix);

#       if (_in.W == 0.0)
#         return (0);
#       _in.X /= _in.W;
#       _in.Y /= _in.W;
#       _in.Z /= _in.W;
#       /* Map x, y and z to range 0-1 */
#       _in.X = _in.X * 0.5f + 0.5f;
#       _in.Y = _in.Y * 0.5f + 0.5f;
#       _in.Z = _in.Z * 0.5f + 0.5f;

#       /* Map x,y to viewport */
#       _in.X = _in.X * viewport[2] + viewport[0];
#       _in.Y = _in.Y * viewport[3] + viewport[1];

#       winx = _in.X;
#       winy = _in.Y;
#       winz = _in.Z;
#       return (1);
#   }

#   test1 = [
#     [1, 2, 0],
#     [0, 1, 1],
#     [2, 0, 1]
#   ]

#   test2 = [
#     [1, 1, 2],
#     [2, 1, 1],
#     [1, 2, 1]
#   ]
#   test3 = test1 * test2
# # class Array
# #   def * array2
# #     max_length = array1.length
# #     new_array = Array.new(max_length) { Array.new(max_length) { nil } }

# #     # for (c = 0; c < m; c++) {
# #     (0..max_length - 1) do |c|
# #       # for (d = 0; d < q; d++) {
# #       (0..max_length - 1) do |d|
# #         # for (k = 0; k < p; k++) {
# #         sum = 0
# #         (0..max_length - 1) do |k|
# #           sum += self[c][k] * array2[k][d];
# #         end
 
# #         new_array[c][d] = sum;
# #         sum = 0;
# #       end
# #     end

# #     return new_array
# #   end
# # end

  # All coords are in openGL
  # Use light attenuation
  # def apply_lighting colors_array, vertex = [], lights = [{pos: [0,0], brightness: 0.1, radius: 0.3}, {pos: [0,0], brightness: 0.3, radius: 0.1}]
  def apply_lighting colors_array, vertex = [], lights = [{pos: [0,0], brightness: 0.2, radius: 0.3}]
    # Operates in screen coords
    # Gosu.distance(@x, @y, object.x, object.y) < self.get_radius + object.get_radius
    # Wee ned to operate in opengl coords
    lights.each do |light|
      distance = Gosu.distance(vertex[0], vertex[1], light[:pos][0], light[:pos][1])

      if distance <= light[:radius]
        # Attenuation here
        new_brightness_factor = light[:brightness] - (light[:brightness] / (light[:radius] / distance))
        colors_array[0] = clamp_brightness(colors_array[0] + new_brightness_factor)
        colors_array[1] = clamp_brightness(colors_array[1] + new_brightness_factor)
        colors_array[2] = clamp_brightness(colors_array[2] + new_brightness_factor)
      end
    end
    return colors_array
  end

  def clamp_brightness(comp_value)
    return clamp(comp_value, 0, 1)
  end

  def clamp(comp_value, min, max)
    if comp_value >= min && comp_value <= max
      return comp_value
    elsif comp_value < min
      return min
    else
      return max
    end
  end

end