require_relative 'general_object.rb'

class Building < GeneralObject
  POINT_VALUE_BASE = 1
  attr_accessor :health, :armor, :x, :y


  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/building.png")
  end

  def initialize(scale, x, y, screen_width, screen_height, width_scale, height_scale, location_x = nil, location_y = nil, map_height = nil, map_width = nil, options = {})
    super(scale, x, y, screen_width, screen_height, width_scale, height_scale, location_x, location_y, map_height, map_width, options)
    @health = 15
    @armor = 0
    @height = options[:z] || 1
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