function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

PRUNE = 16777216

function evolve(n)
  r = n << 6
  s = xor(r, n)
  t = s % PRUNE

  u = t >> 5
  v = xor(u, t)
  w = v % PRUNE

  x = w << 11
  y = xor(w, x)
  z = y % PRUNE

  return z
end

function allSequences()
  spread = [ i for i::Int8 in -9:9 ]
  return collect(Iterators.product(spread, spread, spread, spread)) |> vec
end

function marketSequences(market)
  prices = []
  for mi in eachindex(market)
    @show "market", mi
    m = market[mi]
    push!(prices, Dict())
    for i in 1:(length(m) - 3)
      curseq = map(p -> p[2], m[i:(i+3)])
      if !haskey(prices[mi], curseq)
        prices[mi][curseq] = m[i+3][1]
      end
    end
  end
  return prices
end

function price(marketseqs, sequence)
  seq = [ s for s in sequence ]
  prices = map(prices -> get(prices, seq, 0), marketseqs)
  return reduce(+, prices, init=0)
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  secrets = map(i->parse(Int,i), lines)
  @show secrets

  banana_price = s -> parse(Int8, last(string(s)))

  market = []
  for l in secrets
    bs = []
    last_price = banana_price(l)
    for _ in 1:2000
      next_l = evolve(l)
      price = banana_price(next_l)
      push!(bs, (price, price - last_price))
      l = next_l
      last_price = price
    end
    push!(market, bs)
  end

  allseqs = allSequences()
  marketseqs = marketSequences(market)
  @show "built market"

  priceForMarket = s -> price(marketseqs, s)

  @show maximum(priceForMarket, allseqs)
end
main(ARGS)
