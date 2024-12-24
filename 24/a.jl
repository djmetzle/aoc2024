function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInputs(input_lines)
  inputs = []
  for l in input_lines
    line_matches = match(r"(\w+): (1|0)", l)
    wire, value = line_matches[1], parse(Bool, line_matches[2])
    push!(inputs, (wire, value))
  end
  return inputs
end

function parseGates(gate_lines)
  gates = []
  for l in gate_lines
    line_matches = match(r"(\w+) (\w+) (\w+) -> (\w+)", l)
    x = line_matches[1]
    op = line_matches[2]
    y = line_matches[3]
    z = line_matches[4]
    push!(gates, (x, op, y, z))
  end
  return gates
end

function parseInput(lines)
  seperator = findfirst(l -> l == "", lines)
  input_lines = lines[1:(seperator - 1)]
  gate_lines = lines[(seperator + 1):length(lines)]

  return parseInputs(input_lines), parseGates(gate_lines)
end

function buildCircuit(gates)
  circuit = Dict()
  for g in gates
    x, op, y, z = g
    @show x, op, y, z
    circuit[z] = (x, op, y)
  end
  return circuit
end

OPS = Dict(
  "AND" => (x,y) -> x && y,
  "OR" => (x,y) -> x || y,
  "XOR" => (x,y) -> xor(x, y),
)

function resolve(values, circuit, wire)
  x, op, y = circuit[wire]
  @show x, op, y
  if !(haskey(values, x) && haskey(values, y))
    return nothing
  end  
  xv = values[x]
  yv = values[y]
  return OPS[op](xv, yv)
end

function resolveValues(inputs, circuit)
  values = Dict()
  for i in inputs   
    values[i[1]] = i[2]
  end
  unresolved = Set()
  for k in keys(circuit)
    push!(unresolved, k)
  end

  while length(unresolved) > 0
    for u in unresolved
      resolved = resolve(values, circuit, u)
      if !isnothing(resolved)
        values[u] = resolved
        delete!(unresolved, u)
      end
    end
  end

  return values
end

function findAnswer(values)
  zkeys = filter(k -> k[1] == 'z', keys(values))  
  sorted_zkeys = sort([ z for z in zkeys ]) |> reverse
  zvals = map(z -> values[z], sorted_zkeys) 
  zstr = map(zv -> string(Int(zv)), zvals) |> join
  return parse(Int, zstr, base=2)
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  inputs, gates = parseInput(lines)
  circuit = buildCircuit(gates)
  values = resolveValues(inputs, circuit)
  @show findAnswer(values)
end
main(ARGS)
