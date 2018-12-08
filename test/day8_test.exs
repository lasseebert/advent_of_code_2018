defmodule Advent.Day8Test do
  use ExUnit.Case

  alias Advent.Day8

  describe "part 1" do
    test "example input" do
      input = """
      2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
      """

      assert Day8.sum_meta(input) == 138
    end

    test "puzzle input" do
      input = File.read!("inputs/day8_1.txt")
      assert Day8.sum_meta(input) == 42_254
    end
  end

  describe "part 2" do
    test "example input" do
      input = """
      2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
      """

      assert Day8.root_value(input) == 66
    end

    test "puzzle input" do
      input = File.read!("inputs/day8_1.txt")
      assert Day8.root_value(input) == 25_007
    end
  end
end
