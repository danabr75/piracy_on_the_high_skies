require_relative 'menu_item.rb'
class Menu
    def initialize (window)
        @window = window
        @items = Array.new
    end

    def add_item (object, x, y, z, callback, hover_image = nil, options = {})
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
end