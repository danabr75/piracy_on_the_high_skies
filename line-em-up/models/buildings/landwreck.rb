require_relative 'building.rb'
module Buildings
  class Landwreck < Buildings::Building
    CLASS_TYPE = :landwreck

    attr_accessor :drops
    attr_reader :credits

    def initialize current_map_tile_x, current_map_tile_y, item, current_scale, angle = 0, drops = [], options = {}
     # puts "LANDWRECK SCALE: #{current_scale}"
      @item = item

      super(current_map_tile_x, current_map_tile_y, nil, options.merge({drops: drops}))
      @image = @item.class.get_tilable_image(@item.class::ITEM_MEDIA_DIRECTORY)
      @info = @image.gl_tex_info

      # if @image
      #   @image_width  = @image.width  * (@width_scale  || @average_scale)
      #   @image_height = @image.height * (@height_scale || @average_scale)
      #   @image_size   = @image_width  * @image_height / 2
      #   @image_radius = (@image_width  + @image_height) / 4

      #   @image_width_half  = @image_width  / 2
      #   @image_height_half = @image_height / 2
      # end
      @colors = [1, 1, 1, 1]

      @current_scale = current_scale /  (@item.class::IMAGE_SCALER) # * 1.5
      @current_angle = angle


      # result = GeneralObject.convert_screen_pixels_to_opengl(@screen_pixel_width, @screen_pixel_height, screen_x, screen_y, @tile_pixel_width, @tile_pixel_height)
      # # puts "X and Y INDEX: #{x_index} - #{y_index}"
      # # puts "RESULT HERE: #{result}"
      # @opengl_coord_x = result[:o_x]
      # @opengl_coord_y = result[:o_y]
      # # opengl_coord_y = opengl_coord_y * -1
      # # opengl_coord_x = opengl_coord_x * -1
      # @opengl_increment_x = result[:o_w]
      # @opengl_increment_y = result[:o_h]
      @health = 1
      @window = nil

      @image_width  = @image.width  * @current_scale#(@width_scale) /  (@item.class::IMAGE_SCALER)
      @image_height = @image.height * @current_scale#(@height_scale) / (@item.class::IMAGE_SCALER)
      @image_width_half  = @image_width  / 2.0
      @image_height_half = @image_height / 2.0

      @click_area = LUIT::ClickArea.new(self, :object_inventory, 0, 0, ZOrder::HardPointClickableLocation, @image_width, @image_height, nil, nil, {hide_rect_draw: true, key_id: Gosu::KB_E})
      @button_id_mapping = {}
      @button_id_mapping[:object_inventory] = lambda { |window, menu, id|
        if !window.ship_loadout_menu.active
          window.block_all_controls = true; window.ship_loadout_menu.loading_object_inventory(menu, menu.drops, menu.credits, :lootable, {allow_credit_collection: true}); window.ship_loadout_menu.enable
        end
      }
      @is_hovering = false
      @is_close_enough_to_open = false
      @max_lootable_pixel_distance = 2 * @average_tile_size
      @credits = rand(50) # in the future, grab from AIShip.. or whatever the original owner was
      @interactible = true
      # @block_map_pixel_from_tile_update = true
    end


    def tile_draw_gl v1, v2, v3, v4
    end

    def add_credits new_credits
      @credits += new_credits
    end
    def subtract_credits new_credits
      @credits -= new_credits
    end

    def set_drops drops
      @drops = drops
      @interactible = true if @drops.any? || @credits > 0
    end
    def set_window window
      @window = window
    end

    def onClick element_id
      # puts "ONCLICK mappuing"
      # puts @button_id_mapping
      if @is_close_enough_to_open
        button_clicked_exists = @button_id_mapping.key?(element_id)
        if button_clicked_exists
         # puts "BUTTON EXISTS: #{element_id}"
          @button_id_mapping[element_id].call(@window, self, element_id)
        else
         # puts "Clicked button that is not mapped: #{element_id}"
        end
        return button_clicked_exists
      else
        return false
      end
    end

    # Need to calculate distance to player, only allow click when close, and maybe not use a left-click button to activate?  
    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options = {}
      @interactible = false if @drops.count == 0 && @credits == 0
      if @drops.count == 0
        @health = 0
      end
      return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options)
    end
    #   @is_hovering = @click_area.update(@x - @image_width_half, @y - @image_height_half) if @drops.any?
    #   distance = Gosu.distance(player.x, player.y, @x, @y)
    #   if @is_hovering
    #     if distance < @max_lootable_pixel_distance
    #       @is_close_enough_to_open = true
    #     else
    #       @is_close_enough_to_open = false
    #     end
    #   else
    #     @is_close_enough_to_open = false
    #   end
    #   return super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y)
    # end

    def draw viewable_pixel_offset_x,  viewable_pixel_offset_y
      # Why is this here?
      # @click_area.draw(@x - @image_width_half, @y - @image_height_half) if @drops.any?
      color = Gosu::Color.argb(0xff_ffffff)
      if @drops.any?
        if @is_hovering && @is_close_enough_to_open
          color = Gosu::Color.argb(0xff_e1ffcd)
        elsif @is_hovering
          color = Gosu::Color.argb(0xff_ff9479)
        end
      end
      if @item.image
        @item.image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, ZOrder::Building, -@current_angle, 0.5, 0.5, @current_scale, @current_scale, color)
      end
    end

    # def draw viewable_pixel_offset_x, viewable_pixel_offset_y
    #   #do nothing
    # end

    def alt_alt_draw opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y, general_height
      # do nothing yet
    end

    # def alt_draw vert0, vert1, vert2, vert3, general_height, viewMatrix, projectionMatrix, viewport
    def alt_draw opengl_coord_x, opengl_coord_y, opengl_increment_x, opengl_increment_y, general_height
      # # opengl_increment_x_half = opengl_increment_x / 2.0
      # # opengl_increment_y_half = opengl_increment_y / 2.0
      # # @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png", :tileable => true)
      # # @info = @image2.gl_tex_info

      # # o_width =  vert0[0] - (vert0[0] - vert2[0])
      # # o_height = vert2[1] + (vert2[1] - vert3[1])
      # # o_width_quarter  =  o_width  / 4.0
      # # o_height_quarter =  o_height / 4.0



      # info = @info
      # colors = @colors
      # glBindTexture(GL_TEXTURE_2D, info.tex_name)
      # glBegin(GL_TRIANGLE_STRIP)
      #   # bottom left 
      #   glTexCoord2d(info.left, info.bottom)
      #   glColor4d(colors[0], colors[1], colors[2], colors[3])
      #   glVertex3d(opengl_coord_x, vopengl_coord_y, general_height)

      #   # Top Left
      #   glTexCoord2d(info.left, info.top)
      #   glColor4d(colors[0], colors[1], colors[2], colors[3])
      #   glVertex3d(opengl_coord_x, opengl_coord_y, general_height

      #   # bottom Right
      #   glTexCoord2d(info.right, info.bottom)
      #   glColor4d(colors[0], colors[1], colors[2], colors[3])
      #   glVertex3d(opengl_coord_x, opengl_coord_y, general_height)

      #   # top right
      #   glTexCoord2d(info.right, info.top)
      #   glColor4d(colors[0], colors[1], colors[2], colors[3])
      #   glVertex3d(opengl_coord_x, opengl_coord_y, general_height)
      # glEnd

      # # # X and Y are updated 


      # # # @x_offset, @y_offset
      # # # @tile_pixel_width
      # # # @tile_pixel_height
      # # # o_width  = vert0[0] - (vert0[0] - vert2[0])
      # # # o_height = vert2[1] + (vert2[1] - vert3[1])


      # # # # PRE gps_map_center_y: 122
      # # # # POST gps_map_center_y: 121
      # # # # PIXEL: [13556, 13556]
      # # # # GPS: [120, 120]
      # # # # TILE PIXEL: [112.5, 112.5]
      # # # # Landwreck O OFFSETS: [0.4376389805415412, -0.24449473427356722]

      # # # o_x_offset = (@x_offset * o_width)  / (@tile_pixel_width )
      # # # o_y_offset = (@y_offset * o_height) / (@tile_pixel_height)
      # # # puts "Landwreck O OFFSETS: #{[o_x_offset, o_y_offset]}"

      # # update_from_3D(vert0, vert1, vert2, vert3, general_height, viewMatrix, projectionMatrix, viewport)

      # # @item.draw(0, 0, @current_scale)

      # # # @image.draw((@x - get_width / 2) + @x_offset, (@y - get_height / 2) + @y_offset, 1, @height_scale, @height_scale)

      # # # result = convert3DTo2D(o_x, o_y, o_z, viewMatrix, projectionMatrix, viewport)
      # # # puts "RESULT"
      # # # puts result
      # # raise "STOP"
    end
  end
end