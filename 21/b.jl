using IterTools
using Memoization
using Combinatorics

# <<vA ^>>A vA ^A <<vA ^>>A A <<vA >A ^>A   A <A v>A  A ^A <vA ^>A A <A >A <<vA >A ^>A A A <A v>A ^A 
# <v<A >>^A vA ^A  <vA   <A A >>^A  A  vA <^A >A   A vA ^A <vA >^A A <A >A <v<A >A >^A A A vA <^A >A 
function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

DIR_KEYPAD = Dict(
  '^' => CartesianIndex(1,2),
  'A' => CartesianIndex(1,3),
  '<' => CartesianIndex(2,1),
  'v' => CartesianIndex(2,2),
  '>' => CartesianIndex(2,3),
)

NUMERIC_KEYPAD = Dict(
  '7' => CartesianIndex(1,1),
  '8' => CartesianIndex(1,2),
  '9' => CartesianIndex(1,3),
  '4' => CartesianIndex(2,1),
  '5' => CartesianIndex(2,2),
  '6' => CartesianIndex(2,3),
  '1' => CartesianIndex(3,1),
  '2' => CartesianIndex(3,2),
  '3' => CartesianIndex(3,3),
  '0' => CartesianIndex(4,2),
  'A' => CartesianIndex(4,3),
)

function parseKeys(line)
  return [ only(i) for i in split(line, "") ]
end

function getTranslation(translation)
  updown = ""
  leftright = ""

  if translation[1] < 0
    updown = '^'^abs(translation[1])
  end
  if translation[2] < 0
    leftright = '<'^abs(translation[2]) 
  end
  if translation[1] > 0
    updown = 'v'^translation[1]
  end
  if translation[2] > 0
    leftright = '>'^translation[2]
  end

  return updown, leftright
end

@memoize function shortNumeric(from, to)
  fromp = NUMERIC_KEYPAD[from]
  top = NUMERIC_KEYPAD[to]
  translation = top - fromp

  #@show translation
  
  updown, leftright = getTranslation(translation)

  q =  updown * leftright * "A"
  r = leftright * updown * "A"

  if leftright == "" || updown == ""
    return q
  end

  if fromp[1] == 4 && translation[2] + fromp[2] == 1
    return q
  end
  if fromp[2] == 1 && translation[1] + fromp[1] == 4
    return r
  end

  if translation[1] < 0 && translation[2] < 0
    return r
  end

  if translation[1] > 0 && translation[2] < 0
    return r
  end

  if translation[1] > 0 && translation[2] > 0
    return q
  end

  return q
end

@memoize function shortDir(from, to)
  fromp = DIR_KEYPAD[from]
  top = DIR_KEYPAD[to]
  translation = top - fromp
  
  updown, leftright = getTranslation(translation)

  q = leftright * updown * "A"
  r = updown * leftright * "A"

  if leftright == "" || updown == ""
    return q
  end

  if from == '<' 
    return q 
  end

  if to == '<' 
    return r
  end

  if to == '<'
    if from in ['v', '>']
      return q
    end
  end
  if from == '^' && to == '>'
    return r

  end
  if translation[1] < 0 && translation[2] < 0
    return q
  end

  if translation[1] > 0 && translation[2] < 0
    return q
  end

  if translation[1] > 0 && translation[2] > 0
    return r
  end
  return r
end

function expandPair(from, to)
  return length(shortDir(from, to))
end

@memoize function expandN(seq, n)
  if n == 1
    result = 0
    for (from, to) in IterTools.partition('A' * seq, 2, 1)
      result += expandPair(from, to)
    end
    return result
  end

  result = 0 
  for (from, to) in IterTools.partition('A' * seq, 2, 1)
    subseq = shortDir(from, to)
    result += expandN(subseq, n-1)  
  end
  return result
end

function findShortest(keycode)
  numeric = ""
  for (from, to) in IterTools.partition('A' * keycode, 2, 1)
    numeric *= shortNumeric(from, to)
  end
  return expandN(numeric, 25)
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)

  sequences = map(parseKeys, lines)

  sum = 0 
  for s in sequences
    @show s
    minseq = findShortest(join(s))
    numericportion = parse(Int, join(s[1:3]))
    @show minseq, numericportion
    sum += minseq * numericportion
  end
  @show sum
end
main(ARGS)
