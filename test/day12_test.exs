defmodule Advent.Day12Test do
  use ExUnit.Case

  alias Advent.Day12

  @example_input """
  initial state: #..#.#..##......###...###

  ...## => #
  ..#.. => #
  .#... => #
  .#.#. => #
  .#.## => #
  .##.. => #
  .#### => #
  #.#.# => #
  #.### => #
  ##.#. => #
  ##.## => #
  ###.. => #
  ###.# => #
  ####. => #
  """

  describe "part 1" do
    test "example input" do
      assert Day12.sum_pots(@example_input, 20) == 325
    end

    test "puzzle input" do
      input = File.read!("inputs/day12_1.txt")
      assert Day12.sum_pots(input, 20) == 2049
    end
  end

  describe "part 2" do
    test "puzzle input" do
      input = File.read!("inputs/day12_1.txt")
      assert Day12.sum_pots(input, 50000000000) == 2300000000006
    end

    test "getting same answer as naive function" do
      input = File.read!("inputs/day12_1.txt")
      count = 500

      slow_result = Day12.sum_pots_slow(input, count)
      fast_result = Day12.sum_pots(input, count)
      assert slow_result == fast_result
    end
  end
end
