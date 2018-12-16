defmodule Advent.Day16Test do
  use ExUnit.Case

  alias Advent.Day16

  describe "part 1" do
    test "puzzle input" do
      input = File.read!("inputs/day16_1.txt")
      assert Day16.part1(input) == 640
    end
  end

  describe "part 2" do
    test "puzzle input" do
      input = File.read!("inputs/day16_1.txt")
      assert Day16.part2(input) == 472
    end
  end
end
