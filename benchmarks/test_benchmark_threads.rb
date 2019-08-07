require 'benchmark'
require 'parallel'


items = {}

5000.times do
  items[SecureRandom.hex(5)] = SecureRandom.hex(5)
end


b = Benchmark.measure do
  t = Thread.new do
    items.each do |key, value|
      test = key + value
    end
  end
end



b2 = Benchmark.measure do
  t = Thread.new do
    items.each do |key, value|
      test = key + value
    end
  end
  t.join
end


b3 = Benchmark.measure do
  Parallel.each(items, in_threads: 8) do |key, value|
    test = key + value
  end
end


puts b
puts b2
puts b3



module Test
  def self.test
    100 * 10.5
  end
end


b5 = Benchmark.measure do
  Test.test
end

b4 = Benchmark.measure do
  Test.send(:test)
end


########################



puts b
puts b2

# non-local is slighty faster
Benchmark.bmbm do |x|
  x.report("non-local") do
    t = Thread.new do
      items.each do |key, value|
        test = key + value + SecureRandom.hex(5)
      end
    end
    t.join
  end
  x.report("local") do
    t = Thread.new(items) do |local_items|
      local_items.each do |key, value|
        test = key + value + SecureRandom.hex(5)
      end
    end
    t.join
  end
end

ERROR_PREFIX                        = 'ERROR_FOUND_ON_SUB_PROCESS_'
SUB_PROCESS_ENCOUNTER_ERROR_PATTERN = /#{ERROR_PREFIX}([^\n]*)/

not_matching = "NOT_GOING_TO_MATCH"
matching = "ERROR_FOUND_ON_SUB_PROCESS_TESTERROR"

line = matching
b4 = Benchmark.measure do
  line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)
end

line = not_matching
b5 = Benchmark.measure do
  line.match(SUB_PROCESS_ENCOUNTER_ERROR_PATTERN)
end

puts "MATCHING"
puts b4


puts "NOT MATCHING"
puts b5



module Test

  def self.test
    100 * 10.5
  end


end



b4 = Benchmark.measure do
  Thread.new {
    puts "test123"
  }.join
end

b5 = Benchmark.measure do
  f = Fiber.new {
    puts "test123"
  }
  f.resume
end

b6 = Benchmark.measure do
  puts "test123"
end

puts b4

puts b5
puts b6
# [654] pry(main)> puts b4
#   0.000026   0.000047   0.000073 (  0.000060)
# => nil
# [655] pry(main)> 
# [656] pry(main)> puts b5
#   0.000014   0.000011   0.000025 (  0.000022)
# => nil
# [657] pry(main)> puts b6
#   0.000018   0.000008   0.000026 (  0.000014)
# => nil







b4 = Benchmark.measure do
  true
end

b5 = Benchmark.measure do
  ['123', '123', 123]
end

b6 = Benchmark.measure do
  {'1': '123', '2': '123', '3': 123}
end


TEST = [1,2,3,4,5]
TEST2 = {'1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5}

MESSAGES = []
MESSAGES2 = Array.new(500) {SecureRandom.hex(16)}

Benchmark.bmbm do |x|
  messages = MESSAGES.dup
  messages2 = MESSAGES2.dup

  x.report("EMPTY any MESSAGES") do
    messages.any?
  end
  x.report("EMPTY count MESSAGES") do
    messages.count
  end
  x.report("EMPTY reject MESSAGES") do
    messages.reject! {|m| true }
  end


  x.report("EMPTY any? MESSAGES2") do
    messages2.any?
  end
  x.report("EMPTY count MESSAGES2") do
    messages2.count
  end
  x.report("EMPTY reject! MESSAGES2") do
    messages2.reject! {|m| true }
  end

end

TEST = 15.323734622809937

Benchmark.bmbm do |x|
  messages = MESSAGES.dup
  messages2 = MESSAGES2.dup

  x.report("EMPTY any MESSAGES") do
    TEST.round
  end
  x.report("EMPTY count MESSAGES") do
    TEST.round
  end
  x.report("EMPTY reject MESSAGES") do
    TEST.round
  end


  x.report("EMPTY any? MESSAGES2") do
    TEST.round
  end
  x.report("EMPTY count MESSAGES2") do
    TEST.round
  end
  x.report("EMPTY reject! MESSAGES2") do
    TEST.round
  end

end










