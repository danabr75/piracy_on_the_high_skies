require_relative 'menu_item.rb'
class Menu
    attr_accessor :local_window
    def initialize (window)
        @window = window
        @local_window = self
        LUIT.config({window: @window, z: 25})
        @items = Array.new
        # Add to it while the buttons are being added, in add_item
        @button_id_mapping = {}
    end

    def add_item(object, x, y, z, callback, hover_image = nil, options = {})
        if options[:key]
          @button_id_mapping[options[:key]] = callback
        end
        item = MenuItem.new(@window, object, x, y, z, callback, hover_image, options)
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