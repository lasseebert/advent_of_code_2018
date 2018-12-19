defmodule Advent.Day19 do
  @moduledoc """
  https://adventofcode.com/2018/day/19
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

  def part1(input) do
    {ip, program} = parse(input)

    regs = Enum.into(0..5, %{}, fn i -> {i, 0} end)

    program
    |> run_program(regs, ip)
    |> Map.fetch!(0)
  end

  @doc """
  The opcodes translates to this:

      large_number = 10551264
      result = 0

      for(a = 1, a <= large_number, a++) {
        for(b = 1, b <= large_number, b++) {
          if a * b == large_number, do: result += a
        }
      }

  I.e., it finds the sum of factors of a large number in a naive way.
  """
  def part2(input) do
    {ip, program} = parse(input)

    regs = Enum.into(0..5, %{}, fn i -> {i, 0} end) |> Map.put(0, 1)

    large_number =
      program
      # Stop program after large_number is calculated on line 35
      |> Map.put(35, {:mulr, ip, ip, ip})
      |> run_program(regs, ip)
      # large_number is in registry 5
      |> Map.fetch!(5)

    large_number
    |> prime_factors()
    |> factors()
    |> Enum.sum()
  end

  defp prime_factors(n) do
    prime_factors(n, 2, [])
  end

  defp prime_factors(1, _i, acc), do: Enum.reverse(acc)

  defp prime_factors(n, i, acc) do
    if rem(n, i) == 0 do
      prime_factors(div(n, i), i, [i | acc])
    else
      prime_factors(n, i + 1, acc)
    end
  end

  defp factors([n]), do: [1, n]

  defp factors([first | rest]) do
    ([
       first
       | Enum.flat_map(rest, fn other ->
           factors([first * other | List.delete(rest, other)])
         end)
     ] ++ factors(rest))
    |> Enum.uniq()
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
