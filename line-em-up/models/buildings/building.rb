require_relative '../background_fixed_object.rb'

# require 'glu'
require 'gosu'
require 'opengl'
require 'glut'

# include OpenGL
# include GLUT
# include GLU # - defined gluProject
module Buildings
  class Building < BackgroundFixedObject
    prepend Factionable
    include OpenGL
    include GLUT
    POINT_VALUE_BASE = 1
    HEALTH = 100
    CLASS_TYPE = :building


    # Still used?
    attr_accessor :drops

    # For radius size calculations
    def self.get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/building.png", :tileable => true)
    end

    # building by itself doesn't need 'window', it's for inheritance
    def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
      # STill used?
      @drops = @drops || options[:drops] || []
      # puts "options156123"
      # puts options.inspect
      super(current_map_tile_x, current_map_tile_y, options)
      @image = self.class.get_image
      @info = @image.gl_tex_info
      @interactible = false

    end

    def self.get_minimap_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/minimap_building.png") 
    end

    def get_minimap_image
      return self.class.get_minimap_image
    end

    def take_damage damage, owner = nil
      if !@invulnerable
        if owner
          decrease_faction_relations(owner.get_faction_id, damage)
        end
        return super(damage, owner)
      end
    end

    # def drops
    #   # rand_num = rand(10)
    #   # if rand(10) == 9
    #     [ 
    #       HealthPack.new(@current_map_tile_x, @current_map_tile_y)
    #     ]
    #     # raise "STOP"
    #   # elsif rand(10) == 8
    #   #   [BombPack.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y)]
    #   # else
    #   #   [MissilePack.new(@scale, @screen_pixel_width, @screen_pixel_height, @x, @y)]
    #   # end
    # end

    def get_draw_ordering
      ZOrder::Building
    end

    def draw viewable_pixel_offset_x, viewable_pixel_offset_y, colors = nil
      # Doesn't exactly match terrain, kinda does now, when we use the `update_from_3D` function, from gl_background.
      if @graphics_setting == :basic
        if @interactible
          if @is_hovering && @is_close_enough_to_open
            # colors = [0.5, 1, 0.5, 1]
            colors = colors || Gosu::Color.argb(0xff_80ff00)
          elsif @is_hovering
            # colors = [1, 0.5, 0.5, 1]
            colors = colors || Gosu::Color.argb(0xff_ff0000)
          else
            colors = colors || Gosu::Color.argb(0xff_ffffff)
          end
        else
          colors = colors || Gosu::Color.argb(0xff_ffffff)
        end
        @image.draw((@x - @image_width_half), (@y - @image_height_half), ZOrder::Building, @height_scale, @height_scale, colors)
      end
    end

    # def convert_screen_to_opengl x, y, w = nil, h = nil
    #   opengl_x   = ((x / (@screen_pixel_width.to_f )) * 2.0) - 1
    #   opengl_x   = opengl_x * 1.2 # Needs to be boosted for some odd reason - Screen is not entirely 1..-1
    #   opengl_y   = ((y / (@screen_pixel_height.to_f)) * 2.0) - 1
    #   opengl_y   = opengl_y * 0.92
    #   if w && h
    #     open_gl_w  = ((w / (@screen_pixel_width.to_f )) * 2.0)
    #     open_gl_h  = ((h / (@screen_pixel_height.to_f )) * 2.0)
    #     return {o_x: opengl_x, o_y: opengl_y, o_w: open_gl_w, o_h: open_gl_h}
    #   else
    #     return {o_x: opengl_x, o_y: opengl_y}
    #   end
    # end

    def tile_draw_gl v1, v2, v3, v4, colors = nil
      info = @info

      if @interactible
        if @is_hovering && @is_close_enough_to_open
          colors = colors || [0.5, 1, 0.5, 1]
        elsif @is_hovering
          colors = colors || [1, 0.5, 0.5, 1]
        else
          colors = colors || [1, 1, 1, 1]
        end
      else
        colors = colors || [1, 1, 1, 1]
      end

      glBindTexture(GL_TEXTURE_2D, info.tex_name)
      glBegin(GL_TRIANGLE_STRIP)
        # bottom left 
        glTexCoord2d(info.left, info.bottom)
        glColor4d(colors[0], colors[1], colors[2], colors[3])
        glVertex3d(v1[0], v1[1], v1[2])

        # Top Left
        glTexCoord2d(info.left, info.top)
        glColor4d(colors[0], colors[1], colors[2], colors[3])
        glVertex3d(v2[0], v2[1], v2[2])

        # bottom Right
        glTexCoord2d(info.right, info.bottom)
        glColor4d(colors[0], colors[1], colors[2], colors[3])
        glVertex3d(v3[0], v3[1], v3[2])

        # top right
        glTexCoord2d(info.right, info.top)
        glColor4d(colors[0], colors[1], colors[2], colors[3])
        glVertex3d(v4[0], v4[1], v4[2])
      glEnd
    end

    # def self.tile_draw_gl v1, v2, v3, v4
    #   @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
    #   @info = @image2.gl_tex_info

    #   info = @info
    #   colors = [1, 1, 1, 1]
    #   glBindTexture(GL_TEXTURE_2D, info.tex_name)
    #   glBegin(GL_TRIANGLE_STRIP)
    #     # bottom left 
    #     glTexCoord2d(info.left, info.bottom)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v1[0], v1[1], v1[2])

    #     # Top Left
    #     glTexCoord2d(info.left, info.top)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v2[0], v2[1], v2[2])

    #     # bottom Right
    #     glTexCoord2d(info.right, info.bottom)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v3[0], v3[1], v3[2])

    #     # top right
    #     glTexCoord2d(info.right, info.top)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v4[0], v4[1], v4[2])
    #   glEnd
    # end



    # def alt_tile_draw_gl v1, v2, v3, v4, viewMatrix, projectionMatrix, viewport
    #   @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
    #   @info = @image2.gl_tex_info

    #   info = @info
    #   colors = [1, 1, 1, 1]
    #   glBindTexture(GL_TEXTURE_2D, info.tex_name)
    #   glBegin(GL_TRIANGLE_STRIP)
    #     # bottom left 
    #     glTexCoord2d(info.left, info.bottom)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v1[0], v1[1], v1[2])

    #     # Top Left
    #     glTexCoord2d(info.left, info.top)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v2[0], v2[1], v2[2])

    #     # bottom Right
    #     glTexCoord2d(info.right, info.bottom)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v3[0], v3[1], v3[2])

    #     # top right
    #     glTexCoord2d(info.right, info.top)
    #     glColor4d(colors[0], colors[1], colors[2], colors[3])
    #     glVertex3d(v4[0], v4[1], v4[2])
    #   glEnd
    # end

    # def self.alt_alt_draw_gl v1, v2, v3, v4

    #   @image3 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png")
    #   # @info = @image2.gl_tex_info


    #   x, y = convert_opengl_to_screen(v1[0], v1[0])

    #   @image3.draw((x - @image3.width / 2), (y - @image3.height / 2), ZOrder::Building, 2, 2)

    # end


    def draw_gl
      # Draw nothing here
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options = {}
      if @interactible
        @is_hovering = @click_area.update(@x - @image_width_half, @y - @image_height_half) #if @drops.any?
        # puts "BUILDING UPDATE HERE: #{[player_map_pixel_x, player_map_pixel_y, @current_map_tile_x, @current_map_tile_y]}"
        # distance = Gosu.distance(player_map_pixel_x, player_map_pixel_y, @current_map_tile_x, @current_map_tile_y)
        distance = Gosu.distance(player_x, player_y, @x, @y)
        if @is_hovering
          if distance < @max_lootable_pixel_distance
            @is_close_enough_to_open = true
          else
            @is_close_enough_to_open = false
          end
        else
          @is_close_enough_to_open = false
        end
      else
        @is_hovering = false
        @is_close_enough_to_open = false
      end

      if is_on_screen?
        # Update from gl_background
      else
        # lol don't need to update x and y if off screen.
        # convert_map_pixel_location_to_screen(player)
        # if !@block_map_pixel_from_tile_update
        get_map_pixel_location_from_map_tile_location
        # end
      end
      is_alive = super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
      return {is_alive: is_alive}
    end

    # maybe use this in the future...
    # def opengl_update o_x, oy, oz, viewMatrix, projectionMatrix, viewport, player
    #   get_map_pixel_location_from_opengl(o_x, oy, oz, viewMatrix, projectionMatrix, viewport, player)
    # end
  end

end