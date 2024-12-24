using Combinatorics

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

OPS = Dict(
  "AND" => (x,y) -> x && y,
  "OR" => (x,y) -> x || y,
  "XOR" => (x,y) -> xor(x, y),
)

function buildCircuit(gates)
  circuit = Dict()
  for g in gates
    x, op, y, z = g
    opf = OPS[op]
    circuit[z] = (x, opf, y)
  end
  return circuit
end


function resolve(values, circuit, wire)
  x, op, y = circuit[wire]
  if !(haskey(values, x) && haskey(values, y))
    return nothing
  end  
  xv = values[x]
  yv = values[y]
  return op(xv, yv)
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

  rounds = 0
  max_rounds = length(keys(circuit))^2
  while length(unresolved) > 0
    for u in unresolved
      resolved = resolve(values, circuit, u)
      if !isnothing(resolved)
        values[u] = resolved
        delete!(unresolved, u)
      end
    end
    rounds += 1
    if rounds > max_rounds
      return nothing
    end
  end

  return values
end

function findPrefixInput(values, p)
  vkeys = filter(k -> k[1] == p, keys(values))  
  sorted_keys = sort([ k for k in vkeys ]) |> reverse
  vals = map(k -> values[k], sorted_keys) 
  str = map(v -> string(Int(v)), vals) |> join
  return parse(Int, str, base=2)
end

function findAnswer(values)
  return findPrefixInput(values, 'z')
end

function checkCircuit(values)
  x = findPrefixInput(values, 'x')
  y = findPrefixInput(values, 'y')
  z = findPrefixInput(values, 'z')
  @show (x+y, z, xor(x+y, z))
  return x + y == z
end

to_search = [
  "z10",
  "gvm",
  "smt",
  "wsd",
  "mbv",
  "rmc",
  "z11",
  "pbr",
  "ggn",
  "hks",
  "z39",
  "z40",
  "hdj",
  "psd",
  "twr",
  "bkd",
  "pqv",
  "bnv",
  "rgg",
  "nnq",
]

function allCiructSwaps(inputs, circuit)
  ckeys = keys(circuit)
  swaps = Set()
  for swap in Iterators.product(to_search, to_search)
    if swap[1] != swap[2]
      push!(swaps, Set([swap[1], swap[2]]))
    end
  end

  @show to_search

  for swapset in combinations([s for s in swaps], 4)
    @show swapset
    new_circuit = copy(circuit)
    for s in swapset
      sels = [ sel for sel in s ]
      a = sels[1]
      b = sels[2]
      av = circuit[a]
      bv = circuit[b]
      new_circuit[b] = av
      new_circuit[a] = bv
    end
    values = resolveValues(inputs, new_circuit)
    if !isnothing(values) && checkCircuit(values)
      return swapset
    end
  end
  
  return nothing
end

function findInvolved(circuit, values)
  x = findPrefixInput(values, 'x')
  y = findPrefixInput(values, 'y')
  z = findPrefixInput(values, 'z')
  xored = xor(x+y, z)
  bits = bitstring(UInt64(xored)) |> reverse
  involved = Set()
  for i in eachindex(bits)
    if bits[i] == '1'
      wire = 'z' * lpad(i, 2, "0")
      push!(involved, wire)
    end
  end
  ilen = 0
  while ilen != length(involved)
    for i in involved
      if haskey(circuit, i)
        x, _op, y = circuit[i]
        push!(involved, x)
        push!(involved, y)
      end
    end

    ilen = length(involved)
  end
    
  return involved
end

function searchGates(inputs, gates)
  circuit = buildCircuit(gates)
  values = resolveValues(inputs, circuit)
  return allCiructSwaps(inputs, circuit)
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  inputs, gates = parseInput(lines)
  @time swaps = searchGates(inputs, gates)
  @show swaps
end
main(ARGS)
