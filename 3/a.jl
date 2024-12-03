function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  return map(split, line)
end

function findInstructions(input)
  matches = eachmatch(r"mul\((\d+),(\d+)\)", input) |> collect
  instructions = map(x -> (parse(Int, x[1]), parse(Int, x[2])), matches)
  return instructions
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    input = join(lines)
    instructions = findInstructions(input)
    @show sum(map(prod, instructions))
end
main(ARGS)
