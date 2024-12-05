function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function splitInput(lines)
  separator_index = findall(l -> l == "", lines) |> first
  orderings = lines[1:(separator_index-1)]
  pages = lines[(separator_index+1):length(lines)]
  return orderings, pages
end

function buildOrderDict(orderings)
  pairs = map(o -> split(o,"|"), orderings)
  orders = map(p -> map(el -> parse(Int, el), p), pairs)
  keys = map(o -> [o[1], [] ], orders)
  order_dict = Dict(keys)

  for order in orders
    push!(order_dict[order[1]], order[2])
  end

  return order_dict
end

function center(pages)
  pagenumbers = map(n -> parse(Int, n), split(pages, ","))
  return pagenumbers[(length(pagenumbers) + 1) ÷ 2] 
end

function correctOrder(order_dict, pages)
  pagenumbers = map(n -> parse(Int, n), split(pages, ","))
  for i in eachindex(pagenumbers)
    p_i = pagenumbers[i]
    for j in eachindex(pagenumbers)
      p_j = pagenumbers[j]
      if i < j && p_j in keys(order_dict)
        if p_i in order_dict[p_j]
          return false
        end
      end
      if i > j && p_i in keys(order_dict)
        if p_j in order_dict[p_i]
          return false
        end
      end
    end
  end
  return true
end

function main(args)
    if length(args) != 1
      throw("no input!")
    end

    filename = args[1]
    lines = readfile(filename)
    orderings, pages = splitInput(lines)

    order_dict = buildOrderDict(orderings)

    correct = [ pageset for pageset in pages if correctOrder(order_dict, pageset) ]
    centers = [ center(c) for c in correct ]
    @show sum(centers)
end
main(ARGS)
