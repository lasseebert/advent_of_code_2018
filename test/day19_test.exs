defmodule Advent.Day19Test do
  use ExUnit.Case

  alias Advent.Day19

  @example_input """
  #ip 0
  seti 5 0 1
  seti 6 0 2
  addi 0 1 0
  addr 1 2 3
  setr 1 0 0
  seti 8 0 4
  seti 9 0 5
  """

  describe "part 1" do
    test "example input" do
      assert Day19.part1(@example_input) == 7
    end

    test "puzzle input" do
      input = File.read!("inputs/day19_1.txt")
      assert Day19.part1(input) == 2520
    end
  end

  describe "part 2" do
    test "puzzle input" do
      input = File.read!("inputs/day19_1.txt")
      assert Day19.part2(input) == 27941760
    end
  end
end
