# require 'concurrent'
require 'parallel'
# require 'ruby-progressbar'
# require 'time'
# require 'benchmark/ips'
# require 'open3'
require 'oj'

# TEMP
require_relative 'projectiles/projectile.rb'

require "thwait"

class AsyncProcessManager
  MAX_BYTE_LENGTH   = 65535

  ERROR_PREFIX                        = 'ERROR_FOUND_ON_SUB_PROCESS_'
  SUB_PROCESS_ENCOUNTER_ERROR_PATTERN = /#{ERROR_PREFIX}([^\n]*)/

  def initialize thread_type_klass, threads_or_processor_count, list_is_hash = false, use_type = :threads #, :processes, :none
    @thread_type_klass = thread_type_klass
    @thread_type_klass_name = thread_type_klass.name
    @debug = false
    # @processor_count = 2
    @threads_or_processor_count = threads_or_processor_count
    @list_is_hash = list_is_hash
    @use_processes = use_type == :processes
    @test_use_processes = use_type == :test_processes
    @use_threads   = use_type == :threads
    @use_joined_threads   = use_type == :joined_threads
    @use_nothing   = use_type == :none
    Thread.abort_on_exception = true

    @pids = []
    if @use_processes
      @parent_write_current_pipe = 0
      @parent_write_pipes = []
      @processors_count = 30
      # @processors_count_indexed_at_zero = @processors_count - 1
      # @parent_read, @parent_write = IO.pipe
      # Try to share out child_read pipe
      @child_read, child_write = IO.pipe
      # puts "parents here:"
      # puts @parent_read.inspect
      # puts @parent_write.inspect
      # @child_read, @child_write = IO.pipe

      @processors_count.times do
        parent_read, parent_write = IO.pipe
        @parent_write_pipes << parent_write
        # pids << Process.spawn({"MARSHALLED_DATA" => item.get_data.to_json, "ARGS" => args.to_json }, RbConfig.ruby, "#{SCRIPT_DIRECTORY}/async_projectile_update_script.rb", :out => w, :err => [:child, :out])S
        # How to find the PIDs of zombies.
        # ps aux | grep ruby-2 | grep -v grep | awk '{print $2}'
        # kill -9 ...
        @pids << Process.spawn({"ERROR_PREFIX" => ERROR_PREFIX, "PARENT_PID" => Process.pid.to_s, "TRIGGER_SUB_PROCESS_BY_PARENT_#{Process.pid}" => 'true'}, RbConfig.ruby, "#{SCRIPT_DIRECTORY}/async_projectile_update_script.rb", :in => parent_read, :out => child_write, :err => [:child, :out])
      end
    end

  end

  def exit_hooks
    # Should probably send exit code and let the subprocess shut down itself, but this works too.
    @pids.each do |pid|
      Process.kill("SIGALRM", pid)
    end
  end

  def parent_write_get_pipe
    @parent_write_current_pipe += 1
    if @parent_write_current_pipe == @processors_count
      @parent_write_current_pipe = 0
    end
    # puts "Current pipe: #{@parent_write_current_pipe} - Total Pipe count: #{@parent_write_pipes.count} && @processors_count: #{@processors_count}"
    # puts "2Current pipe: #{@parent_write_current_pipe.class} - Total Pipe count: #{@parent_write_pipes.count.class} && @processors_count: #{@processors_count.class}"
    @parent_write_pipes[@parent_write_current_pipe]
  end
  


  def update window, items, *args
    items_count = items.count
    if @use_nothing
      if @list_is_hash
        items.each do |key, item|
          @thread_type_klass.update(window, item, args)
        end
      else
        items.each do |item|
          @thread_type_klass.update(window, item, args)
        end
      end
    end

    if @use_joined_threads
      # Thread.new do
        if @list_is_hash
          Parallel.each(items, in_threads: @threads_or_processor_count) do |key, item|
            @thread_type_klass.update(window, item, args)
          end
        else
          Parallel.each(items, in_threads: @threads_or_processor_count) do |item|
            @thread_type_klass.update(window, item, args)
          end
        end
      # end
    end

    if @use_threads
      Thread.new do
        if @list_is_hash
          Parallel.each(items, in_threads: @threads_or_processor_count) do |key, item|
            @thread_type_klass.update(window, item, args)
          end
        else
          Parallel.each(items, in_threads: @threads_or_processor_count) do |item|
            @thread_type_klass.update(window, item, args)
          end
        end
      end
    end

    if @test_use_processes
      final_data = []
      # parameter_threads = []
      t = Thread.new do
        items.each do |key, item|
          # puts "item.get_data"
          # puts item.get_data.inspect

          # Process.spawn({"MARSHALLED_DATA" => item.get_data.to_json, "ARGS" => args.to_json }, RbConfig.ruby, "#{SCRIPT_DIRECTORY}/async_projectile_update_script.rb", :out => w, :err => [:child, :out])
          result = Projectiles::Projectile.async_update(Util.stringify_all_keys(item.get_data), args[0], args[1], args[2], args[3])
          final_data << result
        end
        Thread.exit
      end

      t.join

      t = Thread.new do
        final_data.each do |f_data|
          items[f_data['id']].set_data(f_data)
          window.remove_projectile_ids.push(f_data['id']) if !items[f_data['id']].is_alive
        end
      end

      t.join
    end

    # Marshal.load
    # Just don't work.. SLOW FPS, projectiles aren't being updated.
    if @use_processes
      begin
        final_data = []


        # if @debug
          outer_pid = nil
          begin
            @pids.each do |pid|
              outer_pid = pid
              Process.getpgid(pid)
            end
          rescue Errno::ESRCH => e
            raise "Error - sub process is dead: #{outer_pid}"
          end
        # end


        # parameter_threads = []
        t = Thread.new do
          items.each do |key, item|
            # Process.spawn({"MARSHALLED_DATA" => item.get_data.to_json, "ARGS" => args.to_json }, RbConfig.ruby, "#{SCRIPT_DIRECTORY}/async_projectile_update_script.rb", :out => w, :err => [:child, :out])
            # @child_read, @child_write = IO.pipe
            # @parent_read, @parent_write = IO.pipe
            # @parent_write.write( ({'data' => item.get_data, 'mouse_x' => args[0], 'mouse_y' => args[1], 'player_map_pixel_x' => args[2], 'player_map_pixel_y' => args[3]}).to_json )
            # @parent_write.puts( ({'data' => item.get_data, 'mouse_x' => args[0], 'mouse_y' => args[1], 'player_map_pixel_x' => args[2], 'player_map_pixel_y' => args[3]}).to_json )
            # @parent_write.puts( Oj.dump({'data' => item.get_data, 'mouse_x' => args[0], 'mouse_y' => args[1], 'player_map_pixel_x' => args[2], 'player_map_pixel_y' => args[3]}) )
            write_pipe = parent_write_get_pipe
            write_pipe.puts( Oj.dump({'data' => item.get_data, 'mouse_x' => args[0], 'mouse_y' => args[1], 'player_map_pixel_x' => args[2], 'player_map_pixel_y' => args[3]}) )
            write_pipe.flush
          end
          while final_data.count < items_count
            puts "WAITING FOR COUNT #{final_data.count} < #{items_count}" if @debug
            begin
              puts "BEGINNING AGAIN" if @debug
              while final_data.count < items_count && lines = @child_read.read_nonblock(MAX_BYTE_LENGTH)
                puts lines.inspect if @debug
                puts "REALING LINES IF ANY - #{lines}" if @debug
                lines.split("\n").each do |line|
                  puts "READING LINE" if @debug
                  puts line.inspect if @debug
                  # REMOVE THIS SECTION IF string matching takes too long to process.
                  # if true #@debug
                    if line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)
                      error_data = line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)[1]
                      puts "FOUND ERROR DATA"
                      puts error_data.inspect
                      exit_hooks
                      raise "Encountered error on #{@thread_type_klass_name} with #{error_data}"
                    end
                  # end
                  data = Oj.load(line)
                  # data = JSON.parse(line)
                  final_data << data
                end
              end
            rescue IO::WaitReadable
              puts "SERVER IO WAITING" if @debug
              IO.select([@child_read])
              retry
            end
          end

          Thread.exit
        end
        t.join

        if items_count > 0
          puts 'PROCESS ENDED' if @debug
          puts "items_count < final_data.count: #{items_count} < #{final_data.count}" if @debug
          puts final_data.join(', ') if @debug
        end

        t = Thread.new do
          final_data.each do |f_data|
            items[f_data[:id]].set_data(f_data)
            window.remove_projectile_ids.push(f_data[:id]) if !items[f_data[:id]].is_alive
          end
        end

        t.join
      rescue Exception => e
        # kill sub processes if anything goes wrong
        exit_hooks
        raise
      end
    end

  end
end