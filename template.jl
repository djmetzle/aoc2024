function readfile(filename::String)
  @show filename
  lines = readlines(filename)
  return lines
end

function main(args)
  if length(args) != 1
    throw("no input!")
  end

  filename = args[1]
  lines = readfile(filename)
  @show lines
end
main(ARGS)
