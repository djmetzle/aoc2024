function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parse_runs(line)
  digits = parse.(Int, split(line, "")) 
  id = 0
  blocks = []
  ids = []
  frees = []
  for i in eachindex(digits)
    digit = digits[i]
    if isodd(i)
      file = [ id for _ in 1:digit ]
      fileindex = length(blocks) + 1
      push!(ids, (fileindex, id, digit))
      blocks = vcat(blocks, file)
      id += 1
    end
    if iseven(i)
      free = [ nothing for _ in 1:digit ]
      freeindex = length(blocks) + 1
      push!(frees, (freeindex, digit))
      blocks = vcat(blocks, free)
    end
  end
  @show digits
  return blocks, ids, frees
end

function nofragcompact(compacted, ids, frees)
  @show ids
  for (i, id, len) in reverse(ids)
    for (fj, (f, free)) in enumerate(frees)
      if free >= len && f < i
        compacted[f:(f+len-1)] .= id
        compacted[i:(i+len-1)] .= nothing
        push!(frees, (i, len))
        sort!(frees, by=x->x[1])
        if free > len
          left = free - len
          frees[fj] = (f + len, left) 
          break
        end
        deleteat!(frees, fj)
        break
      end
    end
  end
  return compacted
end

function checksum(blocks)
  return map(b -> (b[1]-1) * something(b[2], 0), enumerate(blocks)) |> sum
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    line = readfile(filename)[1]
    blocks, ids, frees = parse_runs(line)
    @show ids
    @show frees
    @show blocks |> length
    @show "compacting..."
    compacted = nofragcompact(blocks, ids, frees)
    @show compacted
    @show compacted |> length
    @show checksum(compacted)
end
main(ARGS)
