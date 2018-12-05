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

  describe "part 2" do
    test "example input" do
      input = """
      dabAcCaCBAcCcaDA
      """

      assert Day5.remaining_length_after_removal(input) == 4
    end

    test "puzzle input" do
      input = File.read!("inputs/day5_1.txt")
      assert Day5.remaining_length_after_removal(input) == 6_890
    end
  end
end
