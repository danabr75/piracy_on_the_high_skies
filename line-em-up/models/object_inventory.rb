require_relative "../lib/global_constants.rb"
require_relative "../lib/global_variables.rb"

# Needs a CLOSE BUTTON AT THE BOTTOM OF THE INVENTORY PAGE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# A grab all button would also be nice.
# Wjy not show hard points as well.. include this in the ship_loadout_setting!!!!!!!!!!!!!!!!
# WHEN CLOSED, need to empty the inventory back to the landwreck!!!!!!!!!!!
# - back to @attached_to 

class ObjectInventory
  include GlobalVariables
  include GlobalConstants
  IMAGE_SCALER = 10.0


  def init_global_vars
    @tile_pixel_width    = GlobalVariables.tile_pixel_width
    @tile_pixel_height   = GlobalVariables.tile_pixel_height
    @average_tile_size   = GlobalVariables.average_tile_size
    @map_pixel_width     = GlobalVariables.map_pixel_width
    @map_pixel_height    = GlobalVariables.map_pixel_height
    @map_tile_width      = GlobalVariables.map_tile_width
    @map_tile_height     = GlobalVariables.map_tile_height
    @width_scale         = GlobalVariables.width_scale
    @height_scale        = GlobalVariables.height_scale
    @screen_pixel_width  = GlobalVariables.screen_pixel_width
    @screen_pixel_height = GlobalVariables.screen_pixel_height
    # @debug               = GlobalVariables.debug
    # @damage_increase     = GlobalVariables.damage_increase
    @average_scale       = GlobalVariables.average_scale
    # @effects_volume      = GlobalVariables.effects_volume
    # @music_volume        = GlobalVariables.music_volume
  end


  attr_reader :credits, :holding_type, :buy_rate, :sell_rate
  attr_accessor :attached_to

  def initialize window, name, item_list, credits, attached_to, holding_type, options = {}
    raise "INVALID PARMS: #{[window, name, item_list, attached_to, holding_type]}" if [window, name, item_list, attached_to, holding_type].include?(nil)
   # puts "NEW OBJECT INVENOTRY HERE: "
   # puts [window, name, item_list, credits, attached_to, holding_type, options]
    @holding_type = holding_type

    @attached_to = attached_to
    @name = name
    @credits = credits
   # puts "WHAT WAS NAME? #{@name}"
    init_global_vars
    @window = window
    # @local_window = local_window
    @item_list = item_list
    # @parent_container = parent_container
    # @hardpoint_image_z = ZOrder::Hardpoint # Used to be 50
    @hardpoint_image_z = 50
    @config_file_path = CONFIG_FILE
    @inventory_matrix_max_width = 4
    @inventory_matrix_max_height = 4
    @inventory_matrix = []
    @inventory_height = nil
    @inventory_width  = nil
    @hover_object = nil
    @cell_width  = 25 * @height_scale
    @cell_height = 25 * @height_scale
    @cell_width_padding = 5 * @height_scale
    @cell_height_padding = 5 * @height_scale
    @next_x = 5 * @height_scale
    @button_id_mapping = {}
    @font_height  = (12 * @height_scale).to_i
    @font_padding = (4 * @height_scale).to_i
    @font = Gosu::Font.new(@font_height)
    # @window.cursor_object = nil
    @mouse_x, @mouse_y = [0,0]
    if @holding_type == :store
      @buy_rate  = 0.1
      @sell_rate = 1.2
    elsif @holding_type == :shipyard
      @buy_rate  = 0.1
      @sell_rate = 1.0
    else
      @buy_rate  = 1.0
      @sell_rate = 1.0
    end
    init_matrix

    @allow_credit_collection = options[:allow_credit_collection]
    if @allow_credit_collection
      collect_credits_button_x = (@screen_pixel_width + (@cell_width_padding / 2.0) - @inventory_width - (@cell_width / 2.0)) + (@inventory_width + @cell_width_padding) / 2.0
      collect_credits_button_y = ((@screen_pixel_height / 2) - (@inventory_height / 2) - @cell_height_padding - @font_height) + (@inventory_height + @cell_height_padding + @font_height)
      @collect_credits_button  = LUIT::Button.new(@window, @window, :collect_credits, collect_credits_button_x, collect_credits_button_y, ZOrder::UI, "Collect Credits", (12 * @height_scale).to_i , (12 * @height_scale).to_i)
      @button_id_mapping[:collect_credits] = lambda { |window, menu, id| window.ship_loadout_menu.add_to_ship_inventory_credits(menu.credits); menu.subtract_credits(menu.credits) }
    end

  end

  def add_credits new_credits
    @credits += new_credits
    attached_to.add_credits(new_credits)
  end
  def subtract_credits new_credits
    @credits -= new_credits
    attached_to.subtract_credits(new_credits)
  end

  def unload_inventory
   # puts "ObjectInventory#unload_inventory"
   # puts get_matrix_items
    @attached_to.set_drops(get_matrix_items)
    # any changes to credits have already been made.
    # @attached_to.set_credits(@credits)
    @attached_to = nil
  end

  def get_matrix_items
   # puts "HERE: get_matrix_items"
    items = []
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        items << @inventory_matrix[x][y][:item][:klass].to_s if !@inventory_matrix[x][y].nil? && !@inventory_matrix[x][y][:item].nil?
      end
    end
    return items
  end

  def init_matrix
    (0..@inventory_matrix_max_width - 1).each do |i|
      @inventory_matrix[i] = Array.new(@inventory_matrix_max_height)
    end
    # puts "@inventory_matrix_max_height: #{@inventory_matrix_max_height}"
    @inventory_height = (@inventory_matrix_max_height * @cell_height) + (@inventory_matrix_max_height * @cell_height_padding)
    @inventory_width  = (@inventory_matrix_max_width  * @cell_width)  + (@inventory_matrix_max_width  * @cell_width_padding)
    # raise "GOT THIS for height: #{max_y_height} - Y was: #{@y}"
    current_y = (@screen_pixel_height / 2) - (@inventory_height / 2)
    current_x = @screen_pixel_width - (@next_x + @cell_width_padding + @cell_width)
   # puts "current_x was: #{current_x}"
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        key = "oi_matrix_#{x}_#{y}"
        click_area = LUIT::ClickArea.new(@window, @window, key, current_x, current_y, ZOrder::HardPointClickableLocation, @cell_width, @cell_height)
        klass_name = @item_list.shift if @item_list.count > 0
        item = nil
        if klass_name
          klass = eval(klass_name)
          image = klass.get_hardpoint_image
          item = {
            key: key, klass: klass, image: image, value: klass.value, from_store: true, buy_rate: @buy_rate, sell_rate: @sell_rate,
            # hardpoint_slot_type: hp.slot_type,
            hardpoint_item_slot_type: klass::SLOT_TYPE
          }
        end
        # @filler_items << {follow_cursor: false, klass: klass, image: image}
        @inventory_matrix[x][y] = {x: current_x, y: current_y, click_area: click_area, key: key, item: item}
        current_x = current_x - (@cell_width + @cell_width_padding)
        @button_id_mapping[key] = lambda { |window, menu, id| menu.click_inventory(window, menu, id) }
      end
      current_x = @screen_pixel_width - (@next_x + @cell_width_padding + @cell_width)
      current_y = current_y + @cell_height + @cell_height_padding
    end
  end

  def onClick element_id
    # puts "ONCLICK mappuing"
    # puts @button_id_mapping
    button_clicked_exists = @button_id_mapping.key?(element_id)
    if button_clicked_exists
     # puts "BUTTON EXISTS: #{element_id}"
      @button_id_mapping[element_id].call(@window, self, element_id)
    else
     # puts "Clicked button that is not mapped: #{element_id}"
    end
    return button_clicked_exists
  end

  def update mouse_x, mouse_y, other_inventory_credit_limit = nil
    # puts "SHIP INVENTORY HAS CORSURE OBJECT" if @window.cursor_object
    hover_object = nil
    @mouse_x, @mouse_y = [mouse_x, mouse_y]
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        item = @inventory_matrix[x][y][:item]
        is_hover = @inventory_matrix[x][y][:click_area].update(0,0)
        # puts "OBJECT INVENTORY IF HOVER" if is_hover
        hover_object = {item: item, holding_type: @holding_type} if is_hover
      end
    end
    @collect_credits_button.update(0, 0) if @allow_credit_collection
    return hover_object
  end

  # For debugging only
  def print_out_matrix
    (0..@inventory_matrix_max_height - 1).each do |y|
      row_value = []
      (0..@inventory_matrix_max_width - 1).each do |x|
        value = @inventory_matrix[x][y]
        if value.nil?
          value = 'O'
        else
          value = 'X'
        end
        row_value << value
      end
     # puts row_value.join(', ')
    end
  end

  def draw
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        element = @inventory_matrix[x][y]
        element[:click_area].draw(0,0)
        # puts "element[:item]: #{element[:item]}"
        if !element[:item].nil? && element[:item][:follow_cursor] != true
          image = element[:item][:image]
          image.draw(element[:x] - (image.width / 2) / IMAGE_SCALER + @cell_width / 2, element[:y] - (image.height / 2) / IMAGE_SCALER + @cell_height / 2, @hardpoint_image_z, @height_scale / IMAGE_SCALER, @height_scale / IMAGE_SCALER)
        end
      end
    end
    text = "#{@name} $#{@credits}"
    @font.draw(text, @screen_pixel_width - (@inventory_width / 2.0) - (@font.text_width(text) / 2.0), (@screen_pixel_height / 2) - (@inventory_height / 2) - @font_height, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    Gosu::draw_rect(
      # X
      @screen_pixel_width + (@cell_width_padding / 2.0) - @inventory_width - (@cell_width / 2.0),
      # Y
      (@screen_pixel_height / 2) - (@inventory_height / 2) - @cell_height_padding - @font_height,
      # W
      @inventory_width + @cell_width_padding,
      # H
      @allow_credit_collection ? @inventory_height + @cell_height_padding + @font_height + @collect_credits_button.h : @inventory_height + @cell_height_padding + @font_height,
      # Color and Depth
      Gosu::Color.argb(0xff_9797fc), ZOrder::MenuBackground
    )
    # @button.draw(-(@button.w / 2), -(@button.h / 2))
    @collect_credits_button.draw(0, 0) if @allow_credit_collection

    # if @window.cursor_object
    #   @window.cursor_object[:image].draw(@mouse_x, @mouse_y, @hardpoint_image_z, @height_scale, @height_scale)
    # end
  end

  def click_inventory window, menu, id

    # if @holding_type == :store
    #   window
    # end
   # puts "LUANCHER: #{id}"
   # puts "click_inventory: "
    x, y = id.scan(/oi_matrix_(\d+)_(\d+)/).first
    x, y = [x.to_i, y.to_i]
   # puts "LCICKED: #{x} and #{y}"
    matrix_element = @inventory_matrix[x][y]

    if !@window.cursor_object.nil? && (@window.cursor_object[:value].nil? || @window.cursor_object[:buy_rate].nil? || @window.cursor_object[:sell_rate].nil?)
     # puts @window.cursor_object
      raise "INVALID STATE of window.cursor_object"
    end

    element = matrix_element ? matrix_element[:item] : nil

    # Resave new key when dropping element in.
    if @window.cursor_object && element && @holding_type == :store
      # Do nothing, not a use case that is supposed to work for the store.
    elsif @window.cursor_object && element
     # puts "@window.cursor_object[:key]: #{@window.cursor_object[:key]}"
     # puts "ID: #{id}"
     # puts "== #{@window.cursor_object[:key] == id}"
      if @window.cursor_object[:key] == id
        # Same Object, Unstick it, put it back
        # element[:follow_cursor] = false
        # @inventory_matrix[x][y][:item][:follow_cursor] =
        matrix_element[:item] = @window.cursor_object
        ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', x.to_s, y.to_s], matrix_element[:item][:klass])
        matrix_element[:item][:key] = id
        @window.cursor_object = nil
      else
        # Else, drop object, pick up new object
        # @window.cursor_object[:follow_cursor] = false
        # element[:follow_cursor] = true
        temp_element = element
        matrix_element[:item] = @window.cursor_object
        matrix_element[:item][:key] = id
        ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', x.to_s, y.to_s], matrix_element[:item][:klass])
        @window.cursor_object = temp_element
        @window.cursor_object[:key] = nil # Original home lost, no last home of key present
        # @window.cursor_object[:follow_cursor] = true
        # WRRROOOONNGGG!
        # element = 
      end
    elsif element # Buying from Store, if store
      # Pick up element, no current object
      # element[:follow_cursor] = true
      if @holding_type == :store
        element_value = (element[:value] * (element[:sell_rate] || @sell_rate)).to_i
        if @window.ship_loadout_menu.get_ship_inventory_credits >= element_value
          @window.ship_loadout_menu.subtract_from_ship_inventory_credits(element_value)
          menu.add_credits(element_value)
          @window.cursor_object = element
          matrix_element[:item] = nil
          ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', x.to_s, y.to_s], nil)
        end
      else
        @window.cursor_object = element
        matrix_element[:item] = nil
        ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', x.to_s, y.to_s], nil)
      end
    elsif @window.cursor_object # Selling to store, if store,
      # Placeing something new in inventory
      if @holding_type == :store
       # puts "CURSOR OBJECT"
       # puts @window.cursor_object
        element_value = (@window.cursor_object[:value] * @window.cursor_object[:buy_rate]).to_i
        if menu.credits >= element_value # Do nothing if store doesn't have enough mon 
          @window.ship_loadout_menu.add_to_ship_inventory_credits(element_value)
          menu.subtract_credits(element_value)
          # ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', x.to_s, y.to_s], matrix_element[:item][:klass])
          # matrix_element[:item][:key] = id
          # matrix_element[:item][:follow_cursor] = false
          @window.cursor_object = nil
        end
      else
        matrix_element[:item] = @window.cursor_object
        ConfigSetting.set_mapped_setting(@config_file_path, ['Inventory', x.to_s, y.to_s], matrix_element[:item][:klass])
        matrix_element[:item][:key] = id
        # matrix_element[:item][:follow_cursor] = false
        @window.cursor_object = nil
      end
    end
    return @window.cursor_object
  end


  # def fill_matrix elements
  #   elements.each do |element|
  #     space = find_next_matrix_space
  #     if space
  #       # puts "ASSIGNING ELEMENT:"
  #       # puts element.inspect
  #       @inventory_matrix[space[:x]][space[:y]][:item] = element.merge({key: space[:key]})
  #     else
  #      # puts "NO SPACE LEFT"
  #     end
  #   end
  # end

  # def find_next_matrix_space
  #   found_space = nil
  #   (0..@inventory_matrix_max_height - 1).each do |y|
  #     (0..@inventory_matrix_max_width - 1).each do |x|
  #       if @inventory_matrix[x][y][:item].nil?
  #         key = "matrix_#{x}_#{y}"            
  #         found_space = {x: x, y: y, key: key}
  #       end
  #       break if found_space
  #     end
  #     break if found_space
  #   end
  #   return found_space
  # end


  # def detail_box_draw
  #   if @hover_object
  #     texts = []
  #     text = nil

  #     # Are these necessary here? Is there a difference? Maybe if it's a store, we can show a price.
  #     if @hover_object[:holding_type] == :inventory
  #     end
  #     if @hover_object[:holding_type] == :hardpoint
  #     end

  #     if @hover_object[:item]
  #       object = @hover_object[:item]
  #       if object[:klass].name
  #         texts << object[:klass].name
  #       end
  #       if object[:klass].description
  #         if object[:klass].description.is_a?(String)
  #           texts << object[:klass].description
  #         elsif object[:klass].description.is_a?(Array)
  #           object[:klass].description.each do |description|
  #             texts << description
  #           end
  #         end
  #       end
  #     end

  #     texts.each_with_index do |text, index|
  #       height_padding = index * @font_height
  #       # puts "HEIGHT PADDING: #{index} - #{height_padding}"
  #       @font.draw(text, (@screen_pixel_width / 4), (@screen_pixel_height) + height_padding - (@font_height * 8), ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
  #       # @font.draw(text, (@screen_pixel_width / 2) - (@font.text_width(text) / 2.0), (@screen_pixel_height) - @font_height - (@font_padding * 4), ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
  #     end
  #   end
  # end

end