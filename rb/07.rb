streams = nil
splits = 0
ARGF.each_line do |line|
  line = line.chomp.chars
  if streams.nil?
    streams = [0]*line.size
    streams[line.index("S")] = 1
  else
    new_streams = streams.dup
    line.each_with_index do |c, i|
      if c == "^" && streams[i] != 0
        splits += 1
        new_streams[i-1] += streams[i]
        new_streams[i] = 0
        new_streams[i+1] += streams[i]
      end
    end
    streams = new_streams
  end
end
puts splits, streams.sum
