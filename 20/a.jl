function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  maze = falses(length(lines), length(lines[1]))  
  chars = map(l->split(l, ""), lines)
  startp = nothing
  endp = nothing
  for i in eachindex(chars)
    for j in eachindex(chars[i])
      if chars[i][j] in [ ".", "S", "E" ]
        maze[i,j] = true
        if chars[i][j] == "S"
          startp = (i,j)
        end
        if chars[i][j] == "E"
          endp = (i,j)
        end
      end
    end
  end
  return maze, startp, endp
end

DIRS = [(1,0), (-1,0), (0,1), (0,-1)]

function findPath(maze, startp, endp)
  path = [startp]
  pos = startp
  while pos != endp
    for d in DIRS
      next = pos .+ d
      if maze[next...] && !(next in path)
        push!(path, next)
        pos = next
      end
    end
  end
  return path
end

function cheatSaves(path, from, between, to)
  len = length(path)
  from_i = findfirst(i->i==from, path)
  to_i = findfirst(i->i==to, path)
  new_path = cat(path[1:from_i], [between], path[to_i:len], dims=1)
  return len - length(new_path)
end

function findCheats(maze, path)
  mazeSize = size(maze)
  cheats = []
  for i in eachindex(path)
    pos = path[i]
    remaining = path[(i+1):length(path)]
    for d in DIRS
      between = pos .+ d
      cheat = pos .+ 2 .* d
      if 0 < cheat[1] <= mazeSize[1] && 0 < cheat[2] <= mazeSize[2]
        if maze[cheat...] && cheat in remaining
          push!(cheats, cheatSaves(path, pos, between, cheat))
        end
      end
    end
  end
  return cheats
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  @show lines
  maze, startp, endp = parseInput(lines)
  display(maze)
  @show startp, endp
  path = findPath(maze, startp, endp)
  @show first(path), last(path), path |> length
  cheats = findCheats(maze, path)
  @show filter(c -> (100 <= c), cheats) |> length
end
main(ARGS)
