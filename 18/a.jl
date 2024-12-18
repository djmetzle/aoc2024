const SIZE = 71
const FIRST = 1024

function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  coords = map(l -> split(l, ","), lines)
  return map(c -> (1+parse(Int, c[1]), 1+parse(Int, c[2])), coords)
end

function minSteps(corrupted, first)
  start = CartesianIndex(1,1)
  ending = CartesianIndex(SIZE, SIZE)
  distances = Dict()
  unvisited = Set()

  for c in CartesianIndices(corrupted)
    if !corrupted[c]
      distances[c] = Inf
      push!(unvisited, c)
    end
  end
  distances[start] = 0

  while !isempty(unvisited) && distances[ending] == Inf
    current_unvisited = [un for un in unvisited]
    ui = findmin(i->distances[i], current_unvisited)
    u = current_unvisited[ui[2]]
    distance = get(distances, u, nothing)
    delete!(unvisited, u)
    for n in u .+ [CartesianIndex(1,0), CartesianIndex(0,1), CartesianIndex(-1, 0), CartesianIndex(0, -1)]
      if n in unvisited
        alt = distance + 1
        if distances[n] > alt
          distances[n] = alt
        end
      end
    end
  end

  return distances[ending]
end

function buildCorrupted(coords,first)
  corrupted = falses(SIZE, SIZE)
  for c in coords[1:first]
    corrupted[c...] = true
  end
  return corrupted
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  coords = parseInput(lines)

  # binary search (by hand)
  for first in 3030:3040
    corrupted = buildCorrupted(coords, first)
    @show first, minSteps(corrupted, first), lines[first]
  end
end
main(ARGS)
