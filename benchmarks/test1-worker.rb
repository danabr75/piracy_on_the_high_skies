N=100
N.times do |i|
  s = "x"*100
  $stdout.puts s
  $stdout.flush
  r = $stdin.gets.chomp
  raise if r!=s
end