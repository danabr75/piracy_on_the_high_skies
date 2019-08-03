# TRIGGER_PROCESS='true' ruby async_projectile_update_script.rb

require 'gosu'
require_relative '../models/projectiles/projectile.rb'
require 'json'
require 'oj'

class AsyncProjectileUpdateScript
  # def self.async_update data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results = {}
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  MAX_BYTE_LENGTH   = 65535
  LOGGER_FILE = "#{CURRENT_DIRECTORY}/../../proj_update_logger.txt"
  def self.async_update(stdin, stdout)
    file = File.open(LOGGER_FILE, "w")
    file.write("start - pid: #{Process.pid} \n")
    file.flush
    file.write("stdin #{stdin.inspect.to_s} \n")
    file.flush
    begin
      file.write("#{Time.now.to_s}\n")
      file.flush
      # file.write(Time.now.to_s)
      # file.flush
      # data = ENV['MARSHALLED_DATA']
      begin
        pid = ENV['PARENT_PID'].to_i
        while Process.getpgid(pid)
          file.write("PARENT IS ALIVE - #{pid} \n")
          file.flush
          file.write("#{STDIN.lineno}\n")
          file.flush
          begin
            while lines = stdin.read_nonblock(MAX_BYTE_LENGTH)
              file.write("GOT LINE: #{lines}\n")
              file.flush
              # next if line != ''
              # file.write("READLING LINE: #{line}\n")
              # file.flush
              # parsed_data = Oj.load(line)
              lines.split("\n").each do |line|
                parsed_data = JSON.parse(line)
                file.write("GOT parsed_data: #{parsed_data}\n")
                file.flush
                results = Projectiles::Projectile.async_update(parsed_data['data'], parsed_data['mouse_x'], parsed_data['mouse_y'], parsed_data['player_map_pixel_x'], parsed_data['player_map_pixel_y'])
                raise "BAD RESULTS" if results['current_map_pixel_x'].class == String
                file.write("RETURNING:\n")
                file.flush
                # file.write(Oj.dump(results)) 
                file.write( (results).to_json.to_s ) 
                file.flush
                # stdout.write(Oj.dump(results))
                file.write( "sending bakc data" ) 
                file.flush
                stdout.puts( (results).to_json )
                stdout.flush
              end
            end
          rescue IO::WaitReadable, EOFError
            # file.write("CLIENT IO BLOCK or EOFError\n")
            # file.flush
            IO.select([stdin])
            retry
          end
          file.write("GOT HERE1?\n")
          file.flush
        end
        file.write("GOT HERE2?\n")
        file.flush

      rescue Errno::ESRCH => e
        file.write("Error - parent is dead")
        file.write(e.message)
        file.flush
        file.close
        exit 0
      end
    rescue Exception => e
      file.flush
      file.write("ERROR-#{e.class}\n")
      file.flush
      file.write(e.message)
      file.flush
      file.write( e.backtrace.join("\n") )
      file.flush
      file.close
      exit 0
    end
    file.write("script finished?\n")
    file.flush
    file.close
  end
end

CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
file = File.open("#{CURRENT_DIRECTORY}/../../proj_update_logger2.txt", "w")
file.write("test\n")
file.flush
file.write(ENV['TRIGGER_PROCESS'].to_json)
file.flush
# begin
  if ENV['TRIGGER_PROCESS'] == 'true'
    file.write("\n GOT IT \n")
    file.flush
    AsyncProjectileUpdateScript.async_update(STDIN, STDOUT)# if ENV['TRIGGER_PROCESS'] == 'true'
    file.write("AFTER \n")
    file.flush
  end
  # AsyncProjectileUpdateScript.async_update# if ENV['TRIGGER_PROCESS'] == 'true'
# rescue Exception => e
#   file.write("Error \n")
#   file.write("#{e.message}\n")
#   file.flush
# end

file.close
# AsyncProjectileUpdateScript.async_update if __FILE__ == $0 || ENV['TRIGGER_PROCESS'] == 'true'


# Process.wait(popened_io.pid)