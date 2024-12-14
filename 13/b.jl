function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function buildGames(lines)
  games = []
  for i in 1:4:length(lines)
    a_matches = match(r"Button A: X\+(\d+), Y\+(\d+)", lines[i + 0])
    a = (parse(Int, a_matches[1]), parse(Int, a_matches[2]))
    b_matches = match(r"Button B: X\+(\d+), Y\+(\d+)", lines[i + 1])
    b = (parse(Int, b_matches[1]), parse(Int, b_matches[2]))
    prize_matches = match(r"Prize: X=(\d+), Y=(\d+)", lines[i + 2])
    prize = (parse(Int, prize_matches[1]), parse(Int, prize_matches[2]))
    push!(games, (a, b, 10000000000000 .+ prize))
  end
  return games
end

function solveGame(game)
  a, b, prize = game
  @show a, b, prize

  A = [ a[1] b[1]; a[2] b[2] ]  
  invA = inv(A)
  p = [ p for p in prize ]
  sol = round.(Int, invA * p)
  if sol[1] .* a .+ sol[2] .* b == prize
    @show sol
    return (sol[1], sol[2])
  end

  return nothing
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  games = buildGames(lines)
  solutions = [ solveGame(g) for g in games ] |> filter(x -> !isnothing(x))
  @show [ (3*s[1] + s[2]) for s in solutions ] |> sum
end
main(ARGS)
