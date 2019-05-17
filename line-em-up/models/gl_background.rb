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
  MAP_HEIGHT_EDGE = 700
  MAP_WIDTH_EDGE_RIGHT = 450
  MAP_WIDTH_EDGE_LEFT  = 80
  EXTERIOR_MAP_HEIGHT = 1000
  EXTERIOR_MAP_WIDTH  = 1000
  POINTS_X = 7
  VISIBLE_MAP_WIDTH = 15
  POINTS_Y = 7
  VISIBLE_MAP_HEIGHT = 15
  # Scrolling speed - higher it is, the slower the map moves
  SCROLLS_PER_STEP = 50
  # TEMP USING THIS, CANNOT FIND SCROLLING SPEED
  SCROLLING_SPEED = 4

  attr_accessor :player_position_x, :player_position_y, :map_width, :map_height

  def initialize player_x, player_y
    # @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/earth.png", :tileable => true)
    @scrolls = 0.0
    @height_map = Array.new(VISIBLE_MAP_HEIGHT) { Array.new(VISIBLE_MAP_WIDTH) { nil } }
    @local_map_movement_x = 0
    @local_map_movement_y = 0

    # @map_height = EXTERIOR_MAP_HEIGHT
    # @map_width  = EXTERIOR_MAP_WIDTH
    @player_position_x = EXTERIOR_MAP_HEIGHT / 2.0
    @player_position_y = EXTERIOR_MAP_WIDTH  / 2.0
    @map = JSON.parse(File.readlines("/Users/bendana/projects/line-em-up/line-em-up/maps/desert.txt").first)
    @terrains = @map["terrains"]
    @images = []
    @terrains.each do |terrain_path|
      @images << Gosu::Image.new(terrain_path, :tileable => true)
    end
    @map_width = @map["map_width"]
    @map_height = @map["map_height"]
    @map_data = @map["data"]
    puts "@map_data : #{@map_data[0][0]}" 
    # @height_map = []
    (0..VISIBLE_MAP_HEIGHT - 1).each_with_index do |visible_height, index_h|
      (0..VISIBLE_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
        y_offset = visible_height - VISIBLE_MAP_HEIGHT / 2
        x_offset = visible_width  - VISIBLE_MAP_WIDTH  / 2
        @height_map[index_h][index_w] = @map_data[player_y + y_offset][player_x + x_offset]
      end
    end
  end

  # def scroll factor = 1, movement_x, movement_y
  #   @scrolls += 1.0 * factor
  #   if @scrolls >= SCROLLS_PER_STEP
  #     @scrolls = 0
  #     @height_map.shift
  #     @height_map.push Array.new(POINTS_X) { rand }
  #   end
  # end

  # movement x and y reset for the map
  # player x and y does not.
  # UPDATE SCROLL FROM DATA MAP
  def scroll factor = 1, movement_x, movement_y, player_x, player_y
    # puts "GPS: #{@player_position_y}"

    # y_value = nil
    # if MAP_HEIGHT_EDGE > player_y
    #   y_value = 3
    # elsif player_y > @map_height - MAP_HEIGHT_EDGE
    #   y_value = 3
    # else
      y_value = rand
    # end

    x_value = nil
    if player_x > @map_width - MAP_WIDTH_EDGE_RIGHT
      puts "HITTING RIGHT LIMIT: #{player_x} > #{@map_width} - #{MAP_WIDTH_EDGE_RIGHT}"
      x_value = 3
    elsif player_x < MAP_WIDTH_EDGE_LEFT
      puts "HITTING LEFT LIMIT: #{player_x} < #{MAP_WIDTH_EDGE_LEFT}"
      x_value = 3
    else
      x_value = rand
    end

    # @scrolls += 1.0 * factor
    if movement_y >= SCROLLS_PER_STEP
      @height_map.shift
      @height_map.push Array.new(VISIBLE_MAP_WIDTH) { {height: y_value, terrain_index: rand(2) } }
      movement_y = 0
    end
    if movement_y <= -SCROLLS_PER_STEP
      @height_map.pop
      @height_map.unshift(Array.new(VISIBLE_MAP_HEIGHT) { {height: y_value, terrain_index: rand(2) } })
      movement_y = 0
    end

    if movement_x >= SCROLLS_PER_STEP
      # @height_map.shift
      # @height_map.push Array.new(POINTS_X) { rand }
      @height_map.each do |row|
        row.shift
        row.push({height: x_value, terrain_index: rand(2) })
      end
      movement_x = 0
    end
    if movement_x <= -SCROLLS_PER_STEP
      @height_map.each do |row|
        row.pop
        row.unshift({height: x_value, terrain_index: rand(2) })
      end
      movement_x = 0
    end

    @local_map_movement_y = movement_y
    @local_map_movement_x = movement_x

    return [movement_x, movement_y, @player_position_x, @player_position_y]
  end

  
  # Not needed
  def draw(z)
    # gl will execute the given block in a clean OpenGL environment, then reset
    # everything so Gosu's rendering can take place again.
    Gosu.gl(z) do
      glClearColor(0.0, 0.2, 0.5, 1.0)
      glClearDepth(0)
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      exec_gl
    end
  end
  
  # include Gl
  
  def exec_gl player_x, player_y
    player_x, player_y = [player_x.to_i, player_y.to_i]
    
    # Get the name of the OpenGL texture the Image resides on, and the
    # u/v coordinates of the rect it occupies.
    # gl_tex_info can return nil if the image was too large to fit onto
    # a single OpenGL texture and was internally split up.
    # puts "INCOMGING: #{player_x} - #{player_y}"
    # puts "@map_data.count: #{@map_data.count}"
    # puts "@map_data[player_y]: #{@map_data[player_y]}"
    # puts "@map_data[player_y][player_x]: #{@map_data[player_y][player_x]}"
    # terrain_index = @map_data[player_y][player_x]["terrain_index"]
    # puts "terrain_index: #{terrain_index}"
    # terrain_index
    # @height_map[7][7][:terrain_index]
    puts "@height_map.length : #{@height_map.length}"
    puts "@height_map[7][7] : #{@height_map[7][7]}"
    index = @height_map[7][7][:terrain_index]
    puts "INDEX HERER:"
    image = @images[index || 0]
    info = image.gl_tex_info
    return unless info

    # return true

    # Pretty straightforward OpenGL code.
    
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
  
    glEnable(GL_TEXTURE_2D)
    
    # puts "SCROLLS AND PER STEP: #{@scrolls / SCROLLS_PER_STEP}"
    # puts "SCROLL AND STEP: #{@scrolls} and #{SCROLLS_PER_STEP}"
    # offs_y = 1.0 * @scrolls / SCROLLS_PER_STEP
    # puts "SCROLLS AND PER STEP: #{@scrolls / SCROLLS_PER_STEP}"
    # puts "SCROLL AND STEP: #{@scrolls} and #{SCROLLS_PER_STEP}"
    # offs_y = 1.0 * @scrolls / SCROLLS_PER_STEP
    # @local_terrain_movement_y = 0.0
    # @local_terrain_movement_x = 0.0
    offs_y = 1.0 * @local_map_movement_y / SCROLLS_PER_STEP
    offs_x = 1.0 * @local_map_movement_x / SCROLLS_PER_STEP
    # puts "OFFSX: #{offs_x} - OFFSY: #{offs_y}"


    glBindTexture(GL_TEXTURE_2D, info.tex_name)
    # Offset keeps screen from clipping into blackness on the left side.
    offs_x = offs_x + 1


    # (0..VISIBLE_MAP_HEIGHT - 1).each_with_index do |visible_height, index_h|
    #   (0..VISIBLE_MAP_WIDTH - 1).each_with_index do |visible_width, index_w|
    #     y_offset = visible_height - VISIBLE_MAP_HEIGHT / 2
    #     x_offset = visible_width  - VISIBLE_MAP_WIDTH  / 2
    #     @height_map[index_h][index_w] = @map_data[player_y + y_offset][player_x + x_offset]
    #   end
    # end
    # player_x, player_y
    0.upto(VISIBLE_MAP_HEIGHT - 2) do |y|
      0.upto(VISIBLE_MAP_WIDTH - 2) do |x|
        glBegin(GL_TRIANGLE_STRIP)
        puts "WHAT IS GOING ON HERE: #{@height_map[y][x]}"
        puts "X And Y : #{x} - #{y} "
          z = @height_map[y][x]["height"] || 0.0
          # raise "no Z" if z.nil?
          glTexCoord2d(info.left, info.top)
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.top)
          glVertex3d(-0.5 + (x - offs_x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x]["height"]
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.bottom)
          glVertex3d(-0.5 + (x - offs_x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)
        
          z = @height_map[y][x + 1]["height"]
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.top)
          # puts "#{x}, #{offs_x}, #{POINTS_X}, #{y}, #{offs_y}, #{POINTS_Y}, #{z}"
          glVertex3d(-0.5 + (x - offs_x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x + 1]["height"]
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.bottom)
          glVertex3d(-0.5 + (x - offs_x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)
        glEnd
      end
    end
  end
end