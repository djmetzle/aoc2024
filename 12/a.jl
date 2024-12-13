function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return split.(lines, "")
end

function inBounds(pos, dims)
  return 0 < pos[1] <= dims[1] && 0 < pos[2] <= dims[2]
end

ADJACENT = [(1,0), (-1, 0), (0, 1), (0, -1)]

function findNeighbors(grid, dims, i, j, neighbors)
  plant = grid[i][j]
  for a in ADJACENT
    neighbor_pos = (i,j) .+ a
    if inBounds(neighbor_pos, dims)
      neighbor_plant = grid[neighbor_pos[1]][neighbor_pos[2]]
      if plant == neighbor_plant && !((plant, neighbor_pos) in neighbors)
        push!(neighbors, (plant, neighbor_pos))
        findNeighbors(grid, dims, neighbor_pos[1], neighbor_pos[2], neighbors)
      end
    end
  end
  return neighbors
end

function findRegions(grid, plants)
  dims = (length(grid), length(grid[1]))
  regions = Set{Set{Tuple}}()
  for i in eachindex(grid)
    for j in eachindex(grid[i])
      plant = grid[i][j]
      neighbors = Set([(plant, (i,j))])
      push!(regions, findNeighbors(grid, dims, i, j, neighbors))
    end
  end
  return regions
end

function area(region)
  return region |> length
end

function perimeter(region)
  perimeter_total = 0
  for r in region
    plant = r[1]
    for a in ADJACENT
      neighbor_pos = r[2] .+ a
      if !((plant, neighbor_pos) in region)
        perimeter_total += 1
      end
    end
  end
  return perimeter_total
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  grid = readfile(filename)
  @show grid

  plants = unique(vcat(grid...))
  regions = findRegions(grid, plants)
  @show regions
  @show regions |> length
  prices = [ area(r) * perimeter(r) for r in regions ]
  @show prices
  @show prices |> sum
end
main(ARGS)