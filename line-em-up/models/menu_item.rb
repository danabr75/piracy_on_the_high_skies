class MenuItem
    HOVER_OFFSET = 3
    def initialize (window, button, x, y, z, callback, hover_image = nil, options = {})
        @window = window
        @button = button
        @hover_image = hover_image
        @original_x = @x = x
        @original_y = @y = y
        @z = z
        @callback = callback
        # Can also be a font object!
        # @active_image = @main_image
        @is_button = options[:is_button]
        # puts "MENU ITEM HERE: #{@is_button}"
        @y_offset = options[:y_offset] || 0
        # @text = options[:text]
        # @value = options[:value]
        # @settings_name = options[:settings_name]
        # @config_file = options[:config_file]
        # @type = options[:type]
    end

    def draw
      # if @text && !@is_button
      #   @active_image.draw(@text, @x, @y, 1, 1.0, 1.0, 0xff_ffff00)
      # elsif !@is_button
      #   @active_image.draw(@x, @y, @z)
      # elsif @is_button
      @button.draw(-(@button.w / 2), -(@button.h / 2))
        # @main_image.draw(0, 0)
      # end
    end

    def update
        # @text = @get_value_callback.call(@config_file, @settings_name) if @get_value_callback && @config_file && @settings_name
        # puts "MENU ITEN: #{!@is_button}"
        # if !@is_button
        #   if is_mouse_hovering
        #       if !@hover_image.nil? then
        #           @active_image = @hover_image
        #       end

        #       @x = @original_x + HOVER_OFFSET
        #      # puts "MENU ITEM NEW X: #{@x}   from : #{@original_x} + #{HOVER_OFFSET}"
        #       @y = @original_y + HOVER_OFFSET
        #   else 
        #       @active_image = @main_image
        #       @x = @original_x
        #       @y = @original_y
        #   end
        # else
          # @main_image.update(-(@main_image.w / 2), -(@y_offset - @main_image.h / 2))
        @button.update(-(@button.w / 2), -(@button.h / 2))
        # end
    end

    # def is_mouse_hovering
    #   mx = @window.mouse_x
    #   my = @window.mouse_y
    #   if @type && @type == 'font'
    #     local_width  = @main_image.text_width(@text)
    #     local_height = @main_image.height
    #   else
    #     local_width = @active_image.width
    #     local_height = @active_image.height
    #   end

    #   (mx >= @x and my >= @y) and (mx <= @x + local_width) and (my <= @y + local_height)
    # end

    # def clicked
    #   raise "NOT USING THIS ANYMORE"
    #   # return_value = nil
    #   # if is_mouse_hovering && @callback && @value && @config_file && @settings_name
    #   #   return_value = @callback.call(@config_file, @settings_name, @value)
    #   # end
    #   if !@is_button
    #     if is_mouse_hovering && @callback
    #       @callback.call
    #     end
    #   end
    #   # if return_value
    #   #   @text = return_value
    #   # end
    #   # if @save_callback && @settings_name && @config_file
    #   #  # puts "USING SAVE CALLBACK: #{@config_file} and #{@settings_name} and #{return_value}"
    #   #   @save_callback.call(@config_file, @settings_name.to_s, return_value)
    #   # end
    # end
end