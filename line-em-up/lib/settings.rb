require 'fileutils'
module Settings
  RESOLUTIONS = ["640x480", "800x600", "960x720", "1024x768", "1280x960", "1400x1050", "1440x1080", "1600x1200", "1856x1392", "1920x1440", "2048x1536"]
  LIST_OF_SETTINGS = {
    resolution: {values: RESOLUTIONS, default_value: RESOLUTIONS[0]}
  }
  
  def self.set_setting file_location, setting_name, setting_value
    create_file_if_non_existent(file_location)
    if File.readlines(file_location).grep(/#{setting_name}:/).size > 0
      text = File.read(file_location)
      replace = text.gsub(/^#{setting_name}: ([^$]*)$/, setting_value)
      # replace = replace.gsub(/bbb/, "Replace bbb with 222")
      File.open(filepath, "w") {|file| file.puts replace}
    else
      File.open(file_location, 'a') do |f|
        f << "#{setting_name}: #{setting_value}"
      end
    end
  end

  def self.get_setting file_location, setting_name
    create_file_if_non_existent(file_location)
    test = File.readlines(file_location).select { |line| line =~ /$#{setting_name}: ([^$]*)$/ }
    puts "test2: #{test.inspect}"
    puts "test2 - #{test.nil?}"
    puts "test3 - #{test.inspect}"
    if test.nil? || test.count == 0
      puts "TEST NIL HERE"
      test = LIST_OF_SETTINGS[setting_name.to_sym][:default_value]
    end
    return test
  end

  def self.create_file_if_non_existent file_location
    if !File.exists?(file_location)
      FileUtils.touch(file_location)
    end
  end
end