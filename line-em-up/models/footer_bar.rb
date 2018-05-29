require_relative 'general_object.rb'

class FooterBar < GeneralObject
  attr_reader :x, :y, :living_time

  def initialize(scale, screen_width = nil, screen_height = nil, image = nil)
    @scale = scale * 0.7
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

    @bomb_hud = Gosu::Image.new("#{MEDIA_DIRECTORY}/bomb_pack_hud.png")
    @missile_hud = Gosu::Image.new("#{MEDIA_DIRECTORY}/missile_pack_hud.png")


    # @time_alive = 0
    # @image_width  = @image.width  * @scale
    # @image_height = @image.height * @scale
    # @image_size   = @image_width  * @image_height / 2
    # @image_radius = (@image_width  + @image_height) / 4
    # @current_speed = (SCROLLING_SPEED - 1) * @scale
    @health = 0

    @health_bar_width  = (@health_100.width  * @scale)
    @health_bar_height = (@health_100.height * @scale)


    # @image_width_half  = 
    # @image_height_half = 
    @health_bar_x = screen_width - @health_bar_width - padding
    @health_bar_y = screen_height- @health_bar_height - padding

    @bomb_hud_width    = (@bomb_hud.width  * @scale)
    @bomb_hud_height   = (@bomb_hud.height * @scale)
    @bomb_hud_width_half  = @bomb_hud_width / 2
    @bomb_hud_height_half = @bomb_hud_height /2

    @bomb_hud_x = screen_width - @health_bar_width - padding  - @bomb_hud_width - padding
    @bomb_hud_y = screen_height - @bomb_hud_height - padding

    @missile_hud_width    = (@missile_hud.width  * @scale)
    @missile_hud_height   = (@missile_hud.height * @scale)
    @missile_hud_width_half  = @missile_hud_width / 2
    @missile_hud_height_half = @missile_hud_height /2

    @missile_hud_x = screen_width - @health_bar_width - padding  - @bomb_hud_width - padding - @missile_hud_width - padding
    @missile_hud_y = screen_height - @missile_hud_height - padding

    @font = Gosu::Font.new(20)
    @red_color = Gosu::Color.new(0xff_000000)
    @red_color.red = 255
    @black_color = Gosu::Color.new(0xff_000000)
    @black_color.red = 0
    @black_color.green = 0
    @black_color.blue = 0
    @current_color = Gosu::Color.new(0xff_000000)
    @current_color.red = 51
    @current_color.green = 204
    @current_color.blue = 51
    # rgb(51, 204, 51)
  end

  def get_draw_ordering
    ZOrder::UI
  end

  def draw player
    health_level = player.health
    if health_level >= 200
      health_image = @green_health_100
    elsif health_level >= 190
      health_image = @green_health_90
    elsif health_level >= 180
      health_image = @green_health_80
    elsif health_level >= 170
      health_image = @green_health_70
    elsif health_level >= 160
      health_image = @green_health_60
    elsif health_level >= 150
      health_image = @green_health_50
    elsif health_level >= 140
      health_image = @green_health_40
    elsif health_level >= 130
      health_image = @green_health_30
    elsif health_level >= 120
      health_image = @green_health_20
    elsif health_level >= 110
      health_image = @green_health_10
    elsif health_level >= 100
      health_image = @health_100
    elsif health_level >= 90
      health_image = @health_90
    elsif health_level >= 80
      health_image = @health_80
    elsif health_level >= 70
      health_image = @health_70
    elsif health_level >= 60
      health_image = @health_60
    elsif health_level >= 50
      health_image = @health_50
    elsif health_level >= 40
      health_image = @health_40
    elsif health_level >= 30
      health_image = @health_30
    elsif health_level >= 20
      health_image = @health_20
    elsif health_level >= 10
      health_image = @health_10
    else
      health_image = @health_00
    end

    health_image.draw(@health_bar_x, @health_bar_y, get_draw_ordering, @scale, @scale)

    @bomb_hud.draw(@bomb_hud_x, @bomb_hud_y, get_draw_ordering, @scale, @scale)
    # @bomb_hud_width_half  = @bomb_hud_width / 2
    # @bomb_hud_height_half = @bomb_hud_height /2
    if player.get_secondary_name == 'Bomb'
      bomb_color = @current_color
    else
      bomb_color = @red_color
    end
    @font.draw("#{player.bombs}", @bomb_hud_x + @bomb_hud_width_half - (@font.text_width("#{player.bombs}")), @bomb_hud_y + @bomb_hud_height_half, ZOrder::UI, @scale, @scale, bomb_color)
    # local_width  = @font.text_width('>')
    # local_height = @font.height
    @missile_hud.draw(@missile_hud_x, @missile_hud_y, get_draw_ordering, @scale, @scale)
    # draw(text, x, y, z, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default) ⇒ void
    if player.get_secondary_name == 'Rocket'
      rocket_color = @current_color
    else
      rocket_color = @red_color
    end
    @font.draw("#{player.rockets}", @missile_hud_x + @missile_hud_width_half - (@font.text_width("#{player.rockets}")), @missile_hud_y - 5 +  @missile_hud_height_half, ZOrder::UI, @scale, @scale, rocket_color)

  end


  def update
    raise "Do not call update on this object"
  end


end