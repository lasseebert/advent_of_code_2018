defmodule Advent.Day6Part2Test do
  use ExUnit.Case

  alias Advent.Day6Part2

  describe "part 2" do
    test "example input" do
      input = """
      1, 1
      1, 6
      8, 3
      3, 4
      5, 5
      8, 9
      """

      assert Day6Part2.area_size(input, 32) == 16
    end

    test "puzzle input" do
      input = "inputs/day6_1.txt" |> File.read!()
      assert Day6Part2.area_size(input, 10_000) == 40_244
    end
  end
end
