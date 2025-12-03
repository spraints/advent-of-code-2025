pos = 50
zeroes1 = 0
zeroes2 = 0
ARGF.each_line do |line|
  #oldpos = pos
  line =~ /(R|L)(\d+)/ or raise line.inspect
  dir = $1
  dist = $2.to_i
  dist *= -1 if dir == "L"
  zeroes2 -= 1 if pos == 0 && dir == "L"
  pos = pos + dist
  zeroes2 += (pos / 100).abs
  #p [line, [oldpos, pos], pos / 100, zeroes2]
  pos %= 100
  zeroes1 += 1 if pos == 0
  zeroes2 += 1 if pos == 0 && dir == "L"
  #puts "#{line.inspect} => #{pos}/#{zeroes1}/#{zeroes2}"
end
puts zeroes1, zeroes2
