function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function nextStones(stones)
  dict = Dict{BigInt, BigInt}()
  stonens = sort(keys(stones) |> collect)
  for stone in stonens
    current = get(stones, stone, 0)
    if stone == 0
      dict[1] = current
      continue
    end
    if stone == 1
      dict[2024] = current + get(dict, 2024, 0)
      continue
    end
    len = length(string(stone))
    if iseven(len)
      half = div(len, 2)
      str = string(stone)
      l, r = parse(BigInt, str[1:half]), parse(BigInt, str[(half + 1):len])
      dict[l] = current + get(dict, l, 0)
      dict[r] = current + get(dict, r, 0)
      continue
    end
    dict[2024 * stone] = current + get(dict, 2024 * stone, 0)
  end
  return dict
end

function toDict(stones)
  dict = Dict{BigInt, BigInt}()
  for stone in stones
    dict[stone] = get(dict, stone, 0) + 1
  end
  return dict
end

function afterTimes(n, stones)
  iterStones = toDict(stones)
  for i in 1:n
    iterStones = nextStones(iterStones)
    @show i
  end
  return iterStones
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  stones = parse.(BigInt, split(readfile(filename)[1], " "))
  after = afterTimes(75, stones)
  @show after |> values |> sum
end
main(ARGS)
