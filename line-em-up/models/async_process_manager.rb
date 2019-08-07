# KILL ASYNC SUB ZOMBIES
# ps aux | grep ruby-2 | grep -v grep | awk '{print $2}'
# kill -9 `ps aux | grep ruby-2 | grep -v grep | awk '{print $2}'`

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
  ROUGH_ESTIMATE_OF_PROJ_DATA = 1310

  ERROR_PREFIX                        = 'ERROR_FOUND_ON_SUB_PROCESS_'
  SUB_PROCESS_ENCOUNTER_ERROR_PATTERN = /#{ERROR_PREFIX}([^\n]*)/

  def initialize thread_type_klass, threads_or_processor_count, list_is_hash = false, use_type = :threads, async_method = nil, gather_data_method = nil, setter_data_method = nil, thread_type_full_path = nil #, :processes, :none
    @thread_type_full_path = thread_type_full_path
    @async_method = async_method
    @gather_data_method = gather_data_method
    @setter_data_method = setter_data_method
    @thread_type_klass = thread_type_klass
    @thread_type_klass_name = thread_type_klass.name
    @debug = false
    # @processor_count = 2
    @threads_or_processor_count = threads_or_processor_count
    @list_is_hash = list_is_hash
    @use_nothing_test = use_type == :none_test
    @use_processes = use_type == :processes
    @process_manager = use_type == :process_manager
    @test_use_processes = use_type == :test_processes
    @use_threads   = use_type == :threads
    @use_joined_threads   = use_type == :joined_threads
    @use_nothing   = use_type == :none
    Thread.abort_on_exception = true

    @exiting = false

    @pids = []

    if @process_manager
      # keep it at 1 for now
      @threads_or_processor_count = 1
      @parent_write_current_pipe = 0
      @parent_write_pipes = []
      @child_read, child_write = IO.pipe

      raise "INVALID INPUT" if @thread_type_klass.nil? || @thread_type_full_path.nil? || @gather_data_method.nil?

      @threads_or_processor_count.times do
        parent_read, parent_write = IO.pipe
        @parent_write_pipes << parent_write
        @pids << Process.spawn(
          {
            "ERROR_PREFIX" => ERROR_PREFIX,
            "PARENT_PID" => Process.pid.to_s,
            "TRIGGER_SUB_PROCESS_BY_PARENT_#{Process.pid}" => 'true',
            "THREAD_TYPE_KLASS_NAME" => @thread_type_klass.name,
            "THREAD_TYPE_FULL_PATH" => @thread_type_full_path,
            "ASYNC_METHOD" => @async_method.to_s
          },
          RbConfig.ruby, "#{LIB_DIRECTORY}/async_manager_process.rb", :in => parent_read, :out => child_write, :err => [:child, :out])
      end
    end

    if @use_processes
      @parent_write_current_pipe = 0
      @parent_write_pipes = []
      @child_read, child_write = IO.pipe

      raise "INVALID INPUT" if @thread_type_klass.nil? || @thread_type_full_path.nil? || @gather_data_method.nil?

      @threads_or_processor_count.times do
        parent_read, parent_write = IO.pipe
        @parent_write_pipes << parent_write
        @pids << Process.spawn(
          {
            "ERROR_PREFIX" => ERROR_PREFIX,
            "PARENT_PID" => Process.pid.to_s,
            "TRIGGER_SUB_PROCESS_BY_PARENT_#{Process.pid}" => 'true',
            "THREAD_TYPE_KLASS_NAME" => @thread_type_klass.name,
            "THREAD_TYPE_FULL_PATH" => @thread_type_full_path,
            "ASYNC_METHOD" => @async_method.to_s
          },
          RbConfig.ruby, "#{LIB_DIRECTORY}/async_sub_process.rb", :in => parent_read, :out => child_write, :err => [:child, :out])
      end
    end

  end

  def exit_hooks
    @exiting = true
    # Should probably send exit code and let the subprocess shut down itself, but this works too.
    @pids.each do |pid|
      puts "killing pids: #{pid}"
      Process.kill("SIGALRM", pid)
    end
  end

  def parent_write_get_pipe
    @parent_write_current_pipe += 1
    if @parent_write_current_pipe == @threads_or_processor_count
      @parent_write_current_pipe = 0
    end
    # puts "Current pipe: #{@parent_write_current_pipe} - Total Pipe count: #{@parent_write_pipes.count} && @processors_count: #{@processors_count}"
    # puts "2Current pipe: #{@parent_write_current_pipe.class} - Total Pipe count: #{@parent_write_pipes.count.class} && @processors_count: #{@processors_count.class}"
    @parent_write_pipes[@parent_write_current_pipe]
  end
  


  def update window, items, *args
    outer_pid = nil
    begin
      @pids.each do |pid|
        outer_pid = pid
        Process.getpgid(pid)
      end
    rescue Errno::ESRCH => e
      raise "Error - sub process is dead: #{outer_pid}"
    end

    items_count = items.count
    pid = nil

    # specifically for projectiles
    if @use_nothing_test
      items.each do |key, item|
        item.update(*args)
        window.remove_projectile_ids.push(item.id) if !item.is_alive
      end
    end

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
      pid = Thread.new do
        if @list_is_hash
          items.each do |key, item|
          # Parallel.each(items, in_threads: @threads_or_processor_count) do |key, item|
            @thread_type_klass.update(window, item, args)
          end
        else
          items.each do |item|
          # Parallel.each(items, in_threads: @threads_or_processor_count) do |item|
            @thread_type_klass.update(window, item, args)
          end
        end
        Thread.exit
      end
    end

    if @use_threads
      Thread.new do
        if @list_is_hash
          items.each do |key, item|
          # Parallel.each(items, in_threads: @threads_or_processor_count) do |key, item|
            @thread_type_klass.update(window, item, args)
          end
        else
          items.each do |item|
          # Parallel.each(items, in_threads: @threads_or_processor_count) do |item|
            @thread_type_klass.update(window, item, args)
          end
        end
        Thread.exit
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

    if @process_manager
      pid = Thread.new do
        begin
          # only sending 1 block
          raw_final_data = []

          sending_data = []
          items.each do |key, item|
            sending_data << item.send(@gather_data_method)
          end

          write_pipe = parent_write_get_pipe
          write_pipe.puts( Oj.dump({data: sending_data, args: args}) )
          write_pipe.flush

          begin
            lines = @child_read.read_nonblock(MAX_BYTE_LENGTH)
            lines.split("\n").each do |line|
              # REMOVE THIS SECTION IF string matching takes too long to process.
              if line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)
                if !@exiting # don't care about errors if shutting down.
                  error_data = line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)[1]
                  puts "RIGHT HERE ERROR: #{error_data}"
                  exit_hooks
                  raise "Encountered error on #{@thread_type_klass_name} with #{error_data}"
                end
              end
              raw_final_data << line
            end
            # Thread.exit
          rescue IO::WaitReadable
            IO.select([@child_read])
            # Thread.pass
            retry
          end

          raw_final_data.each do |raw_data|
            items_data = Oj.load(raw_data)
            items_data.each do |item_data|
              items[item_data[:id]].set_data(item_data)
              window.remove_projectile_ids.push(item_data[:id]) if !items[item_data[:id]].is_alive
            end
          end

        rescue Exception => e
          # kill sub processes if anything goes wrong
          if !@exiting
            exit_hooks
            raise
          end
        end
        Thread.exit
      end
    end

    # Marshal.load
    # Just don't work.. SLOW FPS, projectiles aren't being updated.
    # Only have hashes implemented currently.
    if @use_processes #54
      pid = Thread.new do
        begin
          final_data = []
          raw_final_data = []
          final_data_count = 0

          t1 = Thread.new do
            items.each do |key, item|
            # Parallel.each(items, in_threads: 8) do |key, item|
              write_pipe = parent_write_get_pipe
              write_pipe.puts(
                Oj.dump(
                  {
                    'data' => item.send(@gather_data_method),
                    'args' => args
                  }
                )
              )
              write_pipe.flush
            end
            Thread.exit
          end
          t1.join

          # Thread.pass

          t2 = Thread.new do
            begin
              while final_data_count < items_count && lines = @child_read.read_nonblock(MAX_BYTE_LENGTH)
                # puts "final_data_count against item count: #{final_data_count} < #{items_count}"
                # puts "lines: #{lines}"
                  lines.split("\n").each do |line|
                    # REMOVE THIS SECTION IF string matching takes too long to process.
                    if line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)
                      if !@exiting # don't care about errors if shutting down.
                        error_data = line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)[1]
                        puts "RIGHT HERE ERROR: #{error_data}"
                        exit_hooks
                        raise "Encountered error on #{@thread_type_klass_name} with #{error_data}"
                      end
                    end
                    final_data_count += 1
                    raw_final_data << line
                    # final_data << Oj.load(line)
                  end
              end
            rescue IO::WaitReadable
              IO.select([@child_read])
              retry
            end
            Thread.exit
          end
          t2.join

          t3 = Thread.new do
            raw_final_data.each do |raw_f_data|
              f_data = Oj.load(raw_f_data)
              items[f_data[:id]].set_data(f_data)
              window.remove_projectile_ids.push(f_data[:id]) if !items[f_data[:id]].is_alive
            end
            Thread.exit
          end
          t3.join
        rescue Exception => e
          # kill sub processes if anything goes wrong
          if !@exiting
            exit_hooks
            raise
          end
        end
        Thread.exit
      end
    end
    # if @use_processes
    #   puts "USE PROCESSES PID: #{pid}"
    # end
    return pid
  end
end