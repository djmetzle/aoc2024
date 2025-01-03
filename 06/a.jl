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
  visited = falses(map_size)
  pos = starting_pos
  while inBounds(pos, map_size)
    visited[pos...] = true
    next_pos = pos .+ directions[1]
    if inBounds(next_pos, map_size) && map[next_pos...]
      circshift!(directions, -1)
      continue
    end
    pos = next_pos
  end
  return visited, pos
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    map, starting_pos = inputMap(lines)
    display(map)
    @show starting_pos

    visited, _final_pos = integrate(map, starting_pos)
    display(visited)
    @show _final_pos
    @show visited |> findall |> length
end
main(ARGS)
