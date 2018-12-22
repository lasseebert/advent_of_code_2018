defmodule Advent.Day21Test do
  use ExUnit.Case

  alias Advent.Day21

  describe "part 1" do
    test "puzzle input" do
      input = File.read!("inputs/day21_1.txt")
      assert Day21.part1(input) == 15_690_445
    end
  end

  describe "part 2" do
    test "puzzle input" do
      input = File.read!("inputs/day21_1.txt")
      assert Day21.part2(input) == 936_387
    end
  end
end
