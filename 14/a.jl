function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function dims(line)
  ds = split(line, ",")
  return (parse(Int, ds[1]), parse(Int, ds[2]))
end

function parseLine(line)
  parse_i = i -> parse(Int, i)
  m = match(r"p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)", line)
  p = (parse_i(m[1]), parse_i(m[2]))
  v = (parse_i(m[3]), parse_i(m[4]))
  return (p, v)
end

function advance(robots, roomsize, n)
  after = []
  for robot in robots
    p = robot[1]
    v = robot[2]
    final = mod.((n .* v) .+ p, roomsize)
    push!(after, final)
  end
  return after
end

function quadCounts(bot_pos, roomsize)
  half = round.(Int, (roomsize .- 1) ./ 2)
  counts = [0, 0, 0, 0]
  for p in bot_pos
    if p[1] < half[1]
      if p[2] < half[2]
        counts[1] += 1
      end
      if p[2] > half[2]
        counts[2] += 1
      end
    end
    if p[1] > half[1]
      if p[2] < half[2]
        counts[3] += 1
      end
      if p[2] > half[2]
        counts[4] += 1
      end
    end
  end
  return counts
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  roomsize = dims(popfirst!(lines))
  @show roomsize
  robots = map(parseLine, lines)
  @show robots |> length
  after = advance(robots, roomsize, 100)
  @show after
  counts = quadCounts(after, roomsize)
  @show counts
  @show prod(counts)
end
main(ARGS)