# require 'concurrent'
# require 'parallel'
# # require 'ruby-progressbar'
# # require 'time'

# module AsyncProcessManager

#   def initialize thread_type_klass, max_concurrent_threads, use_processes 
#   end

#   # def self.update items, thread_type_klass, *args
#   def update
#     Thread.new do
#       # results = Parallel.map((0..20), in_processes: 7, progress: "Proj Update: ", isolation: false) { |item| rand(255) }
#       # results = Parallel.map((0..20), in_processes: 2, isolation: false) { |item| rand(255) }
#       results = Parallel.map((0..20), in_processes: 4) { |item| rand(255) }
#       # Process.waitall
#       puts "FORK RESULTS HERE: #{results.count}"
#       Thread.exit
#     end
#   end
# end