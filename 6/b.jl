function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function inputMap(lines)
  dims = length(lines[1]), length(lines)
  map = falses(dims)
  starting_pos = (0,0)
  for i in eachindex(lines[1])
    for j in eachindex(lines)
      if lines[i][j] == '#'
        map[i,j] = 1
      end
      if lines[i][j] == '^'
        starting_pos = (i, j)
      end
    end
  end
  return map, starting_pos
end

function inBounds(pos, dims)
  return 0 < pos[1] <= dims[1] && 0 < pos[2] <= dims[2]
end

function integrate(map, starting_pos)
  directions = [(-1, 0), (0, 1), (1, 0), (0, -1)]
  map_size = map |> size
  visited = Set{Tuple}()
  pos = starting_pos
  while inBounds(pos, map_size)
    next_pos = pos .+ directions[1]
    if (next_pos, directions[1]) in visited
      return true
    end
    push!(visited, (pos, directions[1]))
    if inBounds(next_pos, map_size) && map[next_pos...]
      circshift!(directions, -1)
      continue
    end
    pos = next_pos
  end
  return false
end

function findLoops(map, starting_pos)
  map_size = map |> size
  loopers = falses(map_size)
  for i in 1:map_size[1]
    for j in 1:map_size[2]
      if starting_pos == (i,j)
        continue
      end
      with_obstacle = copy(map)
      with_obstacle[i,j] = true
      loopers[i,j] = integrate(with_obstacle, starting_pos)
    end
  end
  return loopers
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    map, starting_pos = inputMap(lines)

    @show findLoops(map, starting_pos) |> findall |> length
end
main(ARGS)
