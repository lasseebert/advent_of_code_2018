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
      assert Day12.sum_pots(@example_input) == 325
    end

    test "puzzle input" do
      input = File.read!("inputs/day12_1.txt")
      assert Day12.sum_pots(input) == 2049
    end
  end
end
