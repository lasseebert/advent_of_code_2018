defmodule Advent.Day14Test do
  use ExUnit.Case

  alias Advent.Day14

  describe "part 1" do
    test "example input 1" do
      assert Day14.part1(9) == "5158916779"
    end

    test "example input 2" do
      assert Day14.part1(5) == "0124515891"
    end

    test "example input 3" do
      assert Day14.part1(18) == "9251071085"
    end

    test "example input 4" do
      assert Day14.part1(2018) == "5941429882"
    end

    test "puzzle input" do
      assert Day14.part1(990941) == "3841138812"
    end
  end

  describe "part 2" do
    test "example input 1" do
      assert Day14.part2("51589") == 9
    end

    test "example input 2" do
      assert Day14.part2("01245") == 5
    end

    test "example input 3" do
      assert Day14.part2("92510") == 18
    end

    test "example input 4" do
      assert Day14.part2("59414") == 2018
    end

    test "puzzle input" do
      assert Day14.part2("990941") == 20_200_561
    end
  end
end
