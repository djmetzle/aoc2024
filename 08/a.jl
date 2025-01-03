function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return split.(lines, "")
end

function inBounds(pos, dims)
  return 0 < pos[1] <= dims[1] && 0 < pos[2] <= dims[2]
end

function find_antinodes(a, anntenae, dims)
  antinodes = falses(dims...)
  matched = findall(i -> i == a, anntenae)
  pairs = collect(Iterators.product(matched, matched)) |> filter(p -> p[1] != p[2])
  for pair in pairs
    left = 2 * pair[1] - pair[2]
    right = 2 * pair[2] - pair[1]
    if inBounds(left, dims)
      antinodes[left] = true
    end
    if inBounds(right, dims)
      antinodes[right] = true
    end
  end
  return antinodes
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  map = hcat(readfile(filename)...)
  dims = size(map)
  names = unique(map) |> filter(n -> n != ".")
  antinodes = falses(dims...)
  for a in names
    antinodes = antinodes .|| find_antinodes(a, map, dims)
  end
  @show length(findall(antinodes))
end
main(ARGS)
