class MapGenerator
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  MAP_DIRECTORY   = File.expand_path('../', __FILE__) + "/../maps"

  attr_accessor :map_height, :map_width, :terrain_image_path, :map_location

  def initialize map_save_name, map_height = 1000, map_width = 1000, terrain_image_paths = ["#{MEDIA_DIRECTORY}/earth.png", "#{MEDIA_DIRECTORY}/earth_2.png"]
    @map_height         = map_height
    @map_width          = map_width
    @map_location = "#{MAP_DIRECTORY}/#{map_save_name}.txt"
    @terrain_image_paths = terrain_image_paths
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
    (0..@map_height).each do |y|
      width_rows = []
      (0..@map_width).each do |x|
        if x < @map_edge || x + @map_edge > @map_width
          height = 3
        elsif y < @map_edge || y + @map_edge > @map_height
          height = 3
        else
          height  = rand
        end
        width_rows << {height: height, terrain_index: rand(2)}
      end
      height_rows << width_rows
    end
    data = {terrains: @terrain_image_paths, map_edge: @map_edge, map_width: @map_width, map_height: @map_height, data: height_rows}
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

end