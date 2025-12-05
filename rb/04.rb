def count_neighbors(grid, i, j)
  res = 0
  [-1, 0, 1].each do |di|
    [-1, 0, 1].each do |dj|
      next if di == 0 && dj == 0
      ni = i + di
      nj = j + dj
      next if ni < 0 || nj < 0
      res += 1 if grid.dig(ni, nj) == "@"
    end
  end
  res
end

grid = ARGF.readlines.map { |line| line.strip.chars.to_a }
ok = 0
grid.each_with_index do |row, i|
  row.each_with_index do |cell, j|
    next if cell != "@"
    ok += 1 if count_neighbors(grid, i, j) < 4
  end
end
puts ok
