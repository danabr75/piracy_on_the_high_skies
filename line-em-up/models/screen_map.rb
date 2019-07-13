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

    @player_image = Player.get_minimap_image
    @player_image_width  = @player_image.width  * @height_scale_with_icon_image_scaler
    @player_image_height = @player_image.height * @height_scale_with_icon_image_scaler
    @player_image_width_half  = @player_image_width / 2.0
    @player_image_height_half = @player_image_height / 2.0


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

    @icons = []

    # @mini_map_image = init_map(background_map_data)
    # puts "MINIMAP LENGTH: #{@mini_map.count}"
  end

  def draw
    @image.draw(@x - @image_width, @y, ZOrder::MiniMap, @height_scale_with_image_scaler, @height_scale_with_image_scaler, @color)
    if @player_tile_x && @player_tile_y
      # MiniMapIcon
      @player_image.draw(@player_x, @player_y, ZOrder::PlayerMiniMapIcon, @height_scale_with_icon_image_scaler, @height_scale_with_icon_image_scaler, @color)
    end
    @icons.each do |icon|
      icon[:image].draw(icon[:x], icon[:y], ZOrder::MiniMapIcon, @height_scale_with_icon_image_scaler, @height_scale_with_icon_image_scaler, @color)
    end
  end

  def update player_tile_x, player_tile_y, buildings#, ships
    Thread.new do
      @player_tile_x = player_tile_x
      @player_tile_y = player_tile_y
      # puts "PLAYER IMAGE MINI: #{@player_image_width} - #{@player_image_height}"
      @player_x = convert_tile_x_to_screen_x(player_tile_x, @player_image_width_half)
      @player_y = convert_tile_y_to_screen_y(player_tile_y, @player_image_height_half)

      icons = []

      buildings.each do |b|
        image = b.minimap_image
        if image
          # b.current_map_pixel_x
          # b.current_map_pixel_y
          icons << {
            image: image,
            x: convert_tile_x_to_screen_x(b.current_map_tile_x, b.mini_map_image_width_half),
            y: convert_tile_y_to_screen_y(b.current_map_tile_y, b.mini_map_image_height_half)
          }
          # puts "ICONS HERE:"
          # puts "Tile #{b.current_map_tile_x} - #{b.current_map_tile_y}"
          # puts "X: #{convert_tile_x_to_screen_x(b.current_map_tile_x, b.mini_map_image_width_half)} Y: #{convert_tile_y_to_screen_y(b.current_map_tile_y, b.mini_map_image_height_half)}"
          # puts "IMAGE H AND W: #{b.mini_map_image_width_half}  -  #{b.mini_map_image_height_half}"
        end
      end

      @icons = icons
      Thread.exit
    end

  end

  def convert_tile_x_to_screen_x object_tile_x, image_width_half
      # attr_reader :mini_map_image_width_half, :mini_map_image_height_half
    return @x - (@x_increment * object_tile_x) - image_width_half
  end

  def convert_tile_y_to_screen_y object_tile_y, image_height_half
    return @y + (@y_increment * object_tile_y) - image_height_half
  end






end