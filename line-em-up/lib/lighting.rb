# require 'gosu'
# require 'glfw'
# require 'opengl'

# OpenGL.load_dll
# GLFW.load_dll

# include OpenGL
# include GLFW

# SHADOW_LENGTH = 20000

# module GosuLighting
#   class Source
#     attr_accessor :x, :y, :radius

#     def initialize window, x, y, radius, att_sprite = nil
#       @att_sprite = att_sprite || Gosu::Image.new(window, 'light.png', true)
#       @window = window
#       @x = x
#       @y = y
#       @radius = radius
#     end

#     def shadow_circle circle, depth = 1
#       dist = Gosu::distance @x, @y, circle.x, circle.y
#       depth = depth + 1.0 - dist / SHADOW_LENGTH

#       bx1, by1, bx2, by2 = endpoints_facing circle.x, circle.y, @x, @y, circle.radius

#       nx1, ny1 = normal @x, @y, bx1, by1
#       nx2, ny2 = normal @x, @y, bx2, by2

#       sx1 = bx1 + nx1 * SHADOW_LENGTH
#       sy1 = by1 + ny1 * SHADOW_LENGTH
#       sx2 = bx2 + nx2 * SHADOW_LENGTH
#       sy2 = by2 + ny2 * SHADOW_LENGTH

#       @window.gl depth do
#         gl_draw_shadow bx1, by1, sx1, sy1, sx2, sy2, bx2, by2, 0.5
#       end

#       return depth
#     end

#     def shadow_rectangle rect, depth = 2
#       dist = Gosu::distance @x, @y, rect.center_x, rect.center_y
#       depth = depth + 1.0 - dist / SHADOW_LENGTH

#       cx1 = cx2 = rect.x
#       cy1 = cy2 = rect.y
#       if @x < rect.x
#         cy1 += rect.height
#       elsif @x < rect.x + rect.width
#         cy1 += rect.height if @y > rect.center_y
#         cy2 = cy1
#       else
#         cy2 += rect.height
#       end

#       if @y < rect.y
#         cx2 += rect.width
#       elsif @y < rect.y + rect.height
#         cx1 += rect.width if @x > rect.center_x
#         cx2 = cx1
#       else
#         cx1 += rect.width
#       end

#       nx1, ny1 = normal @x, @y, cx1, cy1
#       nx2, ny2 = normal @x, @y, cx2, cy2

#       sx1 = cx1 + nx1 * SHADOW_LENGTH
#       sy1 = cy1 + ny1 * SHADOW_LENGTH
#       sx2 = cx2 + nx2 * SHADOW_LENGTH
#       sy2 = cy2 + ny2 * SHADOW_LENGTH

#       @window.gl depth do
#         gl_draw_shadow cx1, cy1, sx1, sy1, sx2, sy2, cx2, cy2, 1.0
#       end

#       return depth
#     end

#     def draw_attenuation depth
#       draw_as_rect @att_sprite, *clip_rect, depth, 0xff999999, :multiply
#     end

#     def draw
#       @window.clip_to(*clip_rect) do
#         yield self
#       end
#     end

#     private
#     def endpoints_facing x1, y1, x2, y2, r
#       a = Gosu::angle x1, y1, x2, y2
#       x3 = x1 + Gosu::offset_x(a + 90, r)
#       y3 = y1 + Gosu::offset_y(a + 90, r)

#       x4 = x1 + Gosu::offset_x(a - 90, r)
#       y4 = y1 + Gosu::offset_y(a - 90, r)

#       [x3, y3, x4, y4]
#     end

#     def vector x1, y1, x2, y2
#       dy = y2 - y1
#       dx = x2 - x1
#       [dx, dy]
#     end

#     def normal x1, y1, x2, y2
#       d = Gosu::distance x1, y1, x2, y2
#       x, y = vector x1, y1, x2, y2

#       [x/d, y/d]
#     end

#     def clip_rect
#       [(@x - @radius).to_i, (@y - @radius).to_i, (@radius*2.0).to_i, (@radius*2.0).to_i]
#     end

#     def draw_as_rect sprite, x, y, w, h, z, color, mode
#       sprite.draw_as_quad x, y, color, x+w, y, color, x+w, y+h, color, x, y+h, color, z, mode
#     end

#     def gl_draw_shadow x1, y1, x2, y2, x3, y3, x4, y4, alpha = 0.9
#       glDisable GL_DEPTH_TEST
#       glEnable GL_BLEND
#       glBlendEquationSeparate GL_FUNC_ADD, GL_FUNC_ADD
#       glBlendFuncSeparate GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO

#       glBegin GL_QUADS
#       glColor4f 0, 0, 0, alpha
#       glVertex3f x1, y1, 0
#       glVertex3f x2, y2, 0
#       glVertex3f x3, y3, 0
#       glVertex3f x4, y4, 0
#       glEnd
#     end
#   end
# end
