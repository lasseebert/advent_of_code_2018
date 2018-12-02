defmodule Advent.Day1Test do
  use ExUnit.Case

  alias Advent.Day1

  describe "part 1" do
    test "example input" do
      result =
        """
        +1
        +1
        +1
        """
        |> Day1.final_frequency()

      assert result == 3
    end

    test "puzzle input" do
      result =
        "inputs/day1_1.txt"
        |> File.read!()
        |> Day1.final_frequency()

      assert result == 486
    end
  end

  describe "part 2" do
    test "example input 1" do
      result =
        """
        +1
        -1
        """
        |> Day1.first_duplicate()

      assert result == 0
    end

    test "example input 2" do
      result =
        """
        +3
        +3
        +4
        -2
        -4
        """
        |> Day1.first_duplicate()

      assert result == 10
    end

    test "example input 3" do
      result =
        """
        +7
        +7
        -2
        -7
        -4
        """
        |> Day1.first_duplicate()

      assert result == 14
    end

    test "puzzle input" do
      result =
        "inputs/day1_1.txt"
        |> File.read!()
        |> Day1.first_duplicate()

      assert result == 69285
    end
  end
end
