defmodule Advent.Day5Test do
  use ExUnit.Case

  alias Advent.Day5

  describe "part 1" do
    test "example input" do
      input = """
      dabAcCaCBAcCcaDA
      """

      assert Day5.remaining_length(input) == 10
    end

    test "puzzle input" do
      input = File.read!("inputs/day5_1.txt")
      assert Day5.remaining_length(input) == 9_116
    end
  end
end
