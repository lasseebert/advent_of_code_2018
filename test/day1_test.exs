defmodule Advent.Day1Test do
  use ExUnit.Case

  alias Advent.Day1

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
