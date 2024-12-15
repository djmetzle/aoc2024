function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

WALL = '#'
EMPTY = '.'
BOX = 'O'
FISH = '@'

DIRS = Dict(
  'v' => (1, 0),
  '^' => (-1, 0),
  '>' => (0, 1),
  '<' => (0, -1),
)
@show DIRS

function parseInput(lines)
  grid = []
  instructions = ""
  separator = first(findall(l -> l == "", lines))
  grid = hcat(map(l -> collect(l), lines[1:(separator-1)])...)
  instructions = lines[(separator+1):length(lines)] |> join
  fish = nothing
  for i in (1:size(grid)[1])
    for j in (1:size(grid)[2])
      if grid[i,j] == FISH
        fish = (i,j)
      end
    end
  end
  return grid, instructions, fish
end


function apply(grid, instruction, fish)
  fishx, fishy = fish
  if instruction == '^'
    col = grid[fishx,:]
    move = false
    boxes = []
    for i in (fishy-1):-1:1
      p = col[i]
      if p == WALL
        break
      end
      if p == EMPTY
        move = true
        break
      end
      if p == BOX
        push!(boxes, i)
      end
    end
    if move
      for b in boxes
        col[b-1] = BOX
      end
      grid[fishx,:] = col
      fish = (fishx, fishy-1)
    end
  end
  if instruction == 'v'
    col = grid[fishx,:]
    move = false
    boxes = []
    for i in (fishy+1):length(col)
      p = col[i]
      if p == WALL
        break
      end
      if p == EMPTY
        move = true
        break
      end
      if p == BOX
        push!(boxes, i)
      end
    end
    if move
      for b in boxes
        col[b+1] = BOX
      end
      grid[fishx,:] = col
      fish = (fishx, fishy+1)
    end
  end
  if instruction == '<'
    row = grid[:,fishy]
    move = false
    boxes = []
    for i in (fishx-1):-1:1
      p = row[i]
      if p == WALL
        break
      end
      if p == EMPTY
        move = true
        break
      end
      if p == BOX
        push!(boxes, i)
      end
    end
    if move
      for b in boxes
        row[b-1] = BOX
      end
      grid[:,fishy] = row
      fish = (fishx-1 , fishy)
    end
  end
  if instruction == '>'
    row = grid[:,fishy]
    move = false
    boxes = []
    for i in (fishx+1):length(row)
      p = row[i]
      if p == WALL
        break
      end
      if p == EMPTY
        move = true
        break
      end
      if p == BOX
        push!(boxes, i)
      end
    end
    if move
      for b in boxes
        row[b+1] = BOX
      end
      grid[:,fishy] = row
      fish = (fishx+1 , fishy)
    end
  end
  return fish
end

function iterateGrid(grid, instructions, fish)
  for i in instructions
    grid[fish...] = '.'
    fish = apply(grid, i, fish)
    grid[fish...] = '@'
  end
end

function gps(grid)
  boxes = []
  for i in axes(grid,2), j in axes(grid,1)
    if grid[i,j] == BOX
      push!(boxes, 100*(j-1) + (i-1))
    end
  end
  return boxes
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  grid, instructions, fish = parseInput(lines)
  display(permutedims(grid))
  @show instructions |> length, fish
  iterateGrid(grid, instructions, fish)
  @show "fin"
  display(permutedims(grid))
  @show gps(grid) |> sum
end
main(ARGS)
