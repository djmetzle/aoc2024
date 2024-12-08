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
    stride = pair[2]-pair[1]
    n = 0
    while inBounds(pair[1] + n * stride, dims) || inBounds(pair[1] - n * stride, dims)
      if inBounds(pair[1] + n * stride, dims)
        antinodes[pair[1] + n * stride] = true
      end
      if inBounds(pair[1] - n * stride, dims)
        antinodes[pair[1] - n * stride] = true
      end
      n += 1
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
    @show a
    antinodes = antinodes .|| find_antinodes(a, map, dims)
  end
  @show length(findall(antinodes))
end
main(ARGS)
