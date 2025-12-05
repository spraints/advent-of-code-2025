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

def show_grid(label, grid)
  #puts "===== #{label} =====", grid.map { |row| row.join("") }
end

iters = 0
grid = ARGF.readlines.map { |line| line.strip.chars.to_a }
show_grid("start", grid)
removed_by_round = []
loop do
  changes = 0
  new_grid = []
  grid.each_with_index do |row, i|
    new_grid << row.each_with_index.map do |cell, j|
      iters += 1
      if cell == "x"
        "."
      elsif cell == "@" && count_neighbors(grid, i, j) < 4
        changes += 1
        "x"
      else
        cell
      end
    end
  end
  show_grid("round #{removed_by_round.size + 1}", new_grid)
  #puts "===> #{changes}"
  break if changes == 0
  removed_by_round << changes
  grid = new_grid
end
puts "(iterations: #{iters})",
  removed_by_round.first, removed_by_round.sum
