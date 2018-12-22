defmodule Advent.Day20Test do
  use ExUnit.Case

  alias Advent.Day20

  describe "part 1" do
    test "example 1" do
      input = "^WNE$"
      assert Day20.part1(input) == 3
    end

    test "example 2" do
      input = "^ENWWW(NEEE|SSE(EE|N))$"
      assert Day20.part1(input) == 10
    end

    test "example 3" do
      input = "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$"
      assert Day20.part1(input) == 18
    end

    test "puzzle input" do
      input = File.read!("inputs/day20_1.txt")
      assert Day20.part1(input) == 4184
    end
  end

  describe "part 2" do
    test "puzzle input" do
      input = File.read!("inputs/day20_1.txt")
      assert Day20.part2(input) == 8596
    end
  end
end
