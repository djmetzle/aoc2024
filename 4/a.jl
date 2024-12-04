XMAS = ["X", "M", "A", "S"]

function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return map(line -> collect(split(line, "")), lines)
end

function dims(grid)
  return size(grid)[1], size(grid[1])[1]
end

function countHorizontal(grid)
  I, J  = dims(grid)
  count = 0
  for i in 1:I
    for j in 1:(J-3)
      substr = grid[i][j:(j+3)]
      if substr == XMAS || reverse(substr) == XMAS
        count += 1
      end
    end
  end
  return count
end

function countVertical(grid)
  I, J  = dims(grid)
  count = 0
  for i in 1:(I-3)
    for j in 1:J
      substr = [ grid[x][j] for x=i:(i+3) ]
      if substr == XMAS || reverse(substr) == XMAS
        count += 1
      end
    end
  end
  return count
end

function countLeftDiagonal(grid)
  I, J  = dims(grid)
  count = 0
  for i in 1:(I-3)
    for j in 1:(J-3)
      substr = [ grid[i+n][j+n] for n in 0:3 ]
      if substr == XMAS || reverse(substr) == XMAS
        count += 1
      end
    end
  end
  return count
end

function countRightDiagonal(grid)
  I, J  = dims(grid)
  count = 0
  for i in 4:I
    for j in 1:(J-3)
      substr = [ grid[i-n][j+n] for n in 0:3 ]
      if substr == XMAS || reverse(substr) == XMAS
        count += 1
      end
    end
  end
  return count
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    grid = readfile(filename)

    @show countHorizontal(grid) + countVertical(grid) + countLeftDiagonal(grid) + countRightDiagonal(grid)
end
main(ARGS)
