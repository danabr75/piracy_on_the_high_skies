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
  POINTS_X = 7
  POINTS_Y = 7
  # Scrolling speed
  SCROLLS_PER_STEP = 50
  # TEMP USING THIS, CANNOT FIND SCROLLING SPEED
  SCROLLING_SPEED = 4

  def initialize
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/earth.png", :tileable => true)
    @scrolls = 0.0
    @height_map = Array.new(POINTS_Y) { Array.new(POINTS_X) { rand } }
    @movement_y = 0.0
    @movement_x = 0.0
  end

  # def scroll factor = 1, movement_x, movement_y
  #   @scrolls += 1.0 * factor
  #   if @scrolls >= SCROLLS_PER_STEP
  #     @scrolls = 0
  #     @height_map.shift
  #     @height_map.push Array.new(POINTS_X) { rand }
  #   end
  # end
  
  def scroll factor = 1, movement_x, movement_y
    # @scrolls += 1.0 * factor
    if movement_y >= SCROLLS_PER_STEP
      @height_map.shift
      @height_map.push Array.new(POINTS_X) { rand }
      movement_y = 0
    end
    if movement_y <= -SCROLLS_PER_STEP
      @height_map.pop
      @height_map.unshift(Array.new(POINTS_X) { rand })
      movement_y = 0
    end

    if movement_x >= SCROLLS_PER_STEP
      # @height_map.shift
      # @height_map.push Array.new(POINTS_X) { rand }
      @height_map.each do |row|
        row.shift
        row.push(rand)
      end
      movement_x = 0
    end
    if movement_x <= -SCROLLS_PER_STEP
      @height_map.each do |row|
        row.pop
        row.unshift(rand)
      end
      movement_x = 0
    end


    @movement_y = movement_y
    @movement_x = movement_x
    return [movement_x, movement_y]
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
  
  def exec_gl
    
    # Get the name of the OpenGL texture the Image resides on, and the
    # u/v coordinates of the rect it occupies.
    # gl_tex_info can return nil if the image was too large to fit onto
    # a single OpenGL texture and was internally split up.
    info = @image.gl_tex_info
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
    offs_y = 1.0 * @movement_y / SCROLLS_PER_STEP
    offs_x = 1.0 * @movement_x / SCROLLS_PER_STEP


    glBindTexture(GL_TEXTURE_2D, info.tex_name)
    
    0.upto(POINTS_Y - 2) do |y|
      0.upto(POINTS_X - 2) do |x|
        glBegin(GL_TRIANGLE_STRIP)
          z = @height_map[y][x]
          glTexCoord2d(info.left, info.top)
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.top)
          glVertex3d(-0.5 + (x - offs_x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x]
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.bottom)
          glVertex3d(-0.5 + (x - offs_x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)
        
          z = @height_map[y][x + 1]
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.top)
          glVertex3d(-0.5 + (x - offs_x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x + 1]
          # glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.bottom)
          glVertex3d(-0.5 + (x - offs_x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)
        glEnd
      end
    end
  end
end