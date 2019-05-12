require 'fileutils'
require 'json'
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
    if (test == [] || test.nil? || test == '')
      test = default_value
    end
    return test ? test.gsub(';', '') : test
  end

  def self.set_mapped_setting file_location, setting_names, setting_value
    puts "set_mapped_setting".upcase
    puts setting_names
    puts setting_value
    create_file_if_non_existent(file_location)
    if setting_names.any?
      # File.open('xxx.txt').each do |line|
      #   print "#{line_num += 1} #{line}"
      # end
      setting_name = setting_names.shift
      text = (File.readlines(file_location).select { |line| line =~ /^#{setting_name}: ([^;]*);$/ }).first
      if text
        puts "FOUND TEXT"
        puts text
        text = text.scan(/^#{setting_name}: ([^;]*);$/).first
        text = text.first if text
        data = ::JSON.parse(text)
        indexing_values = data
        # puts "FOUND IT"
        # text = File.read(file_location)
        # data = JSON.parse(text.sub(/;$/, '')).with_indifferent_access
        # indexer = setting_names.shift
        # while setting_names.any?
        #   data = data[indexer]
        #   indexer = setting_names.shift
        # end
        # puts 'GOT DATA HERE'
        # puts data.inspect
        # data[indexer] = setting_value

        indexer = setting_names.shift
        while indexer
          puts "indexing_values: #{indexing_values}"
          puts "INDEXER - #{indexer}"
          if setting_names.count == 0
            indexing_values[indexer] = setting_value
          else
            if indexing_values[indexer]
              indexing_values = indexing_values[indexer]
            else 
              indexing_values[indexer] = {}
              indexing_values = indexing_values[indexer]
            end
            # indexing_values ||= {}
          end
          # puts data
          indexer = setting_names.shift
          indexer = indexer.to_s if indexer
        end
        puts 'PUTTING IN DATA: '
        puts data
        puts "SUBBING IN SETTING NAME: #{setting_name}"
        puts "WITH"
        puts "#{setting_name}: #{data.to_json};"
        full_text = File.read(file_location)
        File.open(file_location, 'w+'){|f| f << full_text.sub(/^#{setting_name}: ([^;]*);$/, "#{setting_name}: #{data.to_json};") }
        return data

        # File.open(file_location, 'w+'){|f| f << text.sub(/^#{setting_name}: ([^;]*);$/, "#{setting_name}: #{setting_value};") }
      else
        puts "DIDIT FIND IT- setting_name: #{setting_name}"
        root_values = {}
        values = root_values
        indexer = setting_names.shift
        while setting_names.any?
          values[indexer] ||= {}
          values = values[indexer]
          indexer = setting_names.shift
          indexer = indexer.to_s if indexer
        end
        values[indexer] = setting_value

        # {"front_hardpoint_locations":{},"1":"launcher"}

        File.open(file_location, 'a') do |f|
          f << "\n#{setting_name}: #{root_values.to_json};"
        end
      end

      # setting_name = setting_names.shift
      # test = File.readlines(file_location).select { |line| line =~ /^#{setting_name}: ([^;]*);$/ }
      # puts "TEST HERE"
      # puts test.inspect
      # data = JSON.parse(test)
      # puts "DATA"
      # puts data
      # data = data.with_indifferent_access
      # indexer = setting_names.shift
      # while setting_names.any?
      #   data = data[indexer]
      #   indexer = setting_names.shift
      # end
      # puts "FOUND DATA: #{data}"
    end
  end

  def self.get_mapped_setting file_location, setting_names = [], default_value = nil
    create_file_if_non_existent(file_location)
    setting_name = setting_names.shift
    text = (File.readlines(file_location).select { |line| line =~ /^#{setting_name}: ([^;]*);$/ }).first
    puts "TEST HERE"
    puts text.inspect
    if text
      text = text.scan(/^#{setting_name}: ([^;]*);$/).first
      text = text.first if text
      data = ::JSON.parse(text)
      # data = data.with_indifferent_access
      indexer = setting_names.shift
      while indexer && data
        puts "DATA index"
        data = data[indexer]
        puts data
        indexer = setting_names.shift
        indexer = indexer.to_s if indexer
      end
      puts "FOUND DATA: #{data}"
      return data
    else
      return default_value
    end
  end

  def self.create_file_if_non_existent file_location
    # puts "CREATING FILE AT LOCATION: #{file_location}"
    if !File.exists?(file_location)
      FileUtils.touch(file_location)
    end
  end
end