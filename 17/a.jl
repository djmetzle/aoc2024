function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

global output = []

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
  @show registers, instruction, operand, ip
  registers, ip = op(registers, operand, ip)
  return registers, ip
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

  ip = 0
  while ip < length(program) - 1
    registers, ip = process(registers, program, ip)
  end
  
  global output
  @show join(output, ",")
end
main(ARGS)
