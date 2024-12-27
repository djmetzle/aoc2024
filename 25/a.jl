function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  blocks = []
  accum = []
  for l in lines
    if l == ""
      push!(blocks, accum)
      accum = []
      continue
    end
    push!(accum, l)
  end
  push!(blocks, accum)

  return parseBlocks(blocks)
end

function mapBlock(block)
  schematic = falses(7,5)
  for l in eachindex(block)
    for p in eachindex(split(block[l],""))
      schematic[l,p] = block[l][p] == '#'
    end
  end
  return [ (count(c) - 1) for c in eachcol(schematic) ]
end

function parseBlocks(blocks)
  locks = []
  keys = []
  for b in blocks
    if b[1] == "#####"
      lock = map(pin -> pin, mapBlock(b))
      push!(locks, lock)
    end
    if b[7] == "#####"
      push!(keys, mapBlock(b))
    end
  end
  return locks, keys
end

function allFits(locks, keys)
  fit = []
  for l in locks
    for k in keys
      @show (l, k)

      if all(h -> h <= 5, map(abs, (k .+ l)))
        push!(fit, (l,k))
      end
    end
  end
  return fit
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  locks, keys = parseInput(lines)
  fit = allFits(locks, keys)
  @show fit
  @show fit |> length
end
main(ARGS)
