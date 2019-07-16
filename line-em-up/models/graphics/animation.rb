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
    def initialize current_map_pixel_x, current_map_pixel_y, width_scale, height_scale, screen_pixel_width, screen_pixel_height, fps_scaler, options = {}
      @fps_scaler = fps_scaler
      @current_map_pixel_x = current_map_pixel_x
      @current_map_pixel_y = current_map_pixel_y
      @screen_pixel_width = screen_pixel_width
      @screen_pixel_height = screen_pixel_height
      @frames = self.class.get_frames
      @height_scale = height_scale

      @frames_limit = 3

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
        @frames[@time_alive / (@frames_limit)].draw(@x + viewable_pixel_offset_x, @y + viewable_pixel_offset_y, ZOrder::Explosions, @height_scale_with_image_scaler, @height_scale_with_image_scaler) #if @image
      end
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y
      @time_alive += 1.0 * @fps_scaler
      @x, @y = GeneralObject.convert_map_pixel_location_to_screen(player_map_pixel_x, player_map_pixel_y, @current_map_pixel_x, @current_map_pixel_y, @screen_pixel_width, @screen_pixel_height)
      return (@time_alive / (@frames_limit)) < @frames.size
    end

  end
end