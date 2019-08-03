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

  def initialize thread_type_klass, threads, list_is_hash = false, use_type = :threads #, :processes, :none
    @thread_type_klass = thread_type_klass
    # @processor_count = 2
    @processor_count = threads
    @list_is_hash = list_is_hash
    @use_processes = use_type == :processes
    @test_use_processes = use_type == :test_processes
    @use_threads   = use_type == :threads
    @use_joined_threads   = use_type == :joined_threads
    @use_nothing   = use_type == :none
    Thread.abort_on_exception = true

    if @use_processes
      @processors_count = 1
      @child_read, @child_write = IO.pipe
      # @child_read, @child_write = IO.pipe

      @pids = []
      @processors_count.times do
        # pids << Process.spawn({"MARSHALLED_DATA" => item.get_data.to_json, "ARGS" => args.to_json }, RbConfig.ruby, "#{SCRIPT_DIRECTORY}/async_projectile_update_script.rb", :out => w, :err => [:child, :out])
        @pids << Process.spawn({"PARENT_PID" => Process.pid.to_s}, RbConfig.ruby, "#{SCRIPT_DIRECTORY}/async_projectile_update_script.rb", :in => @child_read, :out => @child_write, :err => [:child, :out])
      end
    end

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
          Parallel.each(items, in_threads: 8) do |key, item|
            @thread_type_klass.update(window, item, args)
          end
        else
          Parallel.each(items, in_threads: 8) do |item|
            @thread_type_klass.update(window, item, args)
          end
        end
      # end
    end

    if @use_threads
      Thread.new do
        if @list_is_hash
          Parallel.each(items, in_threads: 8) do |key, item|
            @thread_type_klass.update(window, item, args)
          end
        else
          Parallel.each(items, in_threads: 8) do |item|
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
    if false #@use_processes
      final_data = []
      # parameter_threads = []
      t = Thread.new do
        items.each do |key, item|
          # Process.spawn({"MARSHALLED_DATA" => item.get_data.to_json, "ARGS" => args.to_json }, RbConfig.ruby, "#{SCRIPT_DIRECTORY}/async_projectile_update_script.rb", :out => w, :err => [:child, :out])
          @r.write( Oj.dump({'data' => item.get_data, 'mouse_x' => args[0], 'mouse_y' => args[1], 'player_map_pixel_x' => args[2], 'player_map_pixel_y' => args[3]}) )
        end
        while items_count < final_data.count
          while (line = r.read) && line != ''
            data = Oj.load(line)
            final_data << data
          end
        end
        Thread.exit
      end

      t.join

      t = Thread.new do
        final_data.each do |f_data|
          items[f_data['id']].set_data(f_data)
        end
      end

      t.join

    end

  end
end