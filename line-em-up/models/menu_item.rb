class MenuItem
    HOVER_OFFSET = 3
    def initialize (window, image, x, y, z, callback, hover_image = nil)
        @window = window
        @main_image = image
        @hover_image = hover_image
        @original_x = @x = x
        @original_y = @y = y
        @z = z
        @callback = callback
        @active_image = @main_image
    end

    def draw
        @active_image.draw(@x, @y, @z)
    end

    def update
        if is_mouse_hovering then
            if !@hover_image.nil? then
                @active_image = @hover_image
            end

            @x = @original_x + HOVER_OFFSET
            @y = @original_y + HOVER_OFFSET
        else 
            @active_image = @main_image
            @x = @original_x
            @y = @original_y
        end
    end

    def is_mouse_hovering
        mx = @window.mouse_x
        my = @window.mouse_y

        (mx >= @x and my >= @y) and (mx <= @x + @active_image.width) and (my <= @y + @active_image.height)
    end

    def clicked
        if is_mouse_hovering then
            @callback.call
        end
    end
end