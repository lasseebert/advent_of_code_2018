defmodule Advent.Day21 do
  @moduledoc """
  https://adventofcode.com/2018/day/21
  """

  import Bitwise

  @opcodes [
    :addr,
    :addi,
    :mulr,
    :muli,
    :banr,
    :bani,
    :borr,
    :bori,
    :setr,
    :seti,
    :gtir,
    :gtri,
    :gtrr,
    :eqir,
    :eqri,
    :eqrr
  ]

  @doc """
  The program terminates on line 29 if the input (reg0) is equal to the target(reg4)
  Simply always stop the program on line 29 and inspect reg4 to know which value should be in reg0.
  """
  def part1(input) do
    {ip, program} = parse(input)
    regs = Enum.into(0..5, %{}, fn i -> {i, 0} end)

    program
    |> Map.put(29, {:seti, 1000, nil, ip})
    |> run_program(regs, ip)
    |> Map.fetch!(4)
  end

  @doc """
  Same as part1, except that the target will loop at some point. We must find the value of the target just before
  it loops back to the first value (which is the part1 solution).

  To do this in a reasonable time, we need to replace the ineffecient loop in lines 17-26 with a simple div
  """
  def part2(input) do
    {ip, program} = parse(input)
    regs = Enum.into(0..5, %{}, fn i -> {i, 0} end)

    program =
      program
      # Halt on line 29
      |> Map.put(29, {:seti, 1000, nil, ip})
      # Replace loop with div
      |> Map.put(17, {:divi, 3, 256, 3})
      |> Map.put(18, {:seti, 7, nil, ip})

    find_last_target(program, regs, ip, :not_set, MapSet.new())
  end

  defp find_last_target(program, regs, ip, last_target, targets) do
    # Reset program to line 6, which is the right place to start after the halt on line 29
    regs = Map.put(regs, ip, 6)
    regs = run_program(program, regs, ip)
    target = Map.fetch!(regs, 4)

    if MapSet.member?(targets, target) do
      last_target
    else
      targets = MapSet.put(targets, target)
      find_last_target(program, regs, ip, target, targets)
    end
  end

  defp run_program(program, regs, ip) do
    index = read(regs, ip)

    case Map.fetch(program, index) do
      {:ok, instruction} ->
        regs = run_instruction(instruction, regs)
        regs = Map.update!(regs, ip, &(&1 + 1))
        run_program(program, regs, ip)

      :error ->
        regs
    end
  end

  defp run_instruction({:addr, a, b, c}, r), do: write(r, c, read(r, a) + read(r, b))
  defp run_instruction({:addi, a, b, c}, r), do: write(r, c, read(r, a) + b)
  defp run_instruction({:mulr, a, b, c}, r), do: write(r, c, read(r, a) * read(r, b))
  defp run_instruction({:muli, a, b, c}, r), do: write(r, c, read(r, a) * b)
  defp run_instruction({:banr, a, b, c}, r), do: write(r, c, read(r, a) &&& read(r, b))
  defp run_instruction({:bani, a, b, c}, r), do: write(r, c, read(r, a) &&& b)
  defp run_instruction({:borr, a, b, c}, r), do: write(r, c, read(r, a) ||| read(r, b))
  defp run_instruction({:bori, a, b, c}, r), do: write(r, c, read(r, a) ||| b)
  defp run_instruction({:setr, a, _b, c}, r), do: write(r, c, read(r, a))
  defp run_instruction({:seti, a, _b, c}, r), do: write(r, c, a)
  defp run_instruction({:gtir, a, b, c}, r), do: write(r, c, if(a > read(r, b), do: 1, else: 0))
  defp run_instruction({:gtri, a, b, c}, r), do: write(r, c, if(read(r, a) > b, do: 1, else: 0))
  defp run_instruction({:gtrr, a, b, c}, r), do: write(r, c, if(read(r, a) > read(r, b), do: 1, else: 0))
  defp run_instruction({:eqir, a, b, c}, r), do: write(r, c, if(a == read(r, b), do: 1, else: 0))
  defp run_instruction({:eqri, a, b, c}, r), do: write(r, c, if(read(r, a) == b, do: 1, else: 0))
  defp run_instruction({:eqrr, a, b, c}, r), do: write(r, c, if(read(r, a) == read(r, b), do: 1, else: 0))

  # Custom instruction that replaces a loop with a single div
  defp run_instruction({:divi, a, b, c}, r), do: write(r, c, div(read(r, a), b))

  defp read(regs, index), do: Map.fetch!(regs, index)
  defp write(regs, index, value), do: %{regs | index => value}

  defp parse(input) do
    [ip_line | program_lines] = String.split(input, "\n", trim: true)
    ip = parse_ip(ip_line)
    program = parse_program(program_lines)
    {ip, program}
  end

  defp parse_ip("#ip " <> ip_string), do: String.to_integer(ip_string)

  defp parse_program(program_lines) do
    program_lines
    |> Enum.map(&parse_program_line/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {inst, i} -> {i, inst} end)
  end

  defp parse_program_line(line) do
    [inst, a, b, c] = Regex.run(~r/^(.{4}) (\d+) (\d+) (\d+)$/, line, capture: :all_but_first)

    inst = parse_instruction(inst)
    a = String.to_integer(a)
    b = String.to_integer(b)
    c = String.to_integer(c)

    {inst, a, b, c}
  end

  for opcode <- @opcodes do
    opcode_string = Atom.to_string(opcode)
    def parse_instruction(unquote(opcode_string)), do: unquote(opcode)
  end
end
