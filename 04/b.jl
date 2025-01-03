MAS = ["M", "A", "S"]

function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return map(line -> collect(split(line, "")), lines)
end

function dims(grid)
  return size(grid)[1], size(grid[1])[1]
end

function bothMasMatch(leftsubstr, rightsubstr)
  return (leftsubstr == MAS || reverse(leftsubstr) == MAS) &&
    (rightsubstr == MAS || reverse(rightsubstr) == MAS)
end

function countXmases(grid)
  I, J  = dims(grid)
  count = 0
  for i in 2:(I-1)
    for j in 2:(J-1)
      if grid[i][j] != "A"
        continue
      end

      leftsubstr = [ grid[i+n][j+n] for n in -1:1 ]
      rightsubstr = [ grid[i+n][j-n] for n in -1:1 ]
      if bothMasMatch(leftsubstr, rightsubstr)
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

    @show countXmases(grid)
end
main(ARGS)
