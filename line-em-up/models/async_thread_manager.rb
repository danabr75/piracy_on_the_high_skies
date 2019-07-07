require 'concurrent'
require 'parallel'
# require 'ruby-progressbar'
# require 'time'

class AsyncThreadManager

  Thread.abort_on_exception = true

  def initialize thread_type_klass, max_concurrent_threads, use_processes = false #= (Concurrent.processor_count * 2)
    @threads_active = []
    @max_number_of_threads = max_concurrent_threads
    @thread_type_klass = thread_type_klass
    @use_processes = use_processes
    if @use_processes
      @holding_queue = {}
    else
      @holding_queue = []
    end
    # @processor_count = (Concurrent.processor_count - 1)
    @processor_count = 2
  end

  def update *args
    # start_time = Time.now

    # Remove thread from active queue if finished
    # index_offset = 0
    # # puts "THReAD cOUNT: #{@threads_active.count}"
    # (0..@threads_active.count - 1).each do |i|
    #   # puts "ITERATE - OFFSET: #{index_offset} and i: #{i}"
    #   if !@threads_active[i - index_offset].alive?
    #     @threads_active.delete_at(i - index_offset)
    #     index_offset += 1
    #   end
    # end

    # if @async
    #   @threads_active.reject! {|t| !t.alive? }
    # else
    #   @threads_active.reject! do |t|
    #     t.join
    #     true
    #   end
    # end

    # @projectiles_queue.reject! {|p| p.health == 0}
    # puts "THREADS FINISHED HERE: #{index_offset}"

    # add new threads into active queue
    # while @threads_active.count < @max_number_of_threads && @holding_queue.count > 0
    if !@use_processes
      Thread.new(@holding_queue, @thread_type_klass, args) do |local_holding_queue, local_klass, local_args|
        while local_holding_queue.count > 0
          item = local_holding_queue.shift
          next if item.nil? || item.health == 0
          # @threads_active << @thread_type_klass.create_new(item, args)
          local_klass.create_new(item, local_args)
        end
      end
    # end_time = Time.now
    # puts "ATM - UPDATE TOOK: #{end_time - start_time}"
    else
      # item_data = []
      # @holding_queue.each do |key, item|
      #   item_data << item.get_data
      # end
      if @holding_queue.count > 0
        # Thread.new(@holding_queue, @thread_type_klass, args) do |local_holding_queue, local_thread_klass, local_args|
          # local_holding_queue, local_thread_klass, local_args = [@holding_queue, @thread_type_klass, args]
          # item_data = []
          # local_holding_queue.each do |key, item|
          #   # item_data << item.get_data
          #   item_data << rand(255)
          #   # break # debugging
          # end

          # items = []
          # (0..20).each do |i|
          #   items << rand(255)
          # end

          # results = Parallel.each(local_data, in_processes: @processor_count) do |item|
          # puts "FORKING HERE"
          # puts item_data.class
          # puts item_data.count
          # puts item_data.first

          # results = Parallel.each(item_data, in_processes: @processor_count, progress: "Proj Update: ", isolation: true) do |item|
          results = Parallel.map((0..20), in_processes: 7, progress: "Proj Update: ", isolation: false) { |item| rand(255) }
          # #   # item.class
          # #   puts "ITEM: #{item}"
          # #   item
          # #   # local_thread_klass.create_new(item, item[:klass], local_args)
          # # end

          puts "FORK RESULTS HERE: #{results.count}"
          # puts results.class
          # puts results.first

          # results.each do |result|
          #   # local_holding_queue[result[:id]].set_data(result)
          #   # local_holding_queue.delete(result[:id])
          # end

        # end
      end
    end
  end

  def add new_projectile
    # puts "ADDING Projectile HERE"
    if @use_processes
      @holding_queue[new_projectile.id] = new_projectile
    else
      @holding_queue << new_projectile
    end
  end

end