# require 'concurrent'

# require 'time'

class AsyncThreadManager

  Thread.abort_on_exception = true

  def initialize thread_type_klass, max_concurrent_threads, async = true #= (Concurrent.processor_count * 2)
    @holding_queue = []
    @threads_active = []
    @max_number_of_threads = max_concurrent_threads
    @thread_type_klass = thread_type_klass
    @async = async
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

    if @async
      @threads_active.reject! {|t| !t.alive? }
    else
      @threads_active.reject! do |t|
        t.join
        true
      end
    end

    # @projectiles_queue.reject! {|p| p.health == 0}
    # puts "THREADS FINISHED HERE: #{index_offset}"

    # add new threads into active queue
    while @threads_active.count < @max_number_of_threads && @holding_queue.count > 0
      item = @holding_queue.shift
      next if item.health == 0
      @threads_active << @thread_type_klass.create_new(item, args)
    end
    # end_time = Time.now
    # puts "ATM - UPDATE TOOK: #{end_time - start_time}"
  end

  def add new_projectile
    # puts "ADDING Projectile HERE"
    @holding_queue << new_projectile
  end

end