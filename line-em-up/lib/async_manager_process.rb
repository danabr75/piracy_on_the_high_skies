# TRIGGER_PROCESS='true' ruby async_projectile_update_script.rb

require 'gosu'
# This needs to come from the parent process.
# require_relative '../models/projectiles/projectile.rb'
require 'json'
require 'oj'
require 'parallel'
# require 'tempfile'


# require_relative 'util.rb'

# Rename, this is the generic subprocess class... or module.. make it a module.
class AsyncManagerProcess
  # def self.async_update data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results = {}
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  MAX_BYTE_LENGTH   = 65535
  LOGGER_FILE = "#{CURRENT_DIRECTORY}/../../proj_update_logger.txt"
  def self.async_update(stdin, stdout, parent_error_prefix, thread_type_klass_name, thread_type_full_path, async_method)
    debug = false
    # debug = true
    file = File.open(LOGGER_FILE, "w")
    file.write("start - pid: #{Process.pid} \n")
    file.flush
    file.write("stdin #{stdin.inspect.to_s} \n")
    file.flush
    # counter = 0
    # shut_down = false
    begin
      require thread_type_full_path
      thread_type_klass = eval(thread_type_klass_name)
      file.write("#{Time.now.to_s}\n") if debug
      file.flush if debug
      begin
          begin
            # If read_nonblock does hold.. need to send exit command? Need to send kill command in the read_non_block.
            while lines = stdin.read_nonblock(MAX_BYTE_LENGTH) # need to move this here,  and preceed, Process.getpgid(pid)
              Thread.new do
                lines.split("\n").each do |line|
                  parsed_data = Oj.load(line)
                  items = parsed_data[:data]
                  args  = parsed_data[:args]
                  results = []
                  # Maybe threading here? probably
                  items.each do |item|
                  # 48 max
                  # Parallel.each(items, in_threads: 2) do |item|
                    results << thread_type_klass.send(async_method, item, *args)
                  end
                  stdout.puts( Oj.dump(results) )
                  stdout.flush
                end
              end
            end
          rescue IO::WaitReadable, EOFError
            IO.select([stdin])
            retry
          end
          file.write("GOT HERE1?\n") if debug
          file.flush if debug
        end
        file.write("GOT HERE2?\n") if debug
        file.flush if debug
    rescue Exception => e
      stdout.flush
      stdout.puts("#{parent_error_prefix}#{e.class.name}:#{e.message.gsub("\n", '')}:end-of-error:pid-#{Process.pid}")
      stdout.flush

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
if ENV["TRIGGER_SUB_PROCESS_BY_PARENT_#{ENV['PARENT_PID']}"] == 'true'
  file = File.open("#{CURRENT_DIRECTORY}/../../proj_update_logger2.txt", "w")
  file.write("\n GOT IT \n")
  file.flush
  AsyncManagerProcess.async_update(STDIN, STDOUT, ENV['ERROR_PREFIX'], ENV['THREAD_TYPE_KLASS_NAME'], ENV['THREAD_TYPE_FULL_PATH'], ENV['ASYNC_METHOD'])# if ENV['TRIGGER_PROCESS'] == 'true'
  file.write("SHUT DOWN SUCCESSFULLY \n")
  file.flush
  file.close
end