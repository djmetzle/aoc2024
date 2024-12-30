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

function keyseq(map, from, to)
  seq = []
  start_pos = map[from]
  end_pos = map[to]
  translation = end_pos - start_pos

  if translation[1] < 0
    push!(seq, '^'^abs(translation[1]))
  end
  if translation[2] < 0
    push!(seq, '<'^abs(translation[2]))
  end
  if translation[1] > 0
    push!(seq, 'v'^translation[1]) 
  end
  if translation[2] > 0
    push!(seq, '>'^translation[2]) 
  end
  push!(seq, 'A')
  all_chars = join(seq)
  return all_chars 
end

@memoize function keyseqs(map, from, to)
  seq = []
  start_pos = map[from]
  end_pos = map[to]
  translation = end_pos - start_pos

  if translation[1] < 0
    push!(seq, '^'^abs(translation[1]))
  end
  if translation[2] < 0
    push!(seq, '<'^abs(translation[2]))
  end
  if translation[1] > 0
    push!(seq, 'v'^translation[1]) 
  end
  if translation[2] > 0
    push!(seq, '>'^translation[2]) 
  end

  seqs = []
  for s in permutations(seq, length(seq))
    q = join(s) * "A"
    fromp = map[from]
    top = map[to]
    if map == NUMERIC_KEYPAD
      if fromp[1] == 4 && abs(translation[2]) == (fromp[2]-1)
        if q[1] == '<'
          continue
        end
      end
      if fromp[2] == 1 && abs(translation[1]) == (4-fromp[1])
        if q[1] == 'v'
          continue
        end
      end
    end
    if map == DIR_KEYPAD 
      if fromp[1] == 1 && abs(translation[2]) == (fromp[2]-1)
        if q[1] == '<'
          continue
        end
      end
      if fromp[2] == 1 && translation[1] == -1
        if q[1] == '^'
          continue
        end
      end
    end
    push!(seqs, q)
  end
  return seqs
end

function seqDir(keycodes)
  last = 'A'
  presses = []

  for k in keycodes
    push!(presses, keyseq(DIR_KEYPAD, last, k))
    last = k
  end
   
  return join(presses)
end

function seqDirs(keycodes)
  last = 'A'
  seqs = []
  for k in keycodes
    push!(seqs, keyseqs(DIR_KEYPAD, last, k))
    last = k
  end
  allSeqs  = [""]
  for i in eachindex(seqs)
    nextSeqs = []
    for a in allSeqs
      for s in seqs[i]
        push!(nextSeqs, a * s)
      end
    end
    allSeqs = nextSeqs
  end
   
  return allSeqs
end

function seqNumerics(keycodes)
  last = 'A'
  seqs = []
  for k in keycodes
    push!(seqs, keyseqs(NUMERIC_KEYPAD, last, k))
    last = k
  end
  
  allSeqs  = [""]
  for i in eachindex(seqs)
    nextSeqs = []
    for a in allSeqs
      for s in seqs[i]
        push!(nextSeqs, a * s)
      end
    end
    allSeqs = nextSeqs
  end
  return allSeqs
end

function demo()
  npad = fill(' ', 4, 3)
  for i in keys(NUMERIC_KEYPAD)
    pos = NUMERIC_KEYPAD[i]
    npad[pos] = i
  end
  display(npad)

  dpad = fill(' ', 2, 3)
  for i in keys(DIR_KEYPAD)
    pos = DIR_KEYPAD[i]
    dpad[pos] = i
  end
  display(dpad)
end

function findShortest(keycode)
  numerics = seqNumerics(keycode)
  dirs = map(seqDirs, numerics)
  twice = map(s->map(seqDirs,s), dirs)
  return twice |> Iterators.flatten |> Iterators.flatten
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)

  @show demo()

  sequences = map(parseKeys, lines)

  sum = 0 
  for s in sequences
    @show s
    shortest = findShortest(s)
    #@show shortest
    minseq = map(length, shortest) |> minimum
    numericportion = parse(Int, join(s[1:3]))
    @show minseq, numericportion
    sum += minseq * numericportion
  end
  @show sum
end
main(ARGS)
