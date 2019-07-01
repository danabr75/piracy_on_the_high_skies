# In Console: 
# mg = MapGenerator.new('desert_v9_small')
# mg.generate

class MapGenerator
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  MAP_DIRECTORY   = File.expand_path('../', __FILE__) + "/../maps"

  attr_accessor :map_tile_height, :map_tile_width, :terrain_image_path, :map_location

  def initialize map_save_name, map_tile_height = 250, map_tile_width = 250, terrain_image_paths = ["#{MEDIA_DIRECTORY}/earth.png"], out_of_bounds_terrain_path = "#{MEDIA_DIRECTORY}/earth_3.png"
    @map_tile_height         = map_tile_height
    @map_tile_width          = map_tile_width
    @map_location = "#{MAP_DIRECTORY}/#{map_save_name}.txt"
    @terrain_image_paths = terrain_image_paths
    @out_of_bounds_terrain_path = out_of_bounds_terrain_path
    @terrain_random_gen = @terrain_image_paths.length
    @water_path = "#{MEDIA_DIRECTORY}/water.png"
    @snow_path = "#{MEDIA_DIRECTORY}/snow.png"

    @terrain_image_paths << @water_path
    @water_index = @terrain_image_paths.count - 1

    @terrain_image_paths << @snow_path
    @snow_index = @terrain_image_paths.count - 1

    # @terrain_image = Gosu::Image.new(terrain_image_path, :tileable => true)
    @map_edge = 10

    @mountain_areas = [
      {x: 125, y: 130},
      {x: 121, y: 135},
      {x: 125, y: 125},
      {x: 125, y: 123},
      {x: 122, y: 121},
      {x: 121, y: 119},
      {x: 120, y: 117},
      {x: 119, y: 115}
    ]
  end

  def generate
    # create_file_if_non_existent("#{MAP_DIRECTORY}/#{map_save_name}.txt")
    create_file_if_non_existent(@map_location)
    # File.open(file_location, 'a') do |f|
    #   f << "\n#{setting_name}: #{root_values.to_json};"
    # end

    # IMPORTANT!!!!!! WHEN generating heights, must not be zero!!!!!!!!!!!!!!

    height_rows = []
    (0..@map_tile_height - 1).each do |y|
      width_rows = []
      (0..@map_tile_width - 1).each do |x|
        if x == 0 || x == @map_tile_width - 1 || y == 0 || y == @map_tile_height - 1 
          height = 2 + rand
        else
          height = rand + rand + rand + rand(2) - 1.0
        end
        height = 0.1 if height < 0.1
        height = 3.0 if height > 3.0
        width_rows << {height: height, terrain_index: rand(@terrain_random_gen), corner_heights: {}, terrain_paths_and_weights: {}}
      end
      height_rows << width_rows
    end

    @mountain_areas.each do |mountain|
      height_rows[mountain[:y]][mountain[:x]][:terrain_index] = @snow_index
      height_rows[mountain[:y]][mountain[:x]][:height]        = 3


      height_rows[mountain[:y] - 1][mountain[:x] - 1][:terrain_index] = @snow_index
      height_rows[mountain[:y] - 1][mountain[:x] - 1][:height]        = 2.5
      height_rows[mountain[:y] + 1][mountain[:x] + 1][:terrain_index] = @snow_index
      height_rows[mountain[:y] + 1][mountain[:x] + 1][:height]        = 2.5
      height_rows[mountain[:y] + 1][mountain[:x] - 1][:height]        = 2.5
      height_rows[mountain[:y] - 1][mountain[:x] + 1][:height]        = 2.5
    end


    snow_height = 0
    snow_width  = 0
    while snow_width < @map_tile_width
      height_rows[snow_height][snow_width][:terrain_index] = @snow_index
      height_rows[snow_height][snow_width][:height]        = 3
      if snow_height == 0
        # Go EAST OR SOUTH
        value = rand(2)
        if value == 0
          snow_width += 1
        else
          snow_height += 1
          snow_width  += 1
        end
      elsif snow_height == @map_tile_height
        # GO EAST or GO NORTH
        value = rand(2)
        if value == 0
          snow_width += 1
        else
          snow_height -= 1
          snow_width  += 1
        end
      else
        # GO EAST NORTH OR SOUTH
        value = rand(3)
        if value == 0
          snow_height += 1
          snow_width += 1
        elsif value == 1
          snow_height -= 1
          snow_width  += 1
        else
          snow_height += 1
          snow_width  += 1
        end
      end
    end

    water_height = @map_tile_height / 2
    water_width  = 0
    while water_width < @map_tile_width
      height_rows[water_height][water_width][:terrain_index] = @water_index
      height_rows[water_height][water_width][:height]        = 0.1
      if water_height == 0
        # Go EAST OR SOUTH
        value = rand(2)
        if value == 0
          water_width += 1
        else
          water_height += 1
          water_width  += 1
        end
      elsif water_height == @map_tile_height
        # GO EAST or GO NORTH
        value = rand(2)
        if value == 0
          water_width += 1
        else
          water_height -= 1
          water_width  += 1
        end
      else
        # GO EAST NORTH OR SOUTH
        value = rand(3)
        if value == 0
          water_width += 1
        elsif value == 1
          water_height -= 1
          water_width  += 1
        else
          water_height += 1
          water_width  += 1
        end
      end
    end


    (-1..@map_tile_height - 1).each do |y_index|
      (-1..@map_tile_width - 1).each_with_index do |x_index|
        heights       = []
        terrain_paths = []
        tile_num = 0

        bottom_right_tile, top_right_tile, top_left_tile, bottom_left_tile = [nil,nil,nil,nil]

        # Add TOP LEFT
        local_y_index = y_index
        local_x_index = x_index
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @map_tile_height - 1 && local_x_index <= @map_tile_width - 1
          top_left_tile = height_rows[local_y_index][local_x_index]
          # heights << top_left_tile[:terrain_index]
          heights       << top_left_tile[:height]
          terrain_paths << top_left_tile[:terrain_index]
          top_left_tile
          tile_num += 1
        end

        # Top Right
        local_y_index = y_index
        local_x_index = x_index + 1
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @map_tile_height - 1 && local_x_index <= @map_tile_width - 1
          top_right_tile = height_rows[local_y_index][local_x_index]
          heights       << top_right_tile[:height]
          terrain_paths << top_right_tile[:terrain_index]
          tile_num += 1
        end

        # Add Bottom LEFT
        local_y_index = y_index + 1
        local_x_index = x_index
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @map_tile_height - 1 && local_x_index <= @map_tile_width - 1
          bottom_left_tile = height_rows[local_y_index][local_x_index]
          heights       << bottom_left_tile[:height]
          terrain_paths << bottom_left_tile[:terrain_index]
          tile_num += 1
        end

        # Add Bottom RIGHT
        local_y_index = y_index + 1
        local_x_index = x_index + 1
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @map_tile_height - 1 && local_x_index <= @map_tile_width - 1
          bottom_right_tile = height_rows[local_y_index][local_x_index]
          heights       << bottom_right_tile[:height]
          terrain_paths << bottom_right_tile[:terrain_index]
          tile_num += 1
        end

        corner_height = heights.inject(:+) / tile_num.to_f

        top_left_tile[:corner_heights][:bottom_right] = corner_height if top_left_tile
        top_right_tile[:corner_heights][:bottom_left] = corner_height if top_right_tile
        bottom_left_tile[:corner_heights][:top_right] = corner_height if bottom_left_tile
        bottom_right_tile[:corner_heights][:top_left] = corner_height if bottom_right_tile

        # puts top_right_tile

        top_left_tile[:terrain_paths_and_weights][:bottom_right] = {} if top_left_tile
        top_right_tile[:terrain_paths_and_weights][:bottom_left] = {} if top_right_tile
        bottom_left_tile[:terrain_paths_and_weights][:top_right] = {} if bottom_left_tile
        bottom_right_tile[:terrain_paths_and_weights][:top_left] = {} if bottom_right_tile

        tile_count = 0
        [top_left_tile, top_right_tile, bottom_left_tile, bottom_right_tile].each do |tile|
          tile_count += 1
        end
        weight_increment = 1 / tile_count.to_f


        terrain_paths.each do |terrain_indexes|
          [
            {tile: top_left_tile, direction: :bottom_right},
            {tile: top_right_tile, direction: :bottom_left},
            {tile: bottom_left_tile, direction: :top_right},
            {tile: bottom_right_tile, direction: :top_left}
          ].each do |tile_values|
            tile      = tile_values[:tile]
            direction = tile_values[:direction]
            next if tile.nil?

            if tile
              tile[:terrain_paths_and_weights][direction][terrain_indexes] ||= 0.0
              tile[:terrain_paths_and_weights][direction][terrain_indexes] += weight_increment
            end
          end
        end

      end
    end

    puts "@terrain_image_paths: #{@terrain_image_paths}"

    data = {
      terrains: @terrain_image_paths, out_of_bounds_terrain_path: @out_of_bounds_terrain_path,
      map_tile_width: @map_tile_width, map_tile_height: @map_tile_height,
      data: height_rows
    }
    File.open(@map_location, 'w') do |f|
      f << data.to_json
    end
  end

  def read_data
    data = JSON.parse(File.readlines(@map_location).first)
    return data
  end

  def create_file_if_non_existent file_location
    # puts "CREATING FILE AT LOCATION: #{file_location}"
    if !File.exists?(file_location)
      FileUtils.touch(file_location)
    end
  end

  # def get_surrounding_average_tile_height x_index, y_index



  # end

end