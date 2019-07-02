require_relative 'effect.rb'
require_relative '../../lib/global_constants.rb'
require_relative '../../lib/global_variables.rb'

module Effects
  class Dialogue < Effects::Effect
    include GlobalConstants
    attr_reader :target
    attr_accessor :dialogue_index
    def initialize quest_key, section_key, player, options = {}
     # puts "INIT DIALOGUE HERE: #{quest_key} - #{section_key}"
      super(options)
      @debug = options[:debug]
      @complete = false
      dialogue_path = "#{DIALOGUE_DIRECTORY}/#{quest_key}.json"
      raise "INVALID QUEST KEY HERE: #{quest_key}" if !File.exist?(dialogue_path)
      json_data = File.read(dialogue_path)
      @dialogue_data = JSON.parse(json_data)
      @section_data  = @dialogue_data[section_key]
      @dialogue_index = 0 # When click next or select choice, increment dialogue index
      @font_height  = (12 * @average_scale).to_i
      @font_padding = (4 * @average_scale).to_i
      @font = Gosu::Font.new(@font_height)
      @y_offset        = @font_height * 10
      # @button_y_offset = @font_height * 13
      @button_id_mapping = self.class.get_id_button_mapping
      @button_size = (40 * @average_scale).to_i
      @next_button = LUIT::Button.new(self, :next, (@screen_pixel_width / 2), @screen_pixel_height - (@font_height * 3), ZOrder::UI, "Next", @button_size, (@button_size / 2.0).to_i )
      player.enable_invulnerability
      player.disable_controls
    end

    def self.get_id_button_mapping
      values = {
        next: lambda { |dialogue, id| dialogue.increment_dialogue },
      }
    end

    def increment_dialogue
      @dialogue_index += 1
    end

    def onClick element_id
      # puts "ONCLICK mappuing"
      # puts @button_id_mapping
      button_clicked_exists = @button_id_mapping.key?(element_id)
      if button_clicked_exists
       # puts "BUTTON EXISTS: #{element_id}"
        @button_id_mapping[element_id].call(self, element_id)
      else
        raise "Clicked button that is not mapped: #{element_id}"
      end
    end

    def is_active
      !@section_data[@dialogue_index].nil?
    end

    def update gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y
      @next_button.update(-(@next_button.w / 2), -(@next_button.h))

      if !is_active
        player.disable_invulnerability
        player.enable_controls
      end

      return [gl_background, ships, buildings, player, offset_target, viewable_pixel_offset_x, viewable_pixel_offset_y]
    end

    def dialogue_box_draw
      raise "FOUND NIL IN SECTION DATA at index: #{@dialogue_index}" if @section_data[@dialogue_index].nil?
      texts = @section_data[@dialogue_index]["text"]
      from  = @section_data[@dialogue_index]["from"]

     # puts "TEXTs: "
     # puts texts.inspect


      @font.draw(from, (@screen_pixel_width / 2) - (@font.text_width(from) / 2.0), (@screen_pixel_height) - (@y_offset), ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      texts.each_with_index do |text, index|
        # index is + 1 to allow room for the "from"
        height_padding = (index + 1) * @font_height
        @font.draw(text, (@screen_pixel_width / 4), (@screen_pixel_height) + height_padding - (@y_offset), ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      end
    end

    def draw
     # puts "DIALOGUES DRAW"
      @next_button.draw(-(@next_button.w / 2), -(@next_button.h))
      dialogue_box_draw
      # draw box of text w/ clickable areas for next. 
      # future case, draw clickable areas for multiple choices
    end
  end
end