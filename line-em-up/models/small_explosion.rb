require_relative 'general_object.rb'

class SmallExplosion < GeneralObject
  attr_reader :x, :y, :living_time
  TIME_TO_LIVE = 50

  def initialize(scale, screen_width, screen_height, x = nil, y = nil, image = nil, options = {})
    @scale = scale
    @smoke_scale = @scale * 1.2
    @smoke = Gosu::Image.new("#{MEDIA_DIRECTORY}/smoke.png")
    @image = image#Gosu::Image.new("#{MEDIA_DIRECTORY}/starfighterv4.png", :tileable => true)

    @x = x || 0
    @y = y || 0
    @time_alive = 0
    @image_width  = @image.width  * @scale
    @image_height = @image.height * @scale
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4
    @current_speed = (SCROLLING_SPEED - 1) * @scale
    
    @screen_width  = screen_width
    @screen_height = screen_height
    @off_screen = screen_height + screen_height
  end

  def draw
    spin_down = 0
    if @time_alive > 0
      spin_down = (@time_alive * @time_alive) / 5
    end
    if spin_down > (@time_alive * 10)
      spin_down = @time_alive * 10
    end
    @smoke.draw_rot(@x, @y, ZOrder::SmallExplosions, (360 - spin_down), 0.5, 0.5, @smoke_scale, @smoke_scale)
    @image.draw_rot(@x, @y, ZOrder::SmallExplosions, (360 - spin_down), 0.5, 0.5, @scale, @scale)
  end


  def update mouse_x = nil, mouse_y = nil, player = nil
    # Remove even if hasn't gone offscreen
    if @time_alive <= TIME_TO_LIVE
      @time_alive += 1
      @y += @current_speed
      super(mouse_x, mouse_y)
    else
      false
    end
  end


end