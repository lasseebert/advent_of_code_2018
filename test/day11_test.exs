defmodule Advent.Day11Test do
  use ExUnit.Case

  alias Advent.Day11

  describe "part 1" do
    test "fuel_value" do
      assert Day11.fuel_value({122, 79}, 57) == -5
      assert Day11.fuel_value({217, 196}, 39) == 0
      assert Day11.fuel_value({101, 153}, 71) == 4
    end

    test "example input 1" do
      assert Day11.best_3_square(18) == {33, 45}
    end

    test "example input 2" do
      assert Day11.best_3_square(42) == {21, 61}
    end

    test "puzzle input" do
      assert Day11.best_3_square(7803) == {20, 51}
    end
  end

  describe "part 2" do
    test "example input 1" do
      assert Day11.best_square(18) == {{90, 269}, 16}
    end

    test "example input 2" do
      assert Day11.best_square(42) == {{232, 251}, 12}
    end

    test "puzzle input" do
      assert Day11.best_square(7803) == {{230, 272}, 17}
    end
  end
end
