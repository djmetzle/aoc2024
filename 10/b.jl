function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function buildmap(lines)
  cells = split.(lines, "")
  return hcat(map(x -> parse.(Int, x), cells)...)
end

function inBounds(pos, dims)
  return 0 < pos[1] <= dims[1] && 0 < pos[2] <= dims[2]
end

function findEnds(topo)
  return map(Tuple, findall(==(0), topo))
end

ADJACENT = [(1,0), (-1, 0), (0, 1), (0, -1)]

function findTrails(topo, start)
  dims = topo |> size
  routes = [[start]]
  for i in 1:9
    for r in routes
      tail = last(r)
      for a in ADJACENT
        n = tail .+ a
        if inBounds(n, dims) && topo[n...] == i
          next_route = vcat(copy(r), [n])
          push!(routes, next_route)
        end
      end

      routes = filter(r -> length(r) == i + 1, unique(routes))
      @show routes
    end
  end
  return routes |> length
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  topo = readfile(filename) |> buildmap
  display(topo)
  starts = findEnds(topo)
  @show starts
  scores = map(s -> findTrails(topo, s), starts)
  @show scores
  @show sum(scores)
end
main(ARGS)
