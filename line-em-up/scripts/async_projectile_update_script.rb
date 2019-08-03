# TRIGGER_PROCESS='true' ruby async_projectile_update_script.rb

require 'gosu'
require_relative '../models/projectiles/projectile.rb'
require 'json'
require 'oj'


require_relative '../lib/util.rb'

class AsyncProjectileUpdateScript
  # def self.async_update data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results = {}
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  MAX_BYTE_LENGTH   = 65535
  LOGGER_FILE = "#{CURRENT_DIRECTORY}/../../proj_update_logger.txt"
  def self.async_update(stdin, stdout)
    debug = false
    file = File.open(LOGGER_FILE, "w")
    file.write("start - pid: #{Process.pid} \n")
    file.flush
    file.write("stdin #{stdin.inspect.to_s} \n")
    file.flush
    # shut_down = false
    begin
      file.write("#{Time.now.to_s}\n") if debug
      file.flush if debug
      begin
        pid = ENV['PARENT_PID'].to_i
        while Process.getpgid(pid)
          file.write("PARENT IS ALIVE - #{pid} \n") if debug
          file.flush if debug
          file.write("#{STDIN.lineno}\n") if debug
          file.flush if debug
          begin
            # If read_nonblock does hold.. need to send exit command? Need to send kill command in the read_non_block.
            while lines = stdin.read_nonblock(MAX_BYTE_LENGTH) # need to move this here,  and preceed, Process.getpgid(pid)
              file.write("GOT LINES: #{lines}\n") if debug
              file.flush if debug
              # next if line != ''
              # file.write("READLING LINE: #{line}\n")
              # file.flush
              # parsed_data = Oj.load(line)
              lines.split("\n").each do |line|
                file.write("GOT LINE: #{line}\n") if debug
                file.flush if debug
                file.write("GOT CLASS: #{line.class}\n") if debug
                file.flush if debug
                parsed_data = Oj.load(line)
                parsed_data = Util.stringify_all_keys(parsed_data)
                # parsed_data = JSON.parse(line)
                file.write("GOT parsed_data: #{parsed_data}\n") if debug
                file.flush if debug
                results = Projectiles::Projectile.async_update(parsed_data['data'], parsed_data['mouse_x'], parsed_data['mouse_y'], parsed_data['player_map_pixel_x'], parsed_data['player_map_pixel_y'])
                if results['current_map_pixel_x'].class == String
                  file.write("BAD RESULTS:\n")
                  file.flush
                  raise "BAD RESULTS"
                end
                file.write("RETURNING:\n") if debug
                file.flush if debug
                file.write(Oj.dump(results).to_s)  if debug
                # file.write( (results).to_json.to_s ) 
                file.flush if debug
                # stdout.write(Oj.dump(results))
                file.write( "sending bakc data" )  if debug
                file.flush if debug
                stdout.puts( Oj.dump(results) )
                # stdout.puts( (results).to_json )
                stdout.flush
              end
            end
          rescue IO::WaitReadable, EOFError
            # file.write("CLIENT IO BLOCK or EOFError\n")
            # file.flush
            IO.select([stdin])
            retry
          end
          file.write("GOT HERE1?\n") if debug
          file.flush if debug
        end
        file.write("GOT HERE2?\n") if debug
        file.flush if debug

      rescue Errno::ESRCH => e
        file.write("Error - parent is dead")
        file.write(e.message)
        file.flush
        file.close
        exit 0
      end
    rescue Exception => e
      file.flush
      file.write("ERROR-#{e.class}-#{e.message}\n")
      file.flush
      file.write("#{e.message}\n")
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