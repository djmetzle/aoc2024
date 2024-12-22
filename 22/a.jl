function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

PRUNE = 16777216

function evolve(n)
  r = n << 6
  s = xor(r, n)
  t = s % PRUNE

  u = t >> 5
  v = xor(u, t)
  w = v % PRUNE

  x = w << 11
  y = xor(w, x) 
  z = y % PRUNE
  
  return z
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  secrets = map(i->parse(Int,i), lines)
  @show secrets

  results = []
  for l in secrets 
    for _ in 1:2000
      l = evolve(l)
    end
    push!(results, l)
  end

  @show results |> sum
end
main(ARGS)
