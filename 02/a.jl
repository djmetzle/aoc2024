using IterTools

function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  splitAndCast = line -> map(n -> parse(Int, n), split(line))
  return map(splitAndCast, lines)
end

function safe(report)
  pairs = IterTools.partition(report, 2, 1)

  in_threshold = p -> 1 <= abs(p[2] - p[1]) <= 3
  monotonic_inc = p -> p[1] < p[2]
  monotonic_dec = p -> p[1] > p[2]

  return all(in_threshold, pairs) &&
    ( all(monotonic_inc, pairs) || all(monotonic_dec, pairs) )
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    reports = parseInput(lines)
    @show count(safe, reports)
end
main(ARGS)
