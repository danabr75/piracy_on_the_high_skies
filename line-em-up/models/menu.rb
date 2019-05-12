require_relative 'menu_item.rb'
class Menu
    attr_accessor :local_window, :current_height, :x, :y
    def initialize(window, x, y, z = ZOrder::UI, scale = 1)
        @scale = scale
        @window = window
        @x = x
        @y = y
        @z = z
        @cell_padding = 10 * @scale
        # @offset_y = 0
        @local_window = self
        LUIT.config({window: @window, z: z})
        @items = Array.new
        @current_height = 0
        # Add to it while the buttons are being added, in add_item
        @button_id_mapping = {}
    end

    # For external use
    def increase_y_offset amount
        @current_height = @current_height + amount
    end

    def add_item(object, x, y, callback, hover_image = nil, options = {})
        if options[:key]
          @button_id_mapping[options[:key]] = callback
        end
        if options[:is_button]

        end
        item = MenuItem.new(@window, object, x, y, @z, callback, hover_image, options)
        if options[:is_button]
          @current_height = @current_height + object.h + @cell_padding
        else
          @current_height = @current_height + object.height + @cell_padding
        end
        @items << item
        self
    end

    def draw
        @items.each do |i|
          i.draw
        end
    end

    def update
        @items.each do |i|
            i.update
        end
    end

    def clicked
        @items.each do |i|
            i.clicked
        end
    end

    def onClick element_id
      # puts "LOADOUT WINDOW ONCLICK"
      button_clicked_exists = @button_id_mapping.key?(element_id)
      if button_clicked_exists
        @button_id_mapping[element_id].call(@local_window, element_id)
      else
        puts "Clicked button that is not mapped: #{element_id}"
      end
    end


end