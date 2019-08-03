require "socket"

io = TCPSocket.open("les00",12345)

N=100
N.times do |i|
  s = "x"*100
  io.puts s
  #io.flush
  r = io.gets.chomp
  raise if r!=s
end
