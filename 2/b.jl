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

function all_with_missing(report)
  return [ deleteat!(copy(report), i) for i in 1:length(report) ]
end

function damper(report)
  with_missing = all_with_missing(report)
  return any(safe, with_missing)
end

function safe(report)
  pairs = IterTools.partition(report, 2, 1)
  for (i, j) in pairs
    if abs(j - i) > 3 || i == j
      return false
    end
  end
  monotonic_inc = p -> p[1] < p[2]
  monotonic_dec = p -> p[1] > p[2]
  return all(monotonic_inc, pairs) || all(monotonic_dec, pairs)
end

function damped_safe(report)
  return safe(report) || damper(report)
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    reports = parseInput(lines)
    @show count(damped_safe, reports)
end
main(ARGS)
