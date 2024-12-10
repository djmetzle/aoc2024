using Images

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

function buildImages(topo)
  global topomapimg = fill(RGB(0.0, 0.0, 0.0), size(topo))
  for ij in CartesianIndices(topo)
    topomapimg[ij] = RGB(0.0, topo[ij] / 10.0, 0.0)
  end
  global imgs = [ copy(topomapimg) for _ in 1:10 ]
end

function addToImages(topo, routes)
  for s in eachindex(routes)
    for r in eachindex(routes[s])
      @show r
      for i in 1:10
        for j in 1:i
          p = routes[s][r][j]
          @show r, p
          imgs[i][CartesianIndex(p)] = RGB(0.5 + (topo[CartesianIndex(p)] + 1)/ 20.0, 0.0, 0.0)
        end
      end
    end
  end
end

function dumpImages()
  filename = "images/img-00.png"
  save(filename, imresize(topomapimg, ratio=20/1))
  for i in 1:9
    filename = "images/img-$(lpad(i+1,2,"0")).png"
    save(filename, imresize(imgs[i], ratio=20/1))
  end
end

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
    end
  end
  return routes
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
  buildImages(topo)
  routes = map(s -> findTrails(topo, s), starts)
  @show routes
  addToImages(topo, routes)
  dumpImages()
end
main(ARGS)
