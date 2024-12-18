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
  @show registers

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
  @show instruction, registers
  return registers, ip
end

function run(registers, program)
  global output = []
  ip = 0
  while ip < length(program) - 1
    registers, ip = process(registers, program, ip)
  end
  @show registers
  return output
end

function nexttrys(a,n)
  next = []
  for i in 0:7
    push!(next, a + (i << (3*n)))
  end
  return next
end

function fails()
  p =            [2, 4, 1, 7, 7, 5, 1, 7, 0, 3, 4, 1, 5, 5, 3, 0]
  flipped = Int64[7, 4, 2, 2, 6, 3, 4, 7, 0, 6, 2, 0, 0, 6, 3, 5]
  p =            [7, 4, 2, 1, 6, 3, 4, 4, 0, 7, 2, 0, 0, 6, 3, 5] |> reverse
  x = 7<<(4*3) + 4<<(3*3) + 2<<(2*3) + 2<<(1*3) + 6<<(0*3)
  y = 0
  for i in eachindex(p)
    f = p[i]
    y += f<<(i*3)
  end
  return y
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  @show lines
  registers, program = parseInput(lines)
  @show registers, program

  output = run(registers, program)
  for a in [fails()]
    @show a
    registers = (a, 0, 0)
    output = run(registers, program)
    @show a, registers, output, output |> length
    if output == program
      @show "FOUND"
      @show a, registers, output, output |> length
      return
    end
  end
end
main(ARGS)
