function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  tuples = map(split, lines)
  return [ (parse(Int, pair[1]), parse(Int, pair[2])) for pair in tuples ]
end

function distances(pairs)
  distances = [ abs(j - i) for (i, j) in pairs ]
  return distances
end

function orderList!(pairs)
  lefts = map(x -> x[1], sort(pairs, by = x -> x[1]))
  rights = map(x -> x[2], sort(pairs, by = x -> x[2]))
  return zip(lefts, rights)
end

function similarity(pairs)
  rights = map(x -> x[2], sort(pairs, by = x -> x[2]))
  similar = p -> count(==(p), rights)
  return [ p[1] * similar(p[1]) for p in pairs ]
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    pairs = parseInput(lines)
    sims = similarity(pairs)
    @show sum(sims)
end
main(ARGS)
