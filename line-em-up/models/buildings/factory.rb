require_relative 'building.rb'

# Offensive store for now, don't have any other hardport types atm.
module Buildings
  class Factory < Buildings::Building

    SHIP_LIMIT = 1

    attr_reader :credits

    def initialize(current_map_tile_x, current_map_tile_y, window, options = {})
      @window = window
      # puts "2TOPIONS: "
      # puts options.inspect
      super(current_map_tile_x, current_map_tile_y, window, options)
      # offensive_types = Launcher.descendants
      @close_image = @image
      @close_info  = @close_image.gl_tex_info
      @open_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/factory_open.png", :tileable => true)
      @open_info  = @open_image.gl_tex_info
      @ships = []
      @create_ship_every   = rand(50) + 1500
      @open_factory_length = 30
      @factory_opened_at   = nil
      @last_created_ship_at = @create_ship_every

      @creating_ships = []
      @thread = nil
      # @image_width  = @image.width  * (@height_scale || @scale)# / self.class::IMAGE_SCALER
      # @image_height = @image.height * (@height_scale || @scale)# / self.class::IMAGE_SCALER
      # @image_size   = @image_width  * @image_height / 2
      # @image_radius = (@image_width  + @image_height) / 4

      # @image_width_half  = @image_width  / 2.0
      # @image_height_half = @image_height / 2.0
    end

    def update mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options = {}
      result = super(mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, player_x, player_y, player, ships, buildings, options)

      new_ship = @creating_ships.shift
      if new_ship
        @ships << new_ship
      end
      # t = nil
      if @time_alive > @last_created_ship_at + @create_ship_every && @ships.count < self.class::SHIP_LIMIT
        # puts "CREATING NEW SHIP"
        # puts "GETTING NEW SHIP HERE: #{self.get_faction_id}"
        # new_ship = AIShip.new(nil, nil, @current_map_tile_x, @current_map_tile_y, {special_target_focus_id: 'player', long_range: true, angle: 0.0, faction_id: self.get_faction_id})
        # @ships << new_ship
        @thread = Thread.new do
          @creating_ships << AIShip.new(nil, nil, @current_map_tile_x, @current_map_tile_y, {special_target_focus_id: 'player', long_range: true, angle: 0.0, faction_id: self.get_faction_id})
          # pid, status = Process.wait2(pid)
          # Thread.current[:status] = status
          # Thread.current[:pid]    = pid
          # data = Marshal.load(r.gets)
          Thread.exit
        end

        # Create new ship
        @last_created_ship_at = @time_alive
        @factory_opened_at = @time_alive
        @image = @open_image
        # puts "OPENING FACTORY"
        @info  = @open_info
      end

      if @ships.count >= self.class::SHIP_LIMIT
        @last_created_ship_at = @time_alive
      end

      if !@factory_opened_at.nil? && @time_alive > @factory_opened_at + @open_factory_length
        # puts "CLOSING FACTORY"
        # puts "@factory_opened_at + @open_factory_length > @time_alive"
        # puts "#{@factory_opened_at} + #{@open_factory_length} > #{@time_alive}"
        @image = @close_image
        @info  = @close_info
        @factory_opened_at = nil
      end


      @ships.reject! do |ship|
        !ship.is_alive || ship.get_faction_id != get_faction_id
      end

      if @thread && @thread.alive?
        @thread.join
        @thread = nil
      end
      if new_ship
        result.merge({add_ships: [new_ship]})
      else
        return result # merge in any new ships
      end
    end

    def self.get_minimap_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/minimap_factory.png")
    end


    def alt_draw x, y
      # @image.draw(@x, @y, 1, @height_scale, @height_scale, Gosu::Color.argb(0xff_ff0000))
      # @image.draw(x, y, 1, @height_scale, @height_scale, Gosu::Color.argb(0xff_ff0000))
    end

    def self.get_image
      Gosu::Image.new("#{MEDIA_DIRECTORY}/buildings/factory_closed.png", :tileable => true)
    end
  end

end