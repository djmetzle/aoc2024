function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  return map(split, line)
end

function findInstructions(input)
  @show input
  matches = eachmatch(r"mul\((\d+),(\d+)\)", input) |> collect
  instructions = map(x -> (parse(Int, x[1]), parse(Int, x[2])), matches)
  return instructions
end

function findDoRuns(input)
  matches = eachmatch(r"(?:do\(\))(.*?)(?:don't\(\))", input) |> collect
  @show matches
  runs = map(r -> r[1], matches)
  return runs
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    input = "do()" * join(lines) * "don't()"
    runs = findDoRuns(input)
    @show runs
    instructions = map(findInstructions, runs) |> Iterators.flatten
    @show instructions
    @show sum(map(i -> i[1] * i[2], instructions))
end
main(ARGS)
