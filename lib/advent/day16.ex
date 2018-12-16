defmodule Advent.Day16 do
  @moduledoc """
  https://adventofcode.com/2018/day/16
  """

  import Bitwise

  def part1(input) do
    {samples, _program} = parse(input)

    samples
    |> Enum.map(&count_sample_behaviours/1)
    |> Enum.count(&(&1 >= 3))
  end

  def part2(input) do
    {samples, program} = parse(input)
    regs = {0, 0, 0, 0}

    opcode_mapping = find_opcode_mapping(samples)

    program
    |> replace_opcodes(opcode_mapping)
    |> run_program(regs)
    |> elem(0)
  end

  defp run_program(program, regs) do
    Enum.reduce(program, regs, &run_instruction/2)
  end

  defp replace_opcodes(program, mapping) do
    Enum.map(program, fn {number, a, b, c} -> {Map.fetch!(mapping, number), a, b, c} end)
  end

  defp find_opcode_mapping(samples) do
    mapping = 0..15 |> Enum.into(%{}, &{&1, all_opcodes()})

    samples
    |> Enum.reduce(mapping, fn {reg1, {number, a, b, c}, reg2}, mapping ->
      case Map.fetch!(mapping, number) do
        opcode when is_atom(opcode) ->
          mapping

        [_single] ->
          mapping

        opcodes ->
          opcodes = opcodes |> Enum.filter(fn opcode -> run_instruction({opcode, a, b, c}, reg1) == reg2 end)

          if length(opcodes) == 1 do
            [opcode] = opcodes

            mapping
            |> delete_mapping_opcode(opcode)
            |> Map.put(number, opcode)
          else
            Map.put(mapping, number, opcodes)
          end
      end
    end)
  end

  defp delete_mapping_opcode(mapping, opcode_to_delete) do
    {mapping, next} =
      mapping
      |> Enum.reduce({mapping, []}, fn
        {_number, opcode}, {mapping, acc} when is_atom(opcode) ->
          {mapping, acc}

        {number, opcodes}, {mapping, acc} ->
          opcodes = List.delete(opcodes, opcode_to_delete)

          if length(opcodes) == 1 do
            [opcode] = opcodes
            {Map.put(mapping, number, opcode), [opcode | acc]}
          else
            {Map.put(mapping, number, opcodes), acc}
          end
      end)

    next
    |> Enum.reduce(mapping, &delete_mapping_opcode(&2, &1))
  end

  defp count_sample_behaviours({before_reg, {_, a, b, c}, after_reg}) do
    Enum.count(all_opcodes(), fn opcode -> run_instruction({opcode, a, b, c}, before_reg) == after_reg end)
  end

  defp all_opcodes() do
    [
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

  defp read({a, _b, _c, _d}, 0), do: a
  defp read({_a, b, _c, _d}, 1), do: b
  defp read({_a, _b, c, _d}, 2), do: c
  defp read({_a, _b, _c, d}, 3), do: d

  defp write({_a, b, c, d}, 0, v), do: {v, b, c, d}
  defp write({a, _b, c, d}, 1, v), do: {a, v, c, d}
  defp write({a, b, _c, d}, 2, v), do: {a, b, v, d}
  defp write({a, b, c, _d}, 3, v), do: {a, b, c, v}

  defp parse(input) do
    {samples, program_lines} =
      input
      |> String.split("\n\n", trim: true)
      |> parse_samples()

    program = parse_program(program_lines)
    {samples, program}
  end

  defp parse_samples(list, acc \\ [])
  defp parse_samples([program], acc), do: {Enum.reverse(acc), program}

  defp parse_samples([sample_text | rest], acc) do
    parse_samples(rest, [parse_sample(sample_text) | acc])
  end

  defp parse_sample(sample_text) do
    sample_text
    |> String.split("\n")
    |> Enum.map(fn line ->
      ~r/(\d+).*?(\d+).*?(\d+).*?(\d+)/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  defp parse_program(program_lines) do
    program_lines
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      ~r/(\d+).*?(\d+).*?(\d+).*?(\d+)/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end
end
