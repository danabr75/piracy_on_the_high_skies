class MenuItem
    HOVER_OFFSET = 3
    def initialize (window, image, x, y, z, callback, hover_image = nil, options = {})
      puts "NEW OPTIONS : #{options}"
        @window = window
        @main_image = image
        @hover_image = hover_image
        @original_x = @x = x
        @original_y = @y = y
        @z = z
        @callback = callback
        # Can also be a font object!
        @active_image = @main_image
        # @text = options[:text]
        # @value = options[:value]
        # @settings_name = options[:settings_name]
        # @config_file = options[:config_file]
        # @type = options[:type]
    end

    def draw
      if @text
        @active_image.draw(@text, @x, @y, 1, 1.0, 1.0, 0xff_ffff00)
      else
        @active_image.draw(@x, @y, @z)
      end
    end

    def update
        # @text = @get_value_callback.call(@config_file, @settings_name) if @get_value_callback && @config_file && @settings_name
        if is_mouse_hovering
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
      if @type && @type == 'font'
        local_width  = @main_image.text_width(@text)
        local_height = @main_image.height
      else
        local_width = @active_image.width
        local_height = @active_image.height
      end

      (mx >= @x and my >= @y) and (mx <= @x + local_width) and (my <= @y + local_height)
    end

    def clicked
      # return_value = nil
      # if is_mouse_hovering && @callback && @value && @config_file && @settings_name
      #   return_value = @callback.call(@config_file, @settings_name, @value)
      # end
      if is_mouse_hovering && @callback
        @callback.call
      end
      # if return_value
      #   @text = return_value
      # end
      # if @save_callback && @settings_name && @config_file
      #   puts "USING SAVE CALLBACK: #{@config_file} and #{@settings_name} and #{return_value}"
      #   @save_callback.call(@config_file, @settings_name.to_s, return_value)
      # end
    end
end