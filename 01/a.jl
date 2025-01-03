function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  tuples = map(split, lines)
  return [ (parse(Int, i), parse(Int, j)) for (i,j) in tuples ]
end

function distances(pairs)
  distances = [ abs(j - i) for (i, j) in pairs ]
  return distances
end

function orderList(pairs)
  lefts = map(x -> x[1], pairs)
  rights = map(x -> x[2], pairs)
  return zip(sort(lefts), sort(rights))
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    pairs = parseInput(lines)
    ordered = orderList(pairs)
    distance = distances(ordered)
    @show sum(distance)
end
main(ARGS)
