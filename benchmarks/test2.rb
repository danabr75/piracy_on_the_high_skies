require "socket"

server = TCPServer.open(12345)

cmd = "ssh -x -T -q les01 'cd #{Dir.pwd}; exec ruby ./test2-worker.rb'"
pipe = IO.popen(cmd, "r+")

io = server.accept
while !io.eof?
  r = io.gets.chomp
  io.puts r
  io.flush
end