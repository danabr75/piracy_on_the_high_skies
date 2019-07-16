require 'gosu'

# require 'opengl'
# require 'glu'
require 'glut'


require_relative 'angled_particle.rb'

module Graphics

  # include OpenGL # Gl
  # include GLUT   # Glut 
  # include GLU    # Glu

  class Animation
    IMAGE_SCALER = 8.0

    FRAME_HEIGHT      = 128
    # FRAME_HEIGHT_HALF = FRAME_HEIGHT / 2.0
    FRAME_WIDTH       = 128
    # FRAME_WIDTH_HALF  = FRAME_WIDTH / 2.0

    def initialize current_map_pixel_x, current_map_pixel_y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, fps_scaler, options = {}
      @fps_scaler = fps_scaler
      @current_map_pixel_x = current_map_pixel_x
      @current_map_pixel_y = current_map_pixel_y
      @screen_pixel_width = screen_pixel_width
      @screen_pixel_height = screen_pixel_height
      @frames = self.class.get_frames

      # puts "TEST"
      # puts @frames[0].width
      # puts @frames[0].height
      @frame_height_half = (self.class::FRAME_HEIGHT / self.class::IMAGE_SCALER) * height_scale
      @frame_width_half  = (self.class::FRAME_WIDTH  / self.class::IMAGE_SCALER) * height_scale
      # puts "@frames.size: #{@frames.size}"

      @height_scale = height_scale

      # smaller is faster, larger is slower
      @frames_limit = 1.5

      @height_scale_with_image_scaler = height_scale / self.class::IMAGE_SCALER


      @time_alive = 0.0
      @x = nil
      @y = nil
      # @max_time_alive = 10000
    end

    def self.get_frames
      raise "override me"
      # return Gosu::Image.load_tiles 'res/dude.png', 32, 48
    end

    def draw viewable_pixel_offset_x, viewable_pixel_offset_y
      if @x && @y
        if @time_alive / (@frames_limit) > @frames.size
          raise "invalid frame: #{time_alive / (@frames_limit)} for #{@frames.size}"
        end
        # @frames[@time_alive / (@frames_limit)].draw(@x + viewable_pixel_offset_x, @y - viewable_pixel_offset_y, ZOrder::Explosions, @height_scale_with_image_scaler, @height_scale_with_image_scaler) #if @image
        @frames[@time_alive / (@frames_limit)].draw(@x + viewable_pixel_offset_x - @frame_width_half, @y - viewable_pixel_offset_y - @frame_height_half, ZOrder::Explosions, @height_scale_with_image_scaler, @height_scale_with_image_scaler) #if @image
      end
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
      @time_alive += 1.0 * @fps_scaler
      @x, @y = GeneralObject.convert_map_pixel_location_to_screen(player_map_pixel_x, player_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y, @screen_pixel_width, @screen_pixel_height)
      return (@time_alive / (@frames_limit)) < @frames.size
    end

  end
end