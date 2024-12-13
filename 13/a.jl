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
    push!(games, (a, b, prize))
  end
  return games
end

function solveGame(game)
  a, b, prize = game
  @show a, b, prize

  max_b = max(div(prize[1], b[1], RoundUp), div(prize[2], b[2], RoundUp) )

  for bi in max_b:-1:0
    left = prize .- (bi .* b)
    max_a = max(div(left[1], a[1], RoundUp), div(left[2], a[2], RoundUp) )
    for ai in max_a:-1:0
      if (ai .* a) .+ (bi .* b) == prize
        @show (ai, bi)
        return (ai, bi)
      end
    end
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
  @show solutions
  @show [ (3*s[1] + s[2]) for s in solutions ] |> sum
end
main(ARGS)
