# In Console: 
# mg = MapGenerator.new('desert_v2')
# mg.generate

class MapGenerator
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  MAP_DIRECTORY   = File.expand_path('../', __FILE__) + "/../maps"

  attr_accessor :map_height, :map_width, :terrain_image_path, :map_location

  def initialize map_save_name, map_height = 1000, map_width = 1000, terrain_image_paths = ["#{MEDIA_DIRECTORY}/earth_0.png", "#{MEDIA_DIRECTORY}/earth.png", "#{MEDIA_DIRECTORY}/earth_2.png"], out_of_bounds_terrain_path = "#{MEDIA_DIRECTORY}/earth_3.png"
    @screen_map_height         = map_height
    @screen_map_width          = map_width
    @map_location = "#{MAP_DIRECTORY}/#{map_save_name}.txt"
    @terrain_image_paths = terrain_image_paths
    @out_of_bounds_terrain_path = out_of_bounds_terrain_path
    @terrain_random_gen = @terrain_image_paths.length
    # @terrain_image = Gosu::Image.new(terrain_image_path, :tileable => true)
    @map_edge = 10
  end

  def generate
    # create_file_if_non_existent("#{MAP_DIRECTORY}/#{map_save_name}.txt")
    create_file_if_non_existent(@map_location)
    # File.open(file_location, 'a') do |f|
    #   f << "\n#{setting_name}: #{root_values.to_json};"
    # end

    height_rows = []
    (0..@screen_map_height - 1).each do |y|
      width_rows = []
      (0..@screen_map_width - 1).each do |x|
        if x == 0 || x == @screen_map_width - 1 || y == 0 || y == @screen_map_height - 1 
          height = 1 + rand
        else
          height = rand
        end
        width_rows << {height: height, terrain_index: rand(@terrain_random_gen), corner_heights: {}}
      end
      height_rows << width_rows
    end

    (-1..@screen_map_height - 1).each do |y_index|
      (-1..@screen_map_width - 1).each_with_index do |x_index|
        heights = []
        tile_num = 0

        bottom_right_tile, top_right_tile, top_left_tile, bottom_left_tile = [nil,nil,nil,nil]

        # Add TOP LEFT
        local_y_index = y_index
        local_x_index = x_index
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @screen_map_height - 1 && local_x_index <= @screen_map_width - 1
          top_left_tile = height_rows[local_y_index][local_x_index]
          heights << top_left_tile[:terrain_index]
          tile_num += 1
        end

        # Top Right
        local_y_index = y_index
        local_x_index = x_index + 1
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @screen_map_height - 1 && local_x_index <= @screen_map_width - 1
          top_right_tile = height_rows[local_y_index][local_x_index]
          heights << top_right_tile[:terrain_index]
          tile_num += 1
        end

        # Add Bottom LEFT
        local_y_index = y_index + 1
        local_x_index = x_index
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @screen_map_height - 1 && local_x_index <= @screen_map_width - 1
          bottom_left_tile = height_rows[local_y_index][local_x_index]
          heights << bottom_left_tile[:terrain_index]
          tile_num += 1
        end

        # Add Bottom RIGHT
        local_y_index = y_index + 1
        local_x_index = x_index + 1
        if local_y_index >= 0 && local_x_index >= 0 && local_y_index <= @screen_map_height - 1 && local_x_index <= @screen_map_width - 1
          bottom_right_tile = height_rows[local_y_index][local_x_index]
          heights << bottom_right_tile[:terrain_index]
          tile_num += 1
        end

        corner_height = heights.inject(:+) / tile_num.to_f

        top_left_tile[:corner_heights][:bottom_right] = corner_height if top_left_tile
        top_right_tile[:corner_heights][:bottom_left] = corner_height if top_right_tile
        bottom_left_tile[:corner_heights][:top_right] = corner_height if bottom_left_tile
        bottom_right_tile[:corner_heights][:top_left] = corner_height if bottom_right_tile
      end
    end

    data = {
      terrains: @terrain_image_paths, out_of_bounds_terrain_path: @out_of_bounds_terrain_path,
      map_width: @screen_map_width, map_height: @screen_map_height,
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