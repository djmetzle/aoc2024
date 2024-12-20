using Memoization

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

function possiblities(colors, pattern)::Int
  @show pattern
  count = 0

  prefixes = colors
  while true
    @show length(prefixes)
    matching = []
    for p in prefixes 
      if p == pattern
        count += 1
        continue
      end
      for c in colors
        next_p = p * c
        p_regex = Regex('^' * next_p)
        if occursin(p_regex, pattern)
          push!(matching, next_p)
        end
      end
    end
    prefixes = matching
    isempty(prefixes) && break
  end

  @show count
  return count
end

function possible(colors, pattern)::Bool
  @show pattern

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

  @memoize function solve(p)
    @show p
    if length(p) == 0
      return 1
    end
    
    count = 0
    for c in colors
      if startswith(p, c)
        rem = p[(length(c)+1):length(p)]
        count += solve(rem)
      end
    end
  
    return count
  end
  @show map(solve, patterns) |> sum
end
main(ARGS)
