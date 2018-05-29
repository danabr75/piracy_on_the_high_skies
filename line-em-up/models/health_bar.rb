require_relative 'general_object.rb'

class HealthBar < GeneralObject
  attr_reader :x, :y, :living_time

  def initialize(scale, screen_width = nil, screen_height = nil, image = nil)
    @scale = scale
    padding = 10 * @scale
    @health_100 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_0.png")
    @health_90 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_1.png")
    @health_80 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_2.png")
    @health_70 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_3.png")
    @health_60 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_4.png")
    @health_50 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_5.png")
    @health_40 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_6.png")
    @health_30 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_7.png")
    @health_20 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_8.png")
    @health_10 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_9.png")
    @health_00 = Gosu::Image.new("#{MEDIA_DIRECTORY}/health_bar_10.png")


    @green_health_100 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_0.png")
    @green_health_90 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_1.png")
    @green_health_80 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_2.png")
    @green_health_70 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_3.png")
    @green_health_60 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_4.png")
    @green_health_50 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_5.png")
    @green_health_40 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_6.png")
    @green_health_30 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_7.png")
    @green_health_20 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_8.png")
    @green_health_10 = Gosu::Image.new("#{MEDIA_DIRECTORY}/green_health_bar_9.png")


    # @time_alive = 0
    # @image_width  = @image.width  * @scale
    # @image_height = @image.height * @scale
    # @image_size   = @image_width  * @image_height / 2
    # @image_radius = (@image_width  + @image_height) / 4
    @current_speed = (SCROLLING_SPEED - 1) * @scale
    @health = 0
    @image_width  = (@health_100.width  * @scale)
    @image_height = (@health_100.height * @scale)

    # @image_width_half  = 
    # @image_height_half = 
    @x = screen_width - @image_width - padding
    @y = screen_height- @image_height - padding
  end

  def get_draw_ordering
    ZOrder::UI
  end

  def draw health_level
    if health_level >= 200
      image = @green_health_100
    elsif health_level >= 190
      image = @green_health_90
    elsif health_level >= 180
      image = @green_health_80
    elsif health_level >= 170
      image = @green_health_70
    elsif health_level >= 160
      image = @green_health_60
    elsif health_level >= 150
      image = @green_health_50
    elsif health_level >= 140
      image = @green_health_40
    elsif health_level >= 130
      image = @green_health_30
    elsif health_level >= 120
      image = @green_health_20
    elsif health_level >= 110
      image = @green_health_10
    elsif health_level >= 100
      image = @health_100
    elsif health_level >= 90
      image = @health_90
    elsif health_level >= 80
      image = @health_80
    elsif health_level >= 70
      image = @health_70
    elsif health_level >= 60
      image = @health_60
    elsif health_level >= 50
      image = @health_50
    elsif health_level >= 40
      image = @health_40
    elsif health_level >= 30
      image = @health_30
    elsif health_level >= 20
      image = @health_20
    elsif health_level >= 10
      image = @health_10
    else
      image = @health_00
    end

    image.draw(@x, @y, get_draw_ordering, @scale, @scale)
  end


  def update
    raise "Do not call update on this object"
  end


end