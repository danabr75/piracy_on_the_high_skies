require_relative 'general_object.rb'

class SmallExplosion < GeneralObject
  attr_reader :x, :y, :living_time
  TIME_TO_LIVE = 50

  def initialize(scale, x = nil, y = nil)
    @scale = scale
    # @smoke = Gosu::Image.new("#{MEDIA_DIRECTORY}/smoke.png", :tileable => true)
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/starfighterv4.png", :tileable => true)

    @x = x || 0
    @y = y || 0
    @time_alive = 0
  end

  def draw
    spin_down = 0
    if @time_alive > 0
      spin_down = (@time_alive * @time_alive) / 5
    end
    if spin_down > (@time_alive * 10)
      spin_down = @time_alive * 10
    end
    @image.draw_rot(@x, @y, ZOrder::SmallExplosions, (360 - spin_down), 0.5, 0.5, @scale, @scale)
  end


  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    # Remove even if hasn't gone offscreen
    if @time_alive <= TIME_TO_LIVE
      @time_alive += 1
      @y += (SCROLLING_SPEED - 1) * @scale
      super(width, height, mouse_x, mouse_y)
    else
      false
    end
  end


end