require_relative 'menu_item.rb'
class Menu
  attr_accessor :current_height, :x, :y
  attr_reader :active, :window, :width, :height, :button_size, :button_size_half, :button_size_quarter, :cell_padding
  def initialize(window, x, y, z = ZOrder::UI, scale = 1, options = {})
    # LUIT.config({window: self, z: 25})
    LUIT.config({window: window})
    @scale = scale
    @window = window
    # @local_window = local_window
    @x = x
    @y = y
    @z = z
    @cell_padding = 10 * @scale
    # @offset_y = 0
    # @local_window = self
    @items = Array.new
    if options[:add_top_padding] == true
      @current_height = @cell_padding + @cell_padding + y
    elsif options[:add_top_padding].class == Integer
      @current_height = y + options[:add_top_padding] * scale
    else
      @current_height = y
    end
    # @current_width  = x
    # Add to it while the buttons are being added, in add_item
    @button_id_mapping = {}
    @active = false
    @button_size = ((options[:button_size] || 40) * scale).to_i
    @button_size_half = @button_size / 2.0
    @button_size_quarter = @button_size_half / 2.0

    # Default is vertical
    @is_horizontal = options[:is_horizontal] || false
    @width   = 0
    @height  = 0
  end

  def enable
    @active = true
  end
  def disable
    @active = false
  end


  # For external use
  # def increase_y_offset amount
  #     @current_height = @current_height + amount
  # end

  def add_item(key, text, x, y, callback, hover_image = nil, options = {})
      @button_id_mapping[key] = callback

      button = LUIT::Button.new(self, key, self.x, @current_height, @z, text, @button_size, @button_size)

      if @is_horizontal
        if options[:is_button]
          # @current_height = @current_height + button.h + @cell_padding
          @width += button.w + @cell_padding
          @height += button.h
        else
          raise "unsupported currently"
          # @current_height = @current_height + button.height + @cell_padding
          @width += button.width + @cell_padding
          @height += button.h
        end
      else
        if options[:is_button]
          @current_height = @current_height + button.h + @cell_padding
          @height += button.h + @cell_padding
        else
          raise "unsupported currently"
          @current_height = @current_height + button.height + @cell_padding
          @height += button.h + @cell_padding
        end
      end
      @items << MenuItem.new(button, x, y, @z, callback, hover_image, options)
  end

  def draw
    # puts "ITEM WIDHTS: #{@item_widths}"
    if @active
      # puts "DAWRING MENUs"
      if @is_horizontal
        x_offset = -(@width / 2.0)
      else
        x_offset = 0
      end
      @items.each do |i|
        i.draw(x_offset)
        x_offset += i.get_button_width + @cell_padding if @is_horizontal
        # puts "ADDING TO OFFSET: #{i.get_button_width}"
        # x_offset += i.get_button_width if @is_horizontal
      end
    end
  end

# ITEM WIDHTS: 127.5
# ADDING TO OFFSET: 40
# ADDING TO OFFSET: 45.0
# ADDING TO OFFSET: 42.5

  def update
    if @active
      # puts "UPDATING MENUs - #{@items.count}"
      if @is_horizontal
        x_offset = -(@width / 2.0)
      else
        x_offset = 0
      end
      @items.each do |i|
        i.update(x_offset)
        x_offset += i.get_button_width + @cell_padding if @is_horizontal
        # x_offset += i.get_button_width if @is_horizontal
      end
    end
  end

  def clicked
    if @active
      @items.each do |i|
          i.clicked
      end
    end
  end

  def onClick element_id
   # puts "MENU ONCLICK"
    if @active
      button_clicked_exists = @button_id_mapping.key?(element_id)
      if button_clicked_exists
        # @button_id_mapping[element_id].call(@local_window, element_id)
        # raise "NEED T OBRING LOCAL WINDOW BACK #{self.class} is not menu - what was it? #{self.class.name}" if self.class.name != Menu
        @button_id_mapping[element_id].call(self.window, self, element_id)
      else
       # puts "Clicked button that is not mapped: #{element_id}"
      end
    end
  end
end