require 'fileutils'

module ConfigSetting
  def self.set_setting file_location, setting_name, setting_value
    # puts "HERE: #{file_location} and #{setting_name} and #{setting_value}"
    create_file_if_non_existent(file_location)
    if setting_value
      # File.open('xxx.txt').each do |line|
      #   print "#{line_num += 1} #{line}"
      # end
      if File.readlines(file_location).grep(/#{setting_name}:/).size > 0
        text = File.read(file_location)
        puts "READ TEXT IN FILE: #{text}"
        File.open(file_location, 'w+'){|f| f << text.sub(/^#{setting_name}: ([^;]*);$/, "#{setting_name}: #{setting_value};") }
      else
        File.open(file_location, 'a') do |f|
          f << "\n#{setting_name}: #{setting_value};"
        end
      end

      # if File.readlines(file_location).grep(/#{setting_name}:/).size > 0
      #   # puts "FOUND SETTING"
      #   text = File.read(file_location)
      #   # puts "FOUDN IN FILE: #{text.inspect}"
      #   replace = text.gsub(/^#{setting_name}: ([^$]*)$/, setting_value)
      #   # replace = replace.gsub(/bbb/, "Replace bbb with 222")
      #   File.open(file_location, "w") {|file| file.puts "#{setting_name}: #{replace}"}
      # else
      #   # puts "COULDNT FIND SETTING"
      #   File.open(file_location, 'a') do |f|
      #     f << "#{setting_name}: #{setting_value}"
      #   end
      # end
    end
  end

  def self.get_setting file_location, setting_name, default_value = nil
    create_file_if_non_existent(file_location)
    test = File.readlines(file_location).select { |line| line =~ /^#{setting_name}: ([^;]*);$/ }
    if test && test.first
      # puts "BEFORE SCAN: #{test}"
      # So many firstsss
      test = test.first.scan(/^#{setting_name}: ([^$]*)$/).first
      if test
        test = test.first
      end
      test = test.strip
    end
    # test = nil
    # if File.readlines(file_location).grep(/#{setting_name}:/).size > 0
    #   test = 
    # end
    # puts "GETTING TEST: #{test}"
    # puts "test2: #{test.inspect}"
    # puts "test2 - #{test.nil?}"
    # puts "test3 - #{test.inspect}"
    # if test.nil? #|| test.count == 0
    #   # puts "TEST NIL HERE"
    #   test = default_value
    # end
    if (test == [] || test.nil? || test == '')
      test = default_value
    end
    return test.gsub(';', '')
  end

  def self.create_file_if_non_existent file_location
    # puts "CREATING FILE AT LOCATION: #{file_location}"
    if !File.exists?(file_location)
      FileUtils.touch(file_location)
    end
  end
end