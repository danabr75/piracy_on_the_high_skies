require_relative 'general_object.rb'

class Building < GeneralObject
  POINT_VALUE_BASE = 1
  attr_accessor :health, :armor, :x, :y


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png")
  end

  def initialize(scale, screen_width, screen_height, x = nil, y = nil, options = {})
    # @scale = scale
    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/building.png").first.resize(0.3)
    # @image = Gosu::Image.new(image, :tileable => true)
    # @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png")
    # @image_width  = @image.width  * @scale
    # @image_height = @image.height * @scale
    # @image_size   = @image_width  * @image_height / 2
    # @image_radius = (@image_width  + @image_height) / 4
    # @x = rand * 800
    # @y = 0 - get_height
    # puts "NEW BUILDING: #{@x} and #{@y}"
    super(scale, rand(screen_width), 0 - get_image.height, screen_width, screen_height, options)
    @health = 15
    @armor = 0
    @current_speed = (GLBackground::SCROLLING_SPEED * @scale)
  end

  def get_points
    return POINT_VALUE_BASE
  end

  def is_alive
    @health > 0
  end

  def take_damage damage
    @health -= damage
  end

  def drops
    rand_num = rand(10)
    if rand(10) == 9
      [HealthPack.new(@scale, @screen_width, @screen_height, @x, @y)]
    elsif rand(10) == 8
      [BombPack.new(@scale, @screen_width, @screen_height, @x, @y)]
    else
      [MissilePack.new(@scale, @screen_width, @screen_height, @x, @y)]
    end
  end

  def get_draw_ordering
    ZOrder::Building
  end


  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    if is_alive
      @y += @current_speed * scroll_factor
      @y < @screen_height + get_height
    else
      false
    end
  end
end