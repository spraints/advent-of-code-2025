pos = 50
zeroes = 0
ARGF.each_line do |line|
  line =~ /(R|L)(\d+)/ or raise line.inspect
  dir = $1
  dist = $2.to_i
  dist *= -1 if dir == "L"
  pos = (pos + dist) % 100
  zeroes += 1 if pos == 0
  #puts "#{line.inspect} => #{pos}"
end
puts zeroes
