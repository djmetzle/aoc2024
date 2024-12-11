function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function nextStones(stones)
  for i in eachindex(stones)
    stone = stones[i]
    if stone == 0
      stones[i] = 1
      continue
    end
    if stone == 1
      stones[i] = 2024
      continue
    end
    len = length(string(stone))
    if iseven(len)
      half = div(len, 2)
      str = string(stone)
      l, r = parse(Int, str[1:half]), parse(Int, str[(half + 1):len])
      stones[i] = l
      push!(stones, r)
      continue
    end
    stones[i] = 2024 * stone
  end
end

function afterTimes(n, stones)
  afterStones = copy(stones)
  for i in 1:n
    nextStones(afterStones)
    @show i, afterStones |> length
  end
  return afterStones
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  stones = parse.(Int, split(readfile(filename)[1], " "))
  @show stones
  after = afterTimes(25, stones)
  @show after |> length
end
main(ARGS)
