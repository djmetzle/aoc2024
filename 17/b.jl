function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

global output = []

#  0: 2,4 = bst B = A % 8
#  2: 1,7 = bxl B = B xor 7
#  4: 7,5 = cdv C = A / B
#  6: 1,7 = bxl B = B xor 7
#  8: 0,3 = adv A = A / 3
# 10: 4,1 = bxc B = B xor C
# 12: 5,5 = out B
# 14: 3,0 = jnz 0
# bst, bxl, cdv, bxl, adv, bxc, out, jnz
INSTRUCTION_SET = Dict(
  # adv
  0 => function(registers, op, ip)
    regA, regB, regC = registers
    value = 2 ^ comboLookup(registers, op)
    regA = div(regA, value)
    registers = (regA, regB, regC)
    return registers, ip+2
  end,
  # bxl
  1 => function(registers, op, ip)
    regA, regB, regC = registers
    regB = regB ⊻ op
    registers = (regA, regB, regC)
    return registers, ip+2
  end,
  # bst
  2 => function(registers, op, ip)
    regA, regB, regC = registers
    value = comboLookup(registers, op) % 8
    registers = (regA, value, regC)
    return registers, ip+2
  end,
  # jnz
  3 => function(registers, op, ip)
    regA, regB, regC = registers
    if regA == 0
      return registers, ip+2
    end
    return registers, op
  end,
  # bxc
  4 => function(registers, op, ip)
    regA, regB, regC = registers
    regB = regB ⊻ regC
    registers = (regA, regB, regC)
    return registers, ip+2
  end,
  # out
  5 => function(registers, op, ip)
    global output
    value = comboLookup(registers, op) % 8
    push!(output, value)
    return registers, ip+2
  end,
  # bdv
  6 => function(registers, op, ip)
    regA, regB, regC = registers
    value = 2 ^ comboLookup(registers, op)
    regB = div(regA, value)
    registers = (regA, regB, regC)
    return registers, ip+2
  end,
  # cdv
  7 => function(registers, op, ip)
    regA, regB, regC = registers
    value = 2 ^ comboLookup(registers, op)
    regC = div(regA, value)
    registers = (regA, regB, regC)
    return registers, ip+2
  end,
)

function comboLookup(registers, op)
  if op in 0:3
    return op
  end
  if op in 4:6
    return registers[op-3]
  end
  if op == 7
    throw("INVALID OPERAND")
  end
end

function parseInput(lines)
  a_match = match(r"Register A: (\d+)", lines[1])
  regA = parse(Int, a_match[1])
  b_match = match(r"Register B: (\d+)", lines[2])
  regB = parse(Int, b_match[1])
  c_match = match(r"Register C: (\d+)", lines[3])
  regC = parse(Int, c_match[1])
  registers = (regA, regB, regC)
  #@show registers

  program_matches = match(r"Program: ([,\d]+)", lines[5])
  instructions_strs = split(program_matches[1], ',') |> collect
  instructions = map(i -> parse(Int, i), instructions_strs)
  return registers, instructions
end

function process(registers, program, ip)
  instruction = program[ip+1]
  operand = program[ip+2]
  op = INSTRUCTION_SET[instruction]
  #@show registers, instruction, operand, ip
  registers, ip = op(registers, operand, ip)
  # @show instruction, registers
  return registers, ip
end

function run(registers, program)
  global output = []
  ip = 0
  while ip < length(program) - 1
    registers, ip = process(registers, program, ip)
  end
  #@show registers
  return output
end

function fastrun(a)
  output = Int64[]
  while a > 0
    o = fastprocess(a)
    push!(output, o)
    a = a >> 3
  end
  return output
end

function fastprocess(a)
  return ((a % 8) ⊻ (a ÷ (1 << ((a % 8) ⊻ 7)))) % 8
end

function checkA(a, output)
  return fastprocess(a) == output
end

function stepreverse(Apos, program, output)
  nextAs = []

  for a in Apos
    for i in 0:63
      next_a = i + a << 3
      if checkA(next_a, output)
        push!(nextAs, next_a)
      end
    end
  end
  @show nextAs

  return nextAs |> unique
end

#  0: 2,4 = bst B = A % 8
#  2: 1,7 = bxl B = B xor 7
#  4: 7,5 = cdv C = A / 2^B
#  6: 1,7 = bxl B = B xor 7
#  8: 0,3 = adv A = A >> 3
# 10: 4,1 = bxc B = B xor C
# 12: 5,5 = out B % 8
# 14: 3,0 = jnz 0
function runreverse(program)
  possibles = [0]
  expected_outputs = reverse(program)
  # we know how to get zero
  popfirst!(expected_outputs)
  for o in expected_outputs
    possibles = stepreverse(possibles, program, o)
    @show o, possibles |> length
  end
  return possibles
end

function fromDigits(digits)
  sum = 0
  for i in eachindex(digits)
    sum += digits[i] << (3 * (16 - i))
  end
  return sum
end

function hunt(program)
  rev = reverse(program)
  last_results = [0]
  for i in eachindex(rev)
    results = []
    tail = program[(16-(i-1)):16]
    for r in last_results
      for n in 0:7
        next = n + (r << 3)
        outputr = fastrun(next)
        @show next, i, rev[i], outputr, tail
        ol = length(outputr)
        tl = length(tail)
        if outputr == tail
          push!(results, next)
        end
      end
    end
    @show results
    last_results = results |> unique

  end
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  #@show lines
  registers, program = parseInput(lines)
  #@show registers, program

  #output = run(registers, program)
  #@show output
  hunt(program)

  lastA = 0
  digitsl = [3, 3, 7, 0, 0, 3, 7, 2, 7, 5, 1, 1, 1, 2, 4, 7] |> reverse
  A = fromDigits(digitsl)
  A = 265601188299675
  start = [2, 4, 1, 7, 7, 5, 1, 7, 0]
  sl = length(start)
  while true
    outputr = fastrun(A)
    if outputr == program
      @show "FOUND"
      @show outputr
      @show program
      @show bitstring(A)
      @show A
      return
    end
    if outputr[1:sl] == start
      @show "FOUND START"
      @show outputr
      @show program
      @show bitstring(A)
      @show A
    end
    A += 1
  end
  return
end
main(ARGS)
