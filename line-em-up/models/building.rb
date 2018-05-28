require_relative 'general_object.rb'

class Building < GeneralObject
  POINT_VALUE_BASE = 1
  attr_accessor :health, :armor, :x, :y

  def initialize(scale, x = nil, y = nil)
    @scale = scale
    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/building.png").first.resize(0.3)
    # @image = Gosu::Image.new(image, :tileable => true)
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png")
    @x = rand * 800
    @y = 0 - get_height
    # puts "NEW BUILDING: #{@x} and #{@y}"
    @health = 15
    @armor = 0
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
      [HealthPack.new(@scale, @x, @y)]
    elsif rand(10) == 8
      [BombPack.new(@scale, @x, @y)]
    else
      [MissilePack.new(@scale, @x, @y)]
    end
  end

  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    if is_alive
      @y += (GLBackground::SCROLLING_SPEED * @scale)
      @y < height + get_height
    else
      false
    end
  end
end