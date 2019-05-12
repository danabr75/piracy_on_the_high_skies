require 'luit'

require_relative 'setting.rb'
require_relative '../models/basic_ship.rb'
require_relative '../models/launcher.rb'
# require "#{MODEL_DIRECTORY}/basic_ship.rb"
# require_relative "config_settings.rb"

class ShipLoadoutSetting < Setting
  # MEDIA_DIRECTORY
  SELECTION = ::Launcher.descendants
  NAME = "ship_loadout"

  # def self.get_weapon_options
  #   ::Launcher.descendants
  # end

  # attr_accessor :x, :y, :font, :max_width, :max_height, :selection, :value, :ship_value
  attr_accessor :value, :ship_value
  attr_accessor :mouse_x, :mouse_y
  def initialize window, fullscreen_height, max_width, max_height, current_height, config_file_path, ship_value, options = {}
    # @window = window # Want relative to self, not window. Can't do that from settting, not a window.
    @mouse_x, @mouse_y = [0,0]
    @window = self # ignoring outer window here? Want actions relative to this window.
    @scale = options[:scale] || 1
    @font = Gosu::Font.new(20)
    # @x = width
    @y = current_height
    @max_width = max_width
    @max_height = max_height
    @next_x = 5 * @scale
    @prev_x = @max_width - 5 * @scale - @font.text_width('>')
    LUIT.config({window: @window, z: 25})
    @selection = []
    @launchers = ::Launcher.descendants.collect{|d| d.name}
    @meta_launchers = {}
    @filler_items = []
    @launchers.each_with_index do |klass_name, index|
      klass = eval(klass_name)
      image = klass.get_hardpoint_image
      button_key = "clicked_launcher_#{index}".to_sym
      @meta_launchers[button_key] = {follow_cursor: false, klass: klass, image: image}
      @filler_items << {follow_cursor: false, klass: klass, image: image}
      # @button_id_mapping[button_key] = lambda { |setting, id| setting.click_inventory(id) }
    end
    @hardpoint_image_z = 50
    # puts "SELECTION: #{@selection}"
    # puts "INNITING #{config_file_path}"
    @config_file_path = config_file_path
    @name = self.class::NAME
    @ship_value = ship_value
    klass = eval(@ship_value)
    # implement hide_hardpoints on pilotable ship class
    @ship = klass.new(1, @max_width / 2, @y + klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY).height / 2, max_width, max_height, {use_large_image: true, hide_hardpoints: true})
    # puts "RIGHT HERE!@!!!"
    # puts "@ship.right_broadside_hard_points"
    # puts @ship.right_broadside_hard_points
    @value = ConfigSetting.get_setting(@config_file_path, @name, @selection[0])
    @fullscreen_height = fullscreen_height
    # @window = window
    # first array is rows at the top, 2nd goes down through the rows
    @inventory_matrix = []
    @inventory_matrix_max_width = 4
    @inventory_matrix_max_height = 7
    @cell_width  = 25 * @scale
    @cell_height = 25 * @scale
    @cell_width_padding = 5 * @scale
    @cell_height_padding = 5 * @scale
    @button_id_mapping = self.class.get_id_button_mapping
    init_matrix
    # puts "FILLER ITEMS: #{@filler_items}"
    fill_matrix(@filler_items)
    @cursor_object = nil
    @ship_hardpoints = init_hardpoints(@ship)
  end

  def self.get_id_button_mapping
    values = {
      next: lambda { |setting, id| setting.next_clicked },
      previous: lambda { |setting, id| setting.previous_clicked }
    }
  end

  def fill_matrix elements
    elements.each do |element|
      space = find_next_matrix_space
      if space
        # puts "ASSIGNING ELEMENT:"
        # puts element.inspect
        @inventory_matrix[space[:x]][space[:y]][:item] = element.merge({follow_cursor: false, key: space[:key]})
      else
        puts "NO SPACE LEFT"
      end
    end
  end

  def find_next_matrix_space
    found_space = nil
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        if @inventory_matrix[x][y][:item].nil?
          key = "matrix_#{x}_#{y}"            
          found_space = {x: x, y: y, key: key}
        end
        break if found_space
      end
      break if found_space
    end
    return found_space
  end

  def init_matrix
    (0..@inventory_matrix_max_width - 1).each do |i|
      @inventory_matrix[i] = Array.new(@inventory_matrix_max_height)
    end
    current_y = @y + @cell_height_padding
    current_x = @next_x
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        key = "matrix_#{x}_#{y}"
        click_area = LUIT::ClickArea.new(@window, key, current_x, current_y, @cell_width, @cell_height)
        # click_area = LUIT::Button.new(@window, click_key, current_x, current_y, '', @cell_width, @cell_height)
        @inventory_matrix[x][y] = {x: current_x, y: current_y, click_area: click_area, key: key, item: nil}
        current_x = current_x + @cell_width + @cell_width_padding
        @button_id_mapping[key] = lambda { |setting, id| setting.click_inventory(id) }
      end
      current_x = @next_x
      current_y = current_y + @cell_height + @cell_height_padding
    end
  end

  def matrix_draw
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        element = @inventory_matrix[x][y]
        element[:click_area].draw(0,0)
        # puts "element[:item]: #{element[:item]}"
        if !element[:item].nil? && element[:item][:follow_cursor] != true
          image = element[:item][:image]
          image.draw(element[:x] - (image.width / 2) + @cell_width / 2, element[:y] - (image.height / 2) + @cell_height / 2, @hardpoint_image_z)
        end
      end
    end
  end

  def hardpoint_draw
    @ship_hardpoints.each do |key, list|
      if list.any?
        list.each do |value|
          click_area = value[:click_area]
          if click_area
            click_area.draw(0, 0)
          else
            # puts " NO CLICK AREA FOUND"
          end
          item = value[:item]
          if item
            image = item[:image]
            if image
              image.draw(value[:x] - (image.width / 2) + @cell_width / 2, value[:y] - (image.height / 2)  + @cell_height / 2, @hardpoint_image_z)
            end
          end
        end
      else
        # puts " KEY DID NOT HAVE Value"
      end
    end
  end

  def matrix_update
    (0..@inventory_matrix_max_height - 1).each do |y|
      (0..@inventory_matrix_max_width - 1).each do |x|
        @inventory_matrix[x][y][:click_area].update(0,0)
      end
    end
  end

  def print_out_matrix
    (0..@inventory_matrix_max_height - 1).each do |y|
      row_value = []
      (0..@inventory_matrix_max_width - 1).each do |x|
        value = @inventory_matrix[x][y]
        if value.nil?
          value = 'O'
        else
          value = 'X'
        end
        row_value << value
      end
      puts row_value.join(', ')
    end
  end

  def init_hardpoints ship
    # Populate ship hardpoints from save file here.
    # will be populated from the ship, don't need to here.
    value = {}
    groups = [
      {hardpoints: ship.right_broadside_hard_points, location: :right},
      {hardpoints: ship.left_broadside_hard_points, location: :left},
      {hardpoints: ship.front_hard_points, location: :front}
    ]
    groups.each do |group|
      value[group[:location]] = []
      group[:hardpoints].each_with_index do |hp, index|
        button_key = "#{group[:location].to_s}_hardpoint_#{index}"
        click_area = LUIT::ClickArea.new(@window, button_key, hp.x + hp.x_offset / 2, hp.y + hp.y_offset / 2, @cell_width, @cell_height)
        @button_id_mapping[button_key] = lambda { |setting, id| setting.click_ship_hardpoint(id) }
        if hp.assigned_weapon_class
          image = hp.assigned_weapon_class.get_hardpoint_image
          item = {
            image: image, key: button_key, 
            weapon_klass: hp.assigned_weapon_class
          }

        else
        end
        value[group[:location]] << {item: item, x: hp.x + hp.x_offset / 2, y: hp.y + hp.y_offset / 2, click_area: click_area, key: button_key}
      end
    end
    puts "VALUES HERE FRONT:"
    puts value[:front]
    puts "VALUES HERE RIGHT:"
    puts value[:right].count
    puts "VALUES HERE LEFT:"
    puts value[:left].count

    # ship.left_broadside_hard_points.each do |hp|
    #   value[:left] << {weapon_klass: hp.assigned_weapon_class, x: hp.x + hp.x_offset, y: hp.y + hp.y_offset}
    # end

    # ship.front_hard_points.each do |hp|
    #   value[:front] << {weapon_klass: hp.assigned_weapon_class, x: hp.x + hp.x_offset, y: hp.y + hp.y_offset}
    # end
    return value
  end

  def click_ship_hardpoint id
    puts "click_ship_hardpoint: #{id}"
    # Key is front, right, or left


    port, i = id.scan(/(\w+)_hardpoint_(\d+)/).first
    port, i = [port.to_sym, i.to_i]
    puts "PORT AND I: #{port} and #{i}"

    hardpoint_element = @ship_hardpoints[port][i]
    element = hardpoint_element ? hardpoint_element[:item] : nil

    if @cursor_object && element
      puts "@cursor_object[:key]: #{@cursor_object[:key]}"
      puts "ID: #{id}"
      puts "== #{@cursor_object[:key] == id}"
      if @cursor_object[:key] == id
        # Same Object, Unstick it, put it back
        # element[:follow_cursor] = false
        # @inventory_matrix[x][y][:item][:follow_cursor] =
        hardpoint_element[:item] = @cursor_object
        hardpoint_element[:item][:key] = id
        @cursor_object = nil
      else
        # Else, drop object, pick up new object
        # @cursor_object[:follow_cursor] = false
        # element[:follow_cursor] = true
        temp_element = element
        hardpoint_element[:item] = @cursor_object
        hardpoint_element[:item][:key] = id
        @cursor_object = temp_element
        @cursor_object[:key] = nil # Original home lost, no last home of key present
        # @cursor_object[:follow_cursor] = true
        # WRRROOOONNGGG!
        # element = 
      end
    elsif element
      # Pick up element, no current object
      # element[:follow_cursor] = true
      @cursor_object = element
      hardpoint_element[:item] = nil
    elsif @cursor_object
      # Placeing something new in inventory
      hardpoint_element[:item] = @cursor_object
      hardpoint_element[:item][:key] = id
      # matrix_element[:item][:follow_cursor] = false
      @cursor_object = false
    end
  end

  def click_inventory id
    puts "LUANCHER: #{id}"
    puts "click_inventory: "
    x, y = id.scan(/matrix_(\d+)_(\d+)/).first
    x, y = [x.to_i, y.to_i]
    puts "LCICKED: #{x} and #{y}"
    matrix_element = @inventory_matrix[x][y]
    element = matrix_element ? matrix_element[:item] : nil

    # Resave new key when dropping element in.

    if @cursor_object && element
      puts "@cursor_object[:key]: #{@cursor_object[:key]}"
      puts "ID: #{id}"
      puts "== #{@cursor_object[:key] == id}"
      if @cursor_object[:key] == id
        # Same Object, Unstick it, put it back
        # element[:follow_cursor] = false
        # @inventory_matrix[x][y][:item][:follow_cursor] =
        matrix_element[:item] = @cursor_object
        matrix_element[:item][:key] = id
        @cursor_object = nil
      else
        # Else, drop object, pick up new object
        # @cursor_object[:follow_cursor] = false
        # element[:follow_cursor] = true
        temp_element = element
        matrix_element[:item] = @cursor_object
        matrix_element[:item][:key] = id
        @cursor_object = temp_element
        @cursor_object[:key] = nil # Original home lost, no last home of key present
        # @cursor_object[:follow_cursor] = true
        # WRRROOOONNGGG!
        # element = 
      end
    elsif element
      # Pick up element, no current object
      # element[:follow_cursor] = true
      @cursor_object = element
      matrix_element[:item] = nil
    elsif @cursor_object
      # Placeing something new in inventory
      matrix_element[:item] = @cursor_object
      matrix_element[:item][:key] = id
      # matrix_element[:item][:follow_cursor] = false
      @cursor_object = false
    end
  end


  def get_values
    # puts "GETTING DIFFICULTY: #{@value}"
    if @value
      @value
    end
  end

  def hardpoint_update
    @ship_hardpoints.each do |key, list|
      if list.any?
        list.each do |value|
          click_area = value[:click_area]
          if click_area
            click_area.update(0, 0)
          end
        end
      end
    end
  end

  def update mouse_x, mouse_y, ship_value
    @mouse_x, @mouse_y = [mouse_x, mouse_y]

    hardpoint_update

    matrix_update

    if ship_value != @ship_value
      @ship_value = ship_value
      klass = eval(@ship_value)
      @ship = klass.new(1, @max_width / 2, @y + klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY).height / 2, @max_width, @max_height, {use_large_image: true, hide_hardpoints: true})
      @ship_hardpoints = init_hardpoints(@ship)
    else
      # Do nothing
    end
    return @value
  end

  def get_hardpoints
    klass = eval(@ship_value)
    return {
      front: klass::FRONT_HARDPOINT_LOCATIONS,
      right: klass::RIGHT_BROADSIDE_HARDPOINT_LOCATIONS,
      left:  klass::LEFT_BROADSIDE_HARDPOINT_LOCATIONS
    }
  end

  def get_image
    klass = eval(@ship_value)
    return klass.get_right_broadside_image(klass::SHIP_MEDIA_DIRECTORY)
  end

  def get_large_image
    klass = eval(@ship_value)
    return klass.get_large_image(klass::SHIP_MEDIA_DIRECTORY)
  end

  # deprecated
  def clicked mx, my
    if is_mouse_hovering_next(mx, my)

    elsif is_mouse_hovering_prev(mx, my)

    end
  end

  def is_mouse_hovering_next mx, my
    local_width  = @font.text_width('>')
    local_height = @font.height

    (mx >= @next_x and my >= @y) and (mx <= @next_x + local_width) and (my <= @y + local_height)
  end

  def is_mouse_hovering_prev mx, my
    local_width  = @font.text_width('<')
    local_height = @font.height

    (mx >= @prev_x and my >= @y) and (mx <= @prev_x + local_width) and (my <= @y + local_height)
  end

  def draw

    if @cursor_object
      @cursor_object[:image].draw(@mouse_x, @mouse_y, @hardpoint_image_z)
    end

    hardpoint_draw

    matrix_draw

    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)

    @ship.draw
    @font.draw(@value, ((@max_width / 2) - @font.text_width(@value) / 2), @y, 1, 1.0, 1.0, 0xff_ffff00)
    @font.draw(">", @prev_x, @y, 1, 1.0, 1.0, 0xff_ffff00)
  end

end