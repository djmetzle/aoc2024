function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

WALL = '#'
EMPTY = '.'
BOX = 'O'
FISH = '@'
BOXL = '['
BOXR = ']'

DIRS = Dict(
  'v' => (1, 0),
  '^' => (-1, 0),
  '>' => (0, 1),
  '<' => (0, -1),
)

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

NEW = Dict(
  WALL => ['#', '#'],
  EMPTY => ['.', '.'],
  BOX => ['[', ']'],
  FISH => ['@', '.'],
)

function doubleUp(grid)
  grid_lines = []
  for i in axes(grid, 2)
    row = grid[:,i]
    wide_row = map(r -> NEW[r], row) |> Iterators.flatten |> collect
    push!(grid_lines, wide_row)
  end
  grid = hcat(grid_lines...)
  fish = nothing
  for i in (1:size(grid)[1])
    for j in (1:size(grid)[2])
      if grid[i,j] == FISH
        fish = (i,j)
      end
    end
  end
  return grid, fish
end

function canPush(grid, new_pos, dir)
  box = grid[new_pos...]
  other_pos = box == BOXL ? (new_pos[1]+1, new_pos[2]) : (new_pos[1]-1, new_pos[2])
  other = grid[other_pos...]
  adj_positions = [ new_pos .+ (0, dir), other_pos .+ (0, dir) ]
  for adj in adj_positions
    adj_p = grid[adj...]
    if adj_p == WALL
      return false
    end
    if adj_p == BOXL || adj_p == BOXR
      if !canPush(grid, adj, dir)
        return false
      end
    end
  end
  return true
end

function pushBoxes(grid, new_pos, dir)
  box = grid[new_pos...]
  other_pos = box == BOXL ? (new_pos[1]+1, new_pos[2]) : (new_pos[1]-1, new_pos[2])
  other = grid[other_pos...]
  adj_positions = [ new_pos .+ (0, dir), other_pos .+ (0, dir) ]
  for adj in adj_positions
    adj_p = grid[adj...]
    if adj_p == BOXL || adj_p == BOXR
      pushBoxes(grid, adj, dir)
    end
  end
  grid[adj_positions[1]...] = box
  grid[adj_positions[2]...] = other
  grid[new_pos...] = EMPTY
  grid[other_pos...] = EMPTY
end

function apply(grid, instruction, fish)
  fishx, fishy = fish
  if instruction == '^'
    col = grid[fishx,:]
    new_pos = (fishx, fishy-1)
    p = grid[new_pos...]
    if p == WALL
      return fish
    end
    if p == EMPTY
      return new_pos
    end
    if p == BOXL || p == BOXR
      if !canPush(grid, new_pos, -1)
        return fish
      end
      pushBoxes(grid, new_pos, -1)
      return new_pos
    end
  end
  if instruction == 'v'
    col = grid[fishx,:]
    new_pos = (fishx, fishy+1)
    p = grid[new_pos...]
    if p == WALL
      return fish
    end
    if p == EMPTY
      return new_pos
    end
    if p == BOXL || p == BOXR
      if !canPush(grid, new_pos, 1)
        return fish
      end
      pushBoxes(grid, new_pos, 1)
      return new_pos
    end
  end
  if instruction == '<'
    row = grid[:,fishy]
    move = false
    boxesl = []
    boxesr = []
    for i in (fishx-1):-1:1
      p = row[i]
      if p == WALL
        break
      end
      if p == EMPTY
        move = true
        break
      end
      if p == BOXL
        push!(boxesl, i)
      end
      if p == BOXR
        push!(boxesr, i)
      end
    end
    if move
      for b in boxesl
        row[b-1] = BOXL
      end
      for b in boxesr
        row[b-1] = BOXR
      end
      grid[:,fishy] = row
      fish = (fishx-1 , fishy)
    end
  end
  if instruction == '>'
    row = grid[:,fishy]
    move = false
    boxesl = []
    boxesr = []
    for i in (fishx+1):length(row)
      p = row[i]
      if p == WALL
        break
      end
      if p == EMPTY
        move = true
        break
      end
      if p == BOXL
        push!(boxesl, i)
      end
      if p == BOXR
        push!(boxesr, i)
      end
    end
    if move
      for b in boxesl
        row[b+1] = BOXL
      end
      for b in boxesr
        row[b+1] = BOXR
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
  dims = size(grid)
  for i in axes(grid,1), j in axes(grid,2)
    if grid[i,j] == BOXL
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
  grid, fish = doubleUp(grid)
  @show instructions |> length, fish
  display(permutedims(grid))
  iterateGrid(grid, instructions, fish)
  @show "fin"
  display(permutedims(grid))
  @show gps(grid) |> sum
end
main(ARGS)
