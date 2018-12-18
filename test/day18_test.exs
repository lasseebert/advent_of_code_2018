defmodule Advent.Day18Test do
  use ExUnit.Case

  alias Advent.Day18

  @example_input """
  .#.#...|#.
  .....#|##|
  .|..|...#.
  ..|#.....#
  #.#|||#|#|
  ...#.||...
  .|....|...
  ||...#|.#|
  |.||||..|.
  ...#.|..|.
  """

  describe "part 1" do
    test "example input" do
      assert Day18.resource_value(@example_input) == 1147
    end

    test "puzzle input" do
      input = File.read!("inputs/day18_1.txt")
      assert Day18.resource_value(input) == 638_400
    end
  end

  describe "part 2" do
    test "example input" do
      assert Day18.resource_value_long_time(@example_input) == 0
    end

    test "puzzle input" do
      input = File.read!("inputs/day18_1.txt")
      assert Day18.resource_value_long_time(input) == 195952
    end
  end
end
