function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  return map(split, line)
end

function findInstructions(input)
  matches = map(line -> eachmatch(r"mul\((\d+),(\d+)\)", line) |> collect, input) |> Iterators.flatten
  instructions = map(x -> (parse(Int, x[1]), parse(Int, x[2])), matches)
  return instructions
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    instructions = findInstructions(lines)
    @show sum(map(i -> i[1] * i[2], instructions))
end
main(ARGS)
