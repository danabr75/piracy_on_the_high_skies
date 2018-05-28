class MenuItem
    HOVER_OFFSET = 3
    def initialize (window, image, x, y, z, callback, hover_image = nil, options = {})
        @window = window
        @main_image = image
        @hover_image = hover_image
        @original_x = @x = x
        @original_y = @y = y
        @z = z
        @callback = callback
        # Can also be a font object!
        @active_image = @main_image
        @text = options[:text]
    end

    def draw
      if @text
        @active_image.draw(@text, @x, @y, 1, 1.0, 1.0, 0xff_ffff00)
      else
        @active_image.draw(@x, @y, @z)
      end
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

      if @text
        local_width  = @main_image.text_width(@text)
        local_height = @main_image.height
      else
        local_width = @active_image.width
        local_height = @active_image.height
      end

      (mx >= @x and my >= @y) and (mx <= @x + local_width) and (my <= @y + local_height)
    end

    def clicked
        if is_mouse_hovering && @callback
            @callback.call
        end
    end
end