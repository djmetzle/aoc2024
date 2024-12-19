function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseInput(lines)
  colors = String.(split(lines[1], ", "))
  patterns = lines[3:length(lines)]
  return colors, patterns
end

function possible(colors, pattern)::Bool
  @show pattern
  if !any(occursin.(colors, pattern))
    return false
  end

  return occursin(colorsRegex(colors), pattern)

  return false

  @show "fallback!"
  cur_patterns = colors 
  while length(cur_patterns) > 0
    for p in cur_patterns
      if p == pattern
        @show "Found"
        return true
      end
    end

    matching = []
    for c in cur_patterns
    end
    matching = filter(p -> p == pattern[1:(min(length(pattern),length(p)))], cur_patterns)
    @show length(matching)
    cur_patterns = vec(collect(map(join, Iterators.product(matching, colors))))
  end
  
  return false
end

function colorsRegex(colors)
  @show colors
  joined = join(colors, "|")
  return Regex("^(" * joined * ")+\$")
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  colors, patterns = parseInput(lines)
  @show colors
  @show map(length, patterns) |> maximum
  filter_possible = i -> possible(colors, i)
  @show filter(filter_possible, patterns) |> length
end
main(ARGS)
