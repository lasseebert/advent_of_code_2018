defmodule Advent.Day2Test do
  use ExUnit.Case

  alias Advent.Day2

  describe "part 1" do
    test "example input" do
      result =
        """
        abcdef
        bababc
        abbcde
        abcccd
        aabcdd
        abcdee
        ababab
        """
        |> Day2.checksum()

      assert result == 12
    end

    test "puzzle input" do
      result =
        "inputs/day2_1.txt"
        |> File.read!()
        |> Day2.checksum()

      assert result == 7410
    end
  end

  describe "part 2" do
    test "example input" do
      result =
        """
        abcde
        fghij
        klmno
        pqrst
        fguij
        axcye
        wvxyz
        """
        |> Day2.common()

      assert result == "fgij"
    end

    test "puzzle input" do
      result =
        "inputs/day2_1.txt"
        |> File.read!()
        |> Day2.common()

      assert result == "cnjxoritzhvbosyewrmqhgkul"
    end
  end
end
