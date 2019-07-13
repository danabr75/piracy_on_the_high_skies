require_relative 'screen_fixed_object.rb'


class ScreenMap < ScreenFixedObject

  IMAGE_SCALER = 2.5

  ICON_IMAGE_SCALER = 20

  def initialize(map_name, map_tile_width, map_tile_height, options = {})
    super(options)

    file_path = "#{MAP_DIRECTORY}/#{map_name}_minimap.png"
    @image = Gosu::Image.new(file_path)

    @image_width  = @image.width  * @height_scale_with_image_scaler
    @image_height = @image.height * @height_scale_with_image_scaler


    @image_width  = @image.width  * @height_scale_with_image_scaler
    @image_height = @image.height * @height_scale_with_image_scaler

    @height_scale_with_icon_image_scaler = @height_scale / self.class::ICON_IMAGE_SCALER

    @player_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/minimap_player.png")
    @player_image_width  = @player_image.width  * @height_scale_with_icon_image_scaler
    @player_image_height = @player_image.height * @height_scale_with_icon_image_scaler



    @x_increment = @image_width  / (@map_tile_width.to_f)
    @y_increment = @image_height / (@map_tile_height.to_f)

    @map_tile_width  = map_tile_width
    @map_tile_height = map_tile_height

    @cell_padding_width  = @height_scale * 3.0
    @cell_padding_height = @height_scale * 3.0

    @font_height  = (15 * @height_scale).to_i
    @font = Gosu::Font.new(@font_height)
    # @screen_pixel_width  = screen_pixel_width
    # @screen_pixel_height = screen_pixel_height
    @x = @screen_pixel_width - @cell_padding_width
    @y = @cell_padding_height
    @cell_width  = @height_scale / 2.0
    @cell_height = @height_scale / 2.0

    @mini_map_pixel_width  = @map_tile_width  * @cell_width
    @mini_map_pixel_height = @map_tile_height * @cell_height

    @color = Gosu::Color.argb(0xcc_ffffff)
    @player_tile_x = nil
    @player_tile_y = nil
    @player_x = nil
    @player_y = nil

    # @mini_map_image = init_map(background_map_data)
    # puts "MINIMAP LENGTH: #{@mini_map.count}"
  end

  def draw
    @image.draw(@x - @image_width, @y, ZOrder::MiniMap, @height_scale_with_image_scaler, @height_scale_with_image_scaler, @color)
    if @player_tile_x && @player_tile_y
      # MiniMapIcon
      @player_image.draw(@player_x, @player_y, ZOrder::MiniMapIcon, @height_scale_with_icon_image_scaler, @height_scale_with_icon_image_scaler, @color)
    end
  end

  def update player_tile_x, player_tile_y
    @player_tile_x = player_tile_x
    @player_tile_y = player_tile_y
    @player_x = @x - @x_increment * player_tile_x - (@player_image_width / 2.0)
    @player_y = @y + @y_increment * player_tile_y - (@player_image_height / 2.0)
  end






end