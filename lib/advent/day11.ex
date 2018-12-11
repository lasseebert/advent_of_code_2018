defmodule Advent.Day11 do
  @moduledoc """
  --- Day 11: Chronal Charge ---
  You watch the Elves and their sleigh fade into the distance as they head toward the North Pole.

  Actually, you're the one fading. The falling sensation returns.

  The low fuel warning light is illuminated on your wrist-mounted device. Tapping it once causes it to project a hologram of the situation: a 300x300 grid of fuel cells and their current power levels, some negative. You're not sure what negative power means in the context of time travel, but it can't be good.

  Each fuel cell has a coordinate ranging from 1 to 300 in both the X (horizontal) and Y (vertical) direction. In X,Y notation, the top-left cell is 1,1, and the top-right cell is 300,1.

  The interface lets you select any 3x3 square of fuel cells. To increase your chances of getting to your destination, you decide to choose the 3x3 square with the largest total power.

  The power level in a given fuel cell can be found through the following process:

  Find the fuel cell's rack ID, which is its X coordinate plus 10.
  Begin with a power level of the rack ID times the Y coordinate.
  Increase the power level by the value of the grid serial number (your puzzle input).
  Set the power level to itself multiplied by the rack ID.
  Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
  Subtract 5 from the power level.
  For example, to find the power level of the fuel cell at 3,5 in a grid with serial number 8:

  The rack ID is 3 + 10 = 13.
  The power level starts at 13 * 5 = 65.
  Adding the serial number produces 65 + 8 = 73.
  Multiplying by the rack ID produces 73 * 13 = 949.
  The hundreds digit of 949 is 9.
  Subtracting 5 produces 9 - 5 = 4.
  So, the power level of this fuel cell is 4.

  Here are some more example power levels:

  Fuel cell at  122,79, grid serial number 57: power level -5.
  Fuel cell at 217,196, grid serial number 39: power level  0.
  Fuel cell at 101,153, grid serial number 71: power level  4.
  Your goal is to find the 3x3 square which has the largest total power. The square must be entirely within the 300x300 grid. Identify this square using the X,Y coordinate of its top-left fuel cell. For example:

  For grid serial number 18, the largest total 3x3 square has a top-left corner of 33,45 (with a total power of 29); these fuel cells appear in the middle of this 5x5 region:

  -2  -4   4   4   4
  -4   4   4   4  -5
  4   3   3   4  -4
  1   1   2   4  -3
  -1   0   2  -5  -2
  For grid serial number 42, the largest 3x3 square's top-left is 21,61 (with a total power of 30); they are in the middle of this region:

  -3   4   2   2   2
  -4   4   3   3   4
  -5   3   3   4  -4
  4   3   3   4  -3
  3   3   3  -5  -1
  What is the X,Y coordinate of the top-left fuel cell of the 3x3 square with the largest total power?
  """

  @type point :: {integer, integer}
  @type square :: {point, size :: integer}

  @doc "Part 1"
  @spec best_3_square(integer) :: point
  def best_3_square(serial) do
    grid = init_grid(serial)
    cache = grid |> Enum.into(%{}, fn {point, value} -> {{point, 1}, value} end)
    squares = build_squares(3)

    squares
    |> Enum.reduce({[], cache}, fn square, {acc, cache} ->
      {value, cache} = square_value(square, cache)
      {[{square, value} | acc], cache}
    end)
    |> elem(0)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
    |> elem(0)
  end

  @doc "Part 2"
  @spec best_square(integer) :: square
  def best_square(serial) do
    grid = init_grid(serial)
    cache = grid |> Enum.into(%{}, fn {point, value} -> {{point, 1}, value} end)

    1..300
    |> Enum.flat_map(&build_squares/1)
    |> Enum.reduce({[], cache}, fn square, {acc, cache} ->
      {value, cache} = square_value(square, cache)
      {[{square, value} | acc], cache}
    end)
    |> elem(0)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
  end

  defp square_value(square, cache) do
    case Map.fetch(cache, square) do
      {:ok, value} -> {value, cache}
      :error -> calc_square_value(square, cache)
    end
  end

  defp calc_square_value({{x, y}, n} = square, cache) when rem(n, 2) == 0 do
    n_half = div(n, 2)

    {value, cache} =
      [
        {{x, y}, n_half},
        {{x + n_half, y}, n_half},
        {{x, y + n_half}, n_half},
        {{x + n_half, y + n_half}, n_half}
      ]
      |> Enum.reduce({0, cache}, fn smaller_square, {sum, cache} ->
        {value, cache} = square_value(smaller_square, cache)
        {value + sum, cache}
      end)

    cache = Map.put(cache, square, value)
    {value, cache}
  end

  defp calc_square_value({{x, y}, n} = square, cache) do
    n_half_small = div(n, 2)
    n_half_big = n_half_small + 1

    {value, cache} =
      [
        {{x, y}, n_half_big},
        {{x + n_half_big, y}, n_half_small},
        {{x, y + n_half_big}, n_half_small},
        {{x + n_half_small, y + n_half_small}, n_half_big}
      ]
      |> Enum.reduce({0, cache}, fn smaller_square, {sum, cache} ->
        {value, cache} = square_value(smaller_square, cache)
        {value + sum, cache}
      end)

    {negative, cache} = square_value({{x + n_half_small, y + n_half_small}, 1}, cache)
    value = value - negative

    cache = Map.put(cache, square, value)
    {value, cache}
  end

  @doc "Returns the fuel cell value of a single cell"
  @spec fuel_value(point, integer) :: integer
  def fuel_value({x, y}, serial) do
    rack_id = x + 10
    power_level = (rack_id * y + serial) * rack_id
    power_level = power_level |> div(100) |> rem(10)
    power_level - 5
  end

  defp init_grid(serial) do
    for x <- 1..300, y <- 1..300 do
      {{x, y}, fuel_value({x, y}, serial)}
    end
    |> Enum.into(%{})
  end

  defp build_squares(size) do
    for x <- 1..(300 - size + 1), y <- 1..(300 - size + 1) do
      {{x, y}, size}
    end
  end
end
