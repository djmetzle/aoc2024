function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function parseLines(lines)
  seperated = split.(lines, ": ")
  return map(s -> (parse(Int, s[1]), parse.(Int, split(s[2], " "))), seperated)
end

function digitconcat(a, b)
  return parse(Int, string.(a,b))
end

function fastdigitconcat(a,b)
  # defunct!
  base = 10^round(Int, log10(b), RoundUp)
  return a * base + b
end

function solvable(equation)
  result, terms = equation
  operations = vec(collect(Base.Iterators.product(Base.Iterators.repeated((+, *, digitconcat), length(terms)-1)...)))
  for ops in operations
    t = copy(terms) 
    for i in eachindex(ops)
      op = ops[i]
      first_el = popfirst!(t)
      t[1] = op(first_el, t[1])
    end
    if sum(t) == result 
      @show result, terms
      @show ops
      return true
    end
  end
  return false
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    equations = parseLines(lines)
    solved = filter(solvable, equations)
    @show sum([s[1] for s in solved])
end
main(ARGS)
