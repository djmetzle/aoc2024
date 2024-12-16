function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

DIRS = Dict(
  'E' => CartesianIndex(1,0),
  'W' => CartesianIndex(-1,0),
  'N' => CartesianIndex(0,1),
  'S' => CartesianIndex(0,-1),
)

LEFT = Dict(
  'E' => 'N',
  'W' => 'S',
  'N' => 'W',
  'S' => 'E',
)

RIGHT = Dict(
  'E' => 'S',
  'W' => 'N',
  'N' => 'E',
  'S' => 'W',
)

function parseInput(lines)
  return hcat(map(collect, lines)...)
end

function startEnding(puzzle)
  start = findall(p -> p == 'S', puzzle)
  ending = findall(p -> p == 'E', puzzle)
  return start, ending
end

function updateCost(position, cost)
  global positionCosts
  if !haskey(positionCosts, position)
    positionCosts[position] = cost
    return
  end
  if positionCosts[position] > cost
    positionCosts[position] = cost
  end
end

function iterate(puzzle, positions)
  global positionCosts
  next_positions = Set()
  for position in positions 
    pos = position[1]
    dir = position[2]
    cost = positionCosts[position]
    
    for d in [('L', LEFT[dir]), (' ', dir), ('R', RIGHT[dir])]
      turn = d[1] 
      move = d[2]
      next_direction = DIRS[move]
      next_pos = pos .+ next_direction
      if puzzle[next_pos] == ['#']
        continue
      end
      if haskey(positionCosts, (next_pos, move)) && positionCosts[(next_pos, move)] < positionCosts[(pos,dir)]
        continue
      end
      if turn == ' '
        push!(next_positions, (next_pos, move))
        updateCost((next_pos, move), cost + 1)
        continue
      end
      push!(next_positions, (next_pos, move))
      updateCost((next_pos, move), cost + 1001)
    end
  end
  return next_positions
end

function pathCost(path)
  turns = 0
  for i in 1:(length(path) - 1)
    if path[i][2] != path[i+1][2]
      turns += 1
    end
  end
  @show turns
  return length(path) + turns * 1000
end

function bestPaths(puzzle, start, ending)
  global positionCosts
  paths = Set()
  next_paths = Set()
  push!(next_paths, [(start, 'E')])
  while paths != next_paths
    paths = next_paths
    next_paths = Set()
    for path in paths
      position = last(path)
      pos = position[1]
      dir = position[2]
      if pos == ending
        push!(next_paths, path)
        continue
      end
      for d in [('L', LEFT[dir]), (' ', dir), ('R', RIGHT[dir])]
        turn = d[1] 
        move = d[2]
        next_direction = DIRS[move]
        next_pos = pos .+ next_direction
        if turn == ' '
          if haskey(positionCosts, (next_pos, move)) && positionCosts[(next_pos, move)] == positionCosts[(pos,dir)] + 1
            next_path = push!(copy(path), (next_pos,move))
            push!(next_paths, next_path)
          end
        end
        if turn in ['R', 'L']
          if haskey(positionCosts, (next_pos, move)) && positionCosts[(next_pos, move)] == positionCosts[(pos,dir)] + 1001
            next_path = push!(copy(path), (next_pos,move))
            push!(next_paths, next_path)
          end
        end
      end
    end
  end
  paths = [ (path, pathCost(path)) for path in next_paths ] |> unique
  lowest = sort!(by=(p -> p[2]), paths) |> first 
  lowest_cost = lowest[2]
  @show lowest_cost
  lowest_paths = filter(p->(p[2] == lowest_cost), paths)
  @show lowest_paths |> length
  return map(p->map(x->x[1],p[1]), lowest_paths) |> Iterators.flatten |> unique
end


function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  puzzle = parseInput(lines)
  display(puzzle)
  start, ending = startEnding(puzzle)
  @show start, ending
  global positionCosts = Dict( (start, 'E') => 0)
  positions = Set()
  next_positions = Set()
  push!(next_positions, (start, 'E'))
  while positions != next_positions
    positions = next_positions
    next_positions = iterate(puzzle, positions)
  end
  costs = []
  for d in ['E', 'W', 'N', 'S']
    if haskey(positionCosts, (ending, d))
      push!(costs, positionCosts[(ending, d )])
    end
  end
  @show minimum(costs)
  best = bestPaths(puzzle, start, ending)
  @show best
  @show best |> length
end
main(ARGS)
