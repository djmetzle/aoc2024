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
    @show next_positions
    
    @show next_positions |> length
  end
  costs = []
  for d in ['E', 'W', 'N', 'S']
    if haskey(positionCosts, (ending, d))
      push!(costs, positionCosts[(ending, d )])
    end
  end
  @show minimum(costs)
end
main(ARGS)
