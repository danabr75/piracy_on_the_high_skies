# I think this is deprecated.

# # require 'luit'
# require_relative 'setting.rb'
# require_relative '../models/basic_ship.rb'
# # require "#{MODEL_DIRECTORY}/basic_ship.rb"
# # require_relative "config_settings.rb"

# class ShipSetting < Setting
#   # MEDIA_DIRECTORY
#   NAME = "ship"

#   # attr_accessor :mouse_x, :mouse_y, :window
#   attr_accessor :window
#   attr_accessor :mouse_x, :mouse_y
#   def initialize window, fullscreen_height, max_width, max_height, current_height, config_file_path
#     raise "NO Window" if window.nil?
#     @mouse_x, @mouse_y = [0,0]
#     @window = window # ignoring outer window here? Want actions relative to this window.
#     # @local_window = local_window
#     @selection = self.class::SELECTION
#     # puts "INNITING #{config_file_path}"
#     @font = Gosu::Font.new(20)
#     # @x = width
#     @y = current_height
#     @max_width = max_width
#     @max_height = max_height
#     @prev_x = 0
#     # @next_x = max_width
#     # LUIT 205 width == 480
#     # X coord system is half that of what it should be, for the LUIT elements
#     @next_x = max_width
#     @config_file_path = config_file_path
#     @name = self.class::NAME
#     @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
#     @fullscreen_height = fullscreen_height
#     # LUIT.config(window, nil, nil, 1)
#     LUIT.config({window: @window, z: 25})
#     @next_button = LUIT::Button.new(@window, self, :next, @next_x, @y, ZOrder::UI, "Next", 0, 1)
#     # puts "CREATING NEXT BUTTON WINDOW HERE"
#     # puts @window.class.name
#     # raise "STOP HERRE"
#     # @next_button.x = @next_x - (@next_button.w / 2)

#     @prev_button = LUIT::Button.new(@window, self, :previous, @prev_x, @y, ZOrder::UI, "Previous", 0, 1)
#     @button_id_mapping = self.class.get_id_button_mapping
#     # puts "SHIP SETTING MAPPING"
#     # puts @button_id_mapping 
#   end

#   def self.get_id_button_mapping
#     {
#       next:     lambda { |window, menu, id| menu.next_clicked },
#       previous: lambda { |window, menu, id| menu.previous_clicked }
#     }
#   end

#   def get_values
#     # puts "GETTING DIFFICULTY: #{@value}"
#     if @value
#       @value
#     end
#   end

#   # def get_image
#     # klass = eval(@value)
#     # puts "KLASS HERE : #{klass.get_image_assets_path(klass::ITEM_MEDIA_DIRECTORY)}"
#     # return klass.get_right_broadside_image(klass::ITEM_MEDIA_DIRECTORY)
#   # end

#   def update mouse_x, mouse_y
#     @mouse_x, @mouse_y = [mouse_x, mouse_y]
#     # puts "SHIP SETTING - UPDATE"
#     # @mouse_x = mouse_x
#     # @mouse_y = mouse_y
#     # @next_x = max_width / 5
#     # puts "new next x: #{@next_x}"
#     # @next_button.update(@next_x - @next_button.w, @y)
#     @next_button.update(-@next_button.w, 0)
#     # puts "NEXT IS AT: #{@next_button.x}"
#     # @next_button.update(@next_x - (@next_button.w / 2), @y)
#     @prev_button.update(0,0)
#     return @value
#   end

#   def draw
#     # @font.draw("<", @next_x, @y, 1, 1.0, 1.0, 0xff_ffff00)

#     @next_button.draw(-@next_button.w, 0)

#     # @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)

#     # image = get_image
#     # image.draw((@max_width / 2) - image.width / 2, y + image.height / 2, 1)
#     @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)
#     # @font.draw(">", @prev_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
#     @prev_button.draw(0,0)
#   end

# end