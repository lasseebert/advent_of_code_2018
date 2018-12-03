defmodule Advent.Day3Test do
  use ExUnit.Case

  alias Advent.Day3

  describe "part 1" do
    test "example input" do
      result =
        """
        #1 @ 1,3: 4x4
        #2 @ 3,1: 4x4
        #3 @ 5,5: 2x2
        """
        |> Day3.double_claim()

      assert result == 4
    end

    test "puzzle input" do
      result =
        "inputs/day3_1.txt"
        |> File.read!()
        |> Day3.double_claim()

      assert result == 103_806
    end
  end

  describe "part 2" do
    test "example input" do
      result =
        """
        #1 @ 1,3: 4x4
        #2 @ 3,1: 4x4
        #3 @ 5,5: 2x2
        """
        |> Day3.find_no_overlap()

      assert result == 3
    end

    test "puzzle input" do
      result =
        "inputs/day3_1.txt"
        |> File.read!()
        |> Day3.find_no_overlap()

      assert result == 625
    end
  end
end
