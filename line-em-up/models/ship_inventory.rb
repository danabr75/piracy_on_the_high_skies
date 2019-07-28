require_relative "../lib/global_constants.rb"
require_relative "../lib/global_variables.rb"

class ShipInventory
  include GlobalVariables
  include GlobalConstants

  IMAGE_SCALER = 10.0

  # attr_accessor :cursor_object

  FORBIDDEN_ITEM_CLASSES = [:ship]

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

  attr_reader :credits

  def initialize window, options = {}#, parent_container
    @buy_rate_from_store  = options[:buy_rate]  || 1.0
    @sell_rate_from_store = options[:sell_rate] || 1.0
    init_global_vars
    @window = window
    # @local_window = local_window
    # @parent_container = parent_container
    # @hardpoint_image_z = ZOrder::Hardpoint # Used to be 50
    @hardpoint_image_z = 50
    @config_file_path = CONFIG_FILE
    @save_file_path   = CURRENT_SAVE_FILE
    @inventory_matrix_max_width = 4
    @inventory_matrix_max_height = 7
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
    @credits = JSON.parse(ConfigSetting.get_setting(@save_file_path, 'Credits', '0'))
    raise "INVALID CREDIT TYPE: #{@credits.class}" if !@credits.kind_of?(Integer)
    init_matrix
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
    current_x = @next_x + @cell_width_padding
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        key = "matrix_#{x}_#{y}"
        click_area = LUIT::ClickArea.new(@window, @window, key, current_x, current_y, ZOrder::HardPointClickableLocation, @cell_width, @cell_height)
        klass_name = ConfigSetting.get_mapped_setting(@save_file_path, ['Inventory', x.to_s, y.to_s])
        item = nil
        if klass_name
          klass = eval(klass_name)
          image = klass.get_hardpoint_image
          item = {
            key: key, klass: klass, image: image, value: klass.value, buy_rate: @buy_rate_from_store, sell_rate: @sell_rate_from_store,
            hardpoint_item_slot_type: klass::SLOT_TYPE
          }
        end
        # @filler_items << {follow_cursor: false, klass: klass, image: image}
        @inventory_matrix[x][y] = {x: current_x, y: current_y, click_area: click_area, key: key, item: item}
        current_x = current_x + @cell_width + @cell_width_padding
        @button_id_mapping[key] = lambda { |window, menu, id| menu.click_inventory(id) }
      end
      current_x = @next_x + @cell_width_padding
      current_y = current_y + @cell_height + @cell_height_padding
    end
  end

  def add_credits new_credits
   # puts "ADDING CREDITS #{@credits.class} w new credits #{new_credits.class} on ShipInventory"
    @credits += new_credits
    ConfigSetting.set_setting(@save_file_path, 'Credits', @credits)
  end
  def subtract_credits new_credits
    @credits -= new_credits
    ConfigSetting.set_setting(@save_file_path, 'Credits', @credits)
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

  def update mouse_x, mouse_y
    # puts "SHIP INVENTORY HAS CORSURE OBJECT" if @window.cursor_object
    hover_object = nil
    @mouse_x, @mouse_y = [mouse_x, mouse_y]
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        item = @inventory_matrix[x][y][:item]
        is_hover = @inventory_matrix[x][y][:click_area].update(0,0)
        hover_object = {item: item, holding_type: :inventory} if is_hover
      end
    end
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
    text = "Inventory $#{@credits}"
    @font.draw(text, (@inventory_width / 2.0) - (@font.text_width(text) / 2.0), (@screen_pixel_height / 2) - (@inventory_height / 2) - @font_height, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    Gosu::draw_rect(@cell_width_padding / 2.0, (@screen_pixel_height / 2) - (@inventory_height / 2) - @cell_height_padding - @font_height, @inventory_width + @cell_width_padding, @inventory_height + @cell_height_padding + @font_height, Gosu::Color.argb(0xff_9797fc), ZOrder::MenuBackground)

    # if @window.cursor_object
    #   @window.cursor_object[:image].draw(@mouse_x, @mouse_y, @hardpoint_image_z, @height_scale, @height_scale)
    # end
  end

  def click_inventory id
   # puts "LUANCHER: #{id}"
   # puts "click_inventory: "
    x, y = id.scan(/matrix_(\d+)_(\d+)/).first
    x, y = [x.to_i, y.to_i]
   # puts "LCICKED: #{x} and #{y}"
    matrix_element = @inventory_matrix[x][y]
    element = matrix_element ? matrix_element[:item] : nil

    # Resave new key when dropping element in.

    if @window.cursor_object && element
     # puts "@window.cursor_object[:key]: #{@window.cursor_object[:key]}"
     # puts "ID: #{id}"
     # puts "== #{@window.cursor_object[:key] == id}"
      if @window.cursor_object[:key] == id
        # Same Object, Unstick it, put it back
        # element[:follow_cursor] = false
        # @inventory_matrix[x][y][:item][:follow_cursor] =
        matrix_element[:item] = @window.cursor_object
        ConfigSetting.set_mapped_setting(@save_file_path, ['Inventory', x.to_s, y.to_s], matrix_element[:item][:klass])
        matrix_element[:item][:key] = id
        @window.cursor_object = nil
      else
        # Else, drop object, pick up new object
        # @window.cursor_object[:follow_cursor] = false
        # element[:follow_cursor] = true
        temp_element = element
        matrix_element[:item] = @window.cursor_object
        matrix_element[:item][:key] = id
        ConfigSetting.set_mapped_setting(@save_file_path, ['Inventory', x.to_s, y.to_s], matrix_element[:item][:klass])
        @window.cursor_object = temp_element
        @window.cursor_object[:key] = nil # Original home lost, no last home of key present
        # @window.cursor_object[:follow_cursor] = true
        # WRRROOOONNGGG!
        # element = 
      end
    elsif element
      # Pick up element, no current object
      # element[:follow_cursor] = true
      @window.cursor_object = element
      matrix_element[:item] = nil
      ConfigSetting.set_mapped_setting(@save_file_path, ['Inventory', x.to_s, y.to_s], nil)
    elsif @window.cursor_object
      # Placeing something new in inventory
      matrix_element[:item] = @window.cursor_object
      ConfigSetting.set_mapped_setting(@save_file_path, ['Inventory', x.to_s, y.to_s], matrix_element[:item][:klass])
      matrix_element[:item][:key] = id
      # matrix_element[:item][:follow_cursor] = false
      @window.cursor_object = nil
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

  # Not used here
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