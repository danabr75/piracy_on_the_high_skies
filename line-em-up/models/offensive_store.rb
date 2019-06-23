require_relative 'building.rb'

# Offensive store for now, don't have any other hardport types atm.
class OffensiveStore < Building


  attr_reader :credits

  def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
    @window = window
    super(current_map_tile_x, current_map_tile_y, options)
    offensive_types = Launcher.descendants
    offensive_types_with_rarities = {}
    Launcher.descendants.each do |launcher_klass|
      offensive_types_with_rarities[launcher_klass.to_s] = launcher_klass::RARITY_MAX - launcher_klass::STORE_RARITY
    end
    puts "offensive_types_with_rarities: "
    puts offensive_types_with_rarities.inspect
    @store_item_count = rand(5) + 3
    (0..@store_item_count).each do |i|
      @drops << random_weighted(offensive_types_with_rarities)
    end
    puts "OFFENSIVE DROP ON INIT"
    puts @drops.inspect
    @click_area = LUIT::ClickArea.new(self, :object_inventory, 0, 0, ZOrder::HardPointClickableLocation, @image_width, @image_height, nil, nil, {hide_rect_draw: true})
    @button_id_mapping = {}
    # Need to add sell window to ship_loadout_menu\ship_loadout_setting
    # Also need to cost credits, add credits to player.
    @button_id_mapping[:object_inventory] = lambda { |window, menu, id|
      if !window.ship_loadout_menu.active
        window.block_all_controls = true; window.ship_loadout_menu.loading_object_inventory(menu, menu.drops, menu.credits); window.ship_loadout_menu.enable
      end
    }
    @is_hovering = false
    @is_close_enough_to_open = false
    @max_lootable_pixel_distance = 2 * @average_tile_size
    @image = self.class::get_image
    @credits = rand(500) + 500
  end

  def set_drops drops
    puts "OFFENSIVE STORE SETTING DROPS"
    puts "DROPS WAS"
    puts @drops.inspect
    puts "DROPS NOW"
    puts drops
    @drops = drops
    puts 'END'
  end
  def set_credits credits
    @credits = credits
  end
  # Not needed on OffensiveStore
  def set_window window
    @window = window
  end

  def onClick element_id
    if @is_close_enough_to_open
      button_clicked_exists = @button_id_mapping.key?(element_id)
      if button_clicked_exists
        puts "BUTTON EXISTS: #{element_id}"
        @button_id_mapping[element_id].call(@window, self, element_id)
      else
        puts "Clicked button that is not mapped: #{element_id}"
      end
      return button_clicked_exists
    else
      return false
    end
  end

  def update mouse_x, mouse_y, player
    @is_hovering = @click_area.update(@x - @image_width_half, @y - @image_height_half) #if @drops.any?
    distance = Gosu.distance(player.x, player.y, @x, @y)
    if @is_hovering
      if distance < @max_lootable_pixel_distance
        @is_close_enough_to_open = true
      else
        @is_close_enough_to_open = false
      end
    else
      @is_close_enough_to_open = false
    end
    return super(mouse_x, mouse_y, player)
  end

  def draw viewable_pixel_offset_x,  viewable_pixel_offset_y
    # @click_area.draw(@x - @image_width_half, @y - @image_height_half) #if @drops.any?
    # color = Gosu::Color.argb(0xff_ffffff)
    # if @drops.any?
    #   if @is_hovering && @is_close_enough_to_open
    #     color = Gosu::Color.argb(0xff_e1ffcd)
    #   elsif @is_hovering
    #     color = Gosu::Color.argb(0xff_ff9479)
    #   end
    # end
    # For testing!!!!!!!!!!!!
    # @image.draw(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, ZOrder::Building, @width_scale, @height_scale)
    # @image.draw_rot(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, ZOrder::Building, 0, 0.5, 0.5, @average_scale / 2.0, @average_scale / 2.0)
    # Super doesn't do anything right now, keeping for consistency
    # super(viewable_pixel_offset_x,  viewable_pixel_offset_y)
  end

  def self.get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/offensive_store.png", :tileable => true)
  end

  def self.tile_draw_gl v1, v2, v3, v4
    @image2 = Gosu::Image.new("#{MEDIA_DIRECTORY}/offensive_store.png", :tileable => true)
    @info = @image2.gl_tex_info

    info = @info
    colors = [1, 1, 1, 1]
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

  def random_weighted(weighted)
    max    = sum_of_weights(weighted)
    target = rand(1..max)
    weighted.each do |item, weight|
      return item if target <= weight
      target -= weight
    end
  end

  def sum_of_weights(weighted)
    weighted.inject(0) { |sum, (item, weight)| sum + weight }
  end

end

