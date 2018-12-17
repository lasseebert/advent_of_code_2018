defmodule Advent.Day17Test do
  use ExUnit.Case

  alias Advent.Day17

  @example_input """
  x=495, y=2..7
  y=7, x=495..501
  x=501, y=3..7
  x=498, y=2..4
  x=506, y=1..2
  x=498, y=10..13
  x=504, y=10..13
  y=13, x=498..504
  """

  describe "part 1" do
    test "example input" do
      assert Day17.count_wet_tiles(@example_input) == 57
    end

    test "puzzle input" do
      input = File.read!("inputs/day17_1.txt")
      assert Day17.count_wet_tiles(input) == 32552
    end
  end

  describe "part 2" do
    test "example input" do
      assert Day17.count_water_tiles(@example_input) == 29
    end

    test "puzzle input" do
      input = File.read!("inputs/day17_1.txt")
      assert Day17.count_water_tiles(input) == 26405
    end
  end
end
