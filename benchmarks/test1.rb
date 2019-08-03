cmd = "ssh -x -T -q les01 'cd #{Dir.pwd}; exec ruby ./test1-worker.rb'"
io = IO.popen(cmd, "r+")

while !io.eof?
  i = io.gets.chomp
  io.puts i
  io.flush
end