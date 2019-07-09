# require 'concurrent'
require 'parallel'
# require 'ruby-progressbar'
# require 'time'
# require 'benchmark/ips'

class AsyncProcessManager

  def initialize thread_type_klass, threads, list_is_hash = false, use_processes = false
    @thread_type_klass = thread_type_klass
    @use_processes = use_processes
    # @processor_count = 2
    @processor_count = threads
    @list_is_hash = list_is_hash
    Thread.abort_on_exception = true
  end

  def update window, items, *args
    Thread.new do
      if @list_is_hash
        Parallel.each(items, in_threads: @processor_count) do |key, item|
          @thread_type_klass.update(window, item, args)
        end
      else
        Parallel.each(items, in_threads: @processor_count) do |item|
          @thread_type_klass.update(window, item, args)
        end
      end
      Thread.exit
    end
  end
end