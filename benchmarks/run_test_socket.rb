$ tail -n100 *
==> test1-worker.rb <==
N=100
N.times do |i|
  s = "x"*100
  $stdout.puts s
  $stdout.flush
  r = $stdin.gets.chomp
  raise if r!=s
end

==> test1.rb <==
cmd = "ssh -x -T -q les01 'cd #{Dir.pwd}; exec ruby ./test1-worker.rb'"
io = IO.popen(cmd, "r+")

while !io.eof?
  i = io.gets.chomp
  io.puts i
  io.flush
end

==> test2-worker.rb <==
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

==> test2.rb <==
require "socket"

server = TCPServer.open(12345)

cmd = "ssh -x -T -q les01 'cd #{Dir.pwd}; exec ruby ./test2-worker.rb'"
pipe = IO.popen(cmd, "r+")

io = server.accept
while !io.eof?
  r = io.gets.chomp
  io.puts r
  #io.flush
end

# HAD PROMPT...
$ time ruby test1.rb 
real  0m0.470s
user  0m0.085s
sys 0m0.022s

$ time ruby test2.rb 

real  0m8.122s
user  0m0.028s
sys 0m0.005s

$ ruby -v
ruby 1.9.3p125 (2012-02-16 revision 34643) [x86_64-linux]