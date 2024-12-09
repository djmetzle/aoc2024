function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parse_runs(line)
  blocks = []
  digits = parse.(Int, split(line, "")) 
  id = 0
  for i in eachindex(digits)
    digit = digits[i]
    if isodd(i)
      file = [ id for _ in 1:digit ]
      blocks = vcat(blocks, file)
      id += 1
    end
    if iseven(i)
      free = [ nothing for _ in 1:digit ]
      blocks = vcat(blocks, free)
    end
  end
  @show digits
  return blocks
end

function compact(blocks)
  compacted = copy(blocks)
  while findall(x -> x == nothing, compacted) |> length > 0
    tail = pop!(compacted)
    if tail == nothing
      continue
    end
    free = findall(x -> x == nothing, compacted)[1]
    compacted[free] = tail
  end
  return compacted
end

function checksum(blocks)
  return map(b -> (b[1]-1) * b[2], enumerate(blocks)) |> sum
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    line = readfile(filename)[1]
    blocks = parse_runs(line)
    @show blocks |> length
    @show "compacting..."
    compacted = compact(blocks)
    @show compacted
    @show compacted |> length
    @show checksum(compacted)
end
main(ARGS)
