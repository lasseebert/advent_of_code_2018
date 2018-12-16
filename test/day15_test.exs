defmodule Advent.Day15Test do
  use ExUnit.Case

  alias Advent.Day15

  describe "part 1" do
    test "example input 1" do
      input = """
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """

      assert Day15.outcome(input) == 27730
    end

    test "example input 2" do
      # #######       #######
      # #G..#E#       #...#E#   E(200)
      # #E#E.E#       #E#...#   E(197)
      # #G.##.#  -->  #.E##.#   E(185)
      # #...#E#       #E..#E#   E(200), E(200)
      # #...E.#       #.....#
      # #######       #######

      input = """
      #######
      #G..#E#
      #E#E.E#
      #G.##.#
      #...#E#
      #...E.#
      #######
      """

      assert Day15.outcome(input) == 36334
    end

    test "example input 3" do
      input = """
      #######
      #E..EG#
      #.#G.E#
      #E.##E#
      #G..#.#
      #..E#.#
      #######
      """

      assert Day15.outcome(input) == 39514
    end

    test "example input 4" do
      input = """
      #######
      #E.G#.#
      #.#G..#
      #G.#.G#
      #G..#.#
      #...E.#
      #######
      """

      assert Day15.outcome(input) == 27755
    end

    test "example input 5" do
      input = """
      #######
      #.E...#
      #.#..G#
      #.###.#
      #E#G#G#
      #...#G#
      #######
      """

      assert Day15.outcome(input) == 28944
    end

    test "example input 6" do
      input = """
      #########
      #G......#
      #.E.#...#
      #..##..G#
      #...##..#
      #...#...#
      #.G...G.#
      #.....G.#
      #########
      """

      assert Day15.outcome(input) == 18740
    end

    @tag timeout: 600_000
    test "puzzle input" do
      input = File.read!("inputs/day15_1.txt")
      assert Day15.outcome(input) == 195811
    end
  end
end
