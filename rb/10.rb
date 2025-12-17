def dbg(*m)
  #puts(*m) unless m.empty?
  #puts(yield) if block_given?
end

def main
  machines = ARGF.readlines.map { |line| parse_line(line) }
  part1 = part2 = 0
  machines.each_with_index do |m, i|
    prog machines, i
    part1 += fewest_button_presses(m)
  end
  puts "", part1
  machines.each_with_index do |m, i|
    prog machines, i
    part2 += buttons_for_joltages(m)
  end
  puts "", part2
end

def prog(machines, done)
  line = machines.each_with_index.map { |_, i| i < done ? "#" : "." }
  printf "\r%s", line.join
end

def buttons_for_joltages(m)
  choices = Hash.new { |h, k| h[k] = [] }
  seen = Set.new

  init = m.jolts.map { 0 }
  choices[0] << init
  seen << init

  k = 0
  loop do
    choice = choices[k].shift
    if choice.nil?
      k += 1
      choice = choices[k].shift
    end
    if choice.nil?
      raise "ahhhhhh #{k} // #{choices.inspect}"
    end
    m.buttons.each do |b|
      j = choice.dup
      b.each { |i| j[i] += 1 }
      next if seen.include?(j)
      seen << j
      return k + 1 if j == m.jolts
      next if j.zip(m.jolts).any? { |x, y| x > y }
      choices[k+1] << j
    end
  end
end

# Part 1:
#         e+f = 0 mod 2
#   b      +f = 1 mod 2
#     c+d+e   = 1 mod 2
# a+b  +d     = 0 mod 2
# 0+1+0+1+0+0
#
# Part 2:
#         e+f = 3
#   b      +f = 5
#     c+d+e   = 4
# a+b  +d     = 7

def fewest_button_presses(m)
  dbg m
  to_check = [ [m.lights.map { false }, []] ]
  seen = Set.new
  loop do
    raise "uh oh" if to_check.empty?
    lit, presses = to_check.shift
    seen << lit
    m.buttons.each do |b|
      new_lit = step(lit, b)
      next if seen.include?(new_lit)
      new_presses = presses + [b]
      dbg { "> #{lights_to_s(new_lit)} after #{buttons_to_s(new_presses)}" }
      if new_lit == m.lights
        dbg "====> #{new_presses.size}"
        return new_presses.size
      else
        to_check.push [new_lit, new_presses]
      end
    end
  end
end

def step(lit, b)
  res = lit.dup
  b.each { |i| res[i] = !res[i] }
  res
end

# Input: [true, false]
# Output: "[#.]"
def lights_to_s(lights)
  "[#{lights.map { |i| i ? "#" : "." }.join}]"
end

# Input: [ [1,2], [3] ]
# Output: "(1,2) (3)"
def buttons_to_s(buttons)
  buttons.map { |b| button_to_s(b) }.join(" ")
end

# Input: [1,2]
# Output: "(1,2)"
def button_to_s(b)
  "(#{b.join(",")})"
end

class Machine
  def initialize(lights:, buttons:, jolts:)
    @lights = lights.freeze
    @buttons = buttons.freeze
    @jolts = jolts.freeze
  end

  attr_reader :lights, :buttons, :jolts

  def to_s
    i = lights_to_s(lights)
    b = buttons_to_s(buttons)
    j = "{#{jolts.join(",")}}"
    "#{i} #{b} #{j}"
  end
end

def parse_line(line)
  line =~ /^\[([.#]+)\] ([\(\)0-9, ]+) \{([0-9,]+)\}$/ or raise "invalid line: #{line.inspect}"
  lights = $1
  buttons = $2
  jolts = $3
  lights = lights.chars.map { |c| c == "#" }
  buttons = buttons.split.map { |w| parse_button(w) }
  jolts = jolts.split(",").map(&:to_i)
  Machine.new \
    lights: lights,
    buttons: buttons,
    jolts: jolts
end

def parse_button(b)
  b =~ /\A\(([0-9,]+)\)\z/ or raise "invalid button: #{b.inspect}"
  $1.split(",").map(&:to_i)
end

main
