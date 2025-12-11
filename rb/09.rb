DEBUG = !ENV["DEBUG"].nil?

class Coord
  def initialize(pt)
    @x = pt[0]
    @y = pt[1]
  end
  attr_reader :x, :y
  def <=>(other)
    [self.x, self.y] <=> [other.x, other.y]
  end
  def inspect
    [self.x, self.y].inspect
  end
  def ==(other)
    self.x == other.x && self.y == other.y
  end
  def eql?(other)
    self.x == other.x && self.y == other.y
  end
  def hash
    [self.x, self.y].hash
  end
end

tpt1 = Coord.new([1,1])
tpt2 = Coord.new([1,1])
tpt3 = Coord.new([1,2])
tpt4 = Coord.new([2,1])
raise "boom" if tpt1 != tpt2
raise "boom" if tpt1 == tpt3
raise "boom" if tpt1 == tpt4

coords = ARGF.readlines.map { |line| Coord.new(line.strip.split(",").map(&:to_i)) }

if DEBUG
  picture = []
  last_pt = coords.last
  coords.each do |pt|
    line = (picture[pt.y] ||= [])
    line[pt.x] = "#"
    case
    when last_pt.x == pt.x
      Range.new(*([pt.y,last_pt.y].sort)).each do |y|
        picture[y] ||= []
        picture[y][pt.x] = "X" if picture[y][pt.x].nil?
      end
    when last_pt.y == pt.y
      Range.new(*([pt.x,last_pt.x].sort)).each do |x|
        line[x] = "X" if line[x].nil?
      end
    else
      raise "#{pt} #{last_pt} womp womp"
    end
    last_pt = pt
  end
  max_line = picture.map { |l| l.nil? ? 0 : l.size }.max
  printf "       %s\n", (0..max_line).map { |i| i % 10 }.join
  picture.each_with_index do |line, i|
    if line.nil?
      printf "%6d|\n", i
    else
      printf "%6d|%s\n",
        i, line.map { |c| c || " " }.join
    end
  end
end

def area(p1, p2)
  l = (p1.x - p2.x).abs + 1
  w = (p1.y - p2.y).abs + 1
  l * w
end

def vert_edge_dir(edge, pt, verbose)
  ep1, ep2 = edge
  case
  when ep1.y < pt.y && pt.y < ep2.y
    puts "from #{pt} to #{edge}: cross" if verbose
    :cross
  when ep1.y == pt.y && ep2.y < pt.y
    puts "from #{pt} to #{edge}: up1" if verbose
    :up
  when ep2.y == pt.y && ep1.y < pt.y
    puts "from #{pt} to #{edge}: up2" if verbose
    :up
  when ep1.y == pt.y && ep2.y > pt.y
    puts "from #{pt} to #{edge}: down1" if verbose
    :down
  when ep2.y == pt.y && ep1.y > pt.y
    puts "from #{pt} to #{edge}: down2" if verbose
    :down
  else
    puts "from #{pt} to #{edge}: ???" if verbose
    :unknown
  end
end

class Bounds
  def initialize
    @vertical_edges = []
    @horizontal_edges = []
    @cache = {}
  end
  def add_edge(p1, p2)
    edge = [p1, p2].sort
    case
    when p1.x == p2.x
      @vertical_edges << edge
    when p1.y == p2.y
      @horizontal_edges << edge
    else
      raise "huh #{p1} #{p2}"
    end
    nil
  end
  def contains?(pt)
    if n = @cache[pt]
      p cached: pt, n: n if DEBUG
    else
      @cache[pt] = n = count_edges(pt)
    end
    n % 2 == 1
  end
  private
  def count_edges(pt)
    verbose = DEBUG && pt.x == 9 && pt.y == 5
    vert_matches = @vertical_edges.select { |e|
      e1, e2 = e
      xok = e1.x <= pt.x
      yok = e1.y <= pt.y && pt.y <= e2.y
      if verbose
        p check: e, px: pt.x, py: pt.y, xok: xok, yok: yok
      end
      xok && yok
    }
    dropped = 0
    vert_matches.combination(2).each do |e1, e2|
      p e1: e1, e2: e2 if verbose
      dir1 = vert_edge_dir(e1, pt, verbose)
      dir2 = vert_edge_dir(e2, pt, verbose)
      next unless [dir1, dir2].sort == [:down, :up]
      goal = [Coord.new([e1[0].x, pt.y]), Coord.new([e2[0].x, pt.y])].sort
      puts "checking if there is an edge between #{e1} and #{e2} (#{goal})..." \
        if verbose
      next unless @horizontal_edges.include?(goal)
      puts "... there is!" if verbose
      dropped += 1
    end

    n = vert_matches.size - dropped
    pp summary_for: pt, n: n, vert: vert_matches if DEBUG
    n
  end
  require "pp"
end

bounds = Bounds.new
coords.each_with_index do |pt, i|
  bounds.add_edge(pt, i == 0 ? coords.last : coords[i-1])
end

max_area1 = 0
max_area2 = 0
coords.each_with_index do |p1, i|
  rest = coords[i+2..] or next
  rest.each do |p2|
    a = area(p1, p2)
    p check_rect: [p1, p2], a: a if DEBUG
    max_area1 = [max_area1, a].max
    if a > max_area2
      # Check if all 4 corners are inside the shape.
      contained = [p1.x, p2.x].all? do |x|
        [p1.y, p2.y].all? do |y|
          bounds.contains?(Coord.new([x, y]))
        end
      end
      if contained
        puts "========> update part 2 = #{a}" if DEBUG
        max_area2 = a
      end
    end
  end
end
puts max_area1, max_area2
