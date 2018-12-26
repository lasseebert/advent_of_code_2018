defmodule Advent.Day22Test do
  use ExUnit.Case

  alias Advent.Day22

  describe "part 1" do
    test "example input" do
      assert Day22.part1(510, {10, 10}) == 114
    end

    test "puzzle input" do
      assert Day22.part1(7305, {13, 734}) == 10204
    end
  end

  describe "part 2" do
    test "example input" do
      assert Day22.part2(510, {10, 10}) == 45
    end

    @tag timeout: 99999999
    test "puzzle input" do
      assert Day22.part2(7305, {13, 734}) == 1004
    end
  end
end
