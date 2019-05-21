# require_relative 'dumb_projectile.rb'
# require 'opengl'
# # require 'ruby-opengl'
# require 'glu'
# require 'glut'

# class BackupBullet < DumbProjectile
#   DAMAGE = 3
#   COOLDOWN_DELAY = 20
#   # Friendly projects are + speeds
#   MAX_SPEED      = 15

#   def get_image
#     Gosu::Image.new("#{MEDIA_DIRECTORY}/bullet-mini.png")
#   end

#   include Gl
#   include Glu 
#   include Glut


#   def draw
#     glClearColor(0.0, 0.2, 0.5, 1.0)
#     glClearDepth(0)
#     glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
#     glDepthFunc(GL_GEQUAL)
#     glEnable(GL_DEPTH_TEST)
#     glEnable(GL_BLEND)

#     glMatrixMode(GL_PROJECTION)
#     glLoadIdentity 
#     glTranslate(0, 0, -4)
  
#     glEnable(GL_TEXTURE_2D)
#     # glBindTexture(GL_TEXTURE_2D, info.tex_name)
    
#     z = ZOrder::Projectile
#     # @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @width_scale, @height_scale)
#     # gl do
#     # points_x = 3
#     # pounts_y = 10
#     # Gosu.gl(z) {
#     #   # glColor3f(r,g,b);
#     #   0.upto(pounts_y) do |y|
#     #     0.upto(points_x) do |x|
#     #       # glColor3f(1.0, 1.0, 0.0)
#     #       glColor4d(1, 0, 0, z)
#     #       glBegin(GL_LINES)
#     #         glColor3f(1.0, 0.0, 0.0)
#     #         glVertex3d(@x + x, @y + y, z)
#     #         # glVertex3d(@x - 5, @y , z)
#     #       glEnd
#     #     end
#     #   end
#     # }

#     Gosu.gl(z) do
#       glLineWidth(50)
#       glColor3f(1.0, 0.0, 0.0)
#       glBegin(GL_LINES)
#         glVertex3f(0.0, 0.0, z)
#         glVertex3f(15, 0, z)
#       glEnd
#     end

#     # end
#   end

# end