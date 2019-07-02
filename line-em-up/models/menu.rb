require_relative 'menu_item.rb'
class Menu
  attr_accessor :current_height, :x, :y
  attr_reader :active, :window
  def initialize(window, x, y, z = ZOrder::UI, scale = 1)
    # LUIT.config({window: self, z: 25})
    LUIT.config({window: window || self})
    @scale = scale
    @window = window
    @x = x
    @y = y
    @z = z
    @cell_padding = 10 * @scale
    # @offset_y = 0
    # @local_window = self
    @items = Array.new
    @current_height = 50
    # Add to it while the buttons are being added, in add_item
    @button_id_mapping = {}
    @active = false
    @button_size = (40 * scale).to_i
  end

  def enable
    @active = true
  end
  def disable
    @active = false
  end


  # For external use
  def increase_y_offset amount
      @current_height = @current_height + amount
  end

  def add_item(key, text, x, y, callback, hover_image = nil, options = {})
      @button_id_mapping[key] = callback

      button = LUIT::Button.new(self, key, self.x, self.y + self.current_height, @z, text, @button_size, @button_size)

      if options[:is_button]
        @current_height = @current_height + button.h + @cell_padding
      else
        @current_height = @current_height + button.height + @cell_padding
      end
      @items << MenuItem.new(@window, button, x, y, @z, callback, hover_image, options)
  end

  def draw
    if @active
      # puts "DAWRING MENUs"
      @items.each do |i|
        i.draw
      end
    end
  end

  def update
    if @active
      # puts "UPDATING MENUs - #{@items.count}"
      @items.each do |i|
          i.update
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