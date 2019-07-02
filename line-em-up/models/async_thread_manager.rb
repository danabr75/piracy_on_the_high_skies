require 'concurrent'

require 'time'

class AsyncThreadManager

  Thread.abort_on_exception = true

  def initialize max_concurrent_threads = (Concurrent.physical_processor_count)
    @projectiles_queue = []
    @threads_active = []
    @max_number_of_threads = max_concurrent_threads
  end

  def update window, targets
    # start_time = Time.now

    # Remove thread from active queue if finished
    index_offset = 0
    # puts "THReAD cOUNT: #{@threads_active.count}"
    (0..@threads_active.count - 1).each do |i|
      # puts "ITERATE - OFFSET: #{index_offset} and i: #{i}"
      if !@threads_active[i - index_offset].alive?
        @threads_active.delete_at(i - index_offset)
        index_offset += 1
      end
    end
    # puts "THREADS FINISHED HERE: #{index_offset}"

    # add new threads into active queue
    while @threads_active.count < @max_number_of_threads && @projectiles_queue.count > 0
      @threads_active << ProjectileCollisionThread.create_new(window, @projectiles_queue.shift, targets)
    end
    # end_time = Time.now
    # puts "ATM - UPDATE TOOK: #{end_time - start_time}"
  end

  def add new_projectile
    # puts "ADDING Projectile HERE"
    @projectiles_queue << new_projectile
  end

end