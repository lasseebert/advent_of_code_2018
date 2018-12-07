defmodule Advent.Day6Part1Test do
  use ExUnit.Case

  alias Advent.Day6Part1

  describe "part 1" do
    test "example input" do
      input = """
      1, 1
      1, 6
      8, 3
      3, 4
      5, 5
      8, 9
      """

      assert Day6Part1.largest_area(input) == 17
    end

    test "puzzle input" do
      input = "inputs/day6_1.txt" |> File.read!()
      assert Day6Part1.largest_area(input) == 5_941
    end
  end
end
