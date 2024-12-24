using Combinatorics

function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseMap(lines)
  computers = Set()
  connections = []
  for connect in map(l -> split(l, "-"), lines)
    push!(computers, connect[1], connect[2])
    push!(connections, (connect[1], connect[2]))
  end
  return [ c for c in computers ], connections
end

function connectedness(connections)
  connects = Dict()
  for (c1, c2) in connections
    if !haskey(connects, c1)
      connects[c1] = Set()
    end
    if !haskey(connects, c2)
      connects[c2] = Set()
    end
    push!(connects[c1], c2)
    push!(connects[c2], c1)
  end

  return connects
end

function allTriples(computers)
  return map(triplet -> Set(triplet), combinations(computers,3)) |> unique
end

function allConnected(connect_graph, subgraph)
  for c in subgraph
    neighbors = connect_graph[c]
    rest = setdiff(subgraph, [c])
    for r in rest
      if !(r in neighbors)
        return false
      end
    end
  end
  return true
end

function withTees(triplet)
  for c in triplet
    if c[1] == 't'
      return true
    end
  end
  return false
end

function findcliques(connect_graph)
  cliques = []
  for (c, neighbors) in connect_graph
    for ps in powerset([n for n in neighbors], 1)
      push!(cliques, union(Set([c]), ps))
    end
  end
  return cliques |> unique
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  computers, connections = parseMap(lines)
  connect_graph = connectedness(connections)

  cliques = findcliques(connect_graph)
  connected_cliques = filter(c -> allConnected(connect_graph, c), cliques)
  best = findmax(length, connected_cliques)
  biggest = sort([ c for c in connected_cliques[best[2]] ])
  @show join(biggest,",")
end
@time main(ARGS)
