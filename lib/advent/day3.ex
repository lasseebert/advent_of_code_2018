defmodule Advent.Day3 do
  @moduledoc """
  --- Day 3: No Matter How You Slice It ---
  The Elves managed to locate the chimney-squeeze prototype fabric for Santa's suit (thanks to someone who helpfully wrote its box IDs on the wall of the warehouse in the middle of the night). Unfortunately, anomalies are still affecting them - nobody can even agree on how to cut the fabric.

  The whole piece of fabric they're working on is a very large square - at least 1000 inches on each side.

  Each Elf has made a claim about which area of fabric would be ideal for Santa's suit. All claims have an ID and consist of a single rectangle with edges parallel to the edges of the fabric. Each claim's rectangle is defined as follows:

  The number of inches between the left edge of the fabric and the left edge of the rectangle.
  The number of inches between the top edge of the fabric and the top edge of the rectangle.
  The width of the rectangle in inches.
  The height of the rectangle in inches.
  A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3 inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4 inches tall. Visually, it claims the square inches of fabric represented by # (and ignores the square inches of fabric represented by .) in the diagram below:

  ...........
  ...........
  ...#####...
  ...#####...
  ...#####...
  ...#####...
  ...........
  ...........
  ...........
  The problem is that many of the claims overlap, causing two or more claims to cover part of the same areas. For example, consider the following claims:

  #1 @ 1,3: 4x4
  #2 @ 3,1: 4x4
  #3 @ 5,5: 2x2
  Visually, these claim the following areas:

  ........
  ...2222.
  ...2222.
  .11XX22.
  .11XX22.
  .111133.
  .111133.
  ........
  The four square inches marked with X are claimed by both 1 and 2. (Claim 3, while adjacent to the others, does not overlap either of them.)

  If the Elves all proceed with their own plans, none of them will have enough fabric. How many square inches of fabric are within two or more claims?
  """

  @doc """
  Finds number of square inches that has at least two claims
  """
  @spec double_claim(String.t()) :: integer
  def double_claim(input) do
    input
    |> parse()
    |> Enum.reduce(%{}, &add_square_to_map/2)
    |> Map.values()
    |> Enum.count(&(&1 > 1))
  end

  defp add_square_to_map({dx, dy, w, h}, map) do
    for x <- dx..(dx + w - 1), y <- dy..(dy + h - 1) do
      {x, y}
    end
    |> Enum.reduce(map, &Map.update(&2, &1, 1, fn c -> c + 1 end))
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, w, h] =
        ~r/^#\d+ @ (\d+),(\d+): (\d+)x(\d+)$/
        |> Regex.run(line, capture: :all_but_first)

      {
        String.to_integer(x),
        String.to_integer(y),
        String.to_integer(w),
        String.to_integer(h)
      }
    end)
  end
end
