defmodule Advent.Day6 do
  @moduledoc """
  --- Day 6: Chronal Coordinates ---
  The device on your wrist beeps several times, and once again you feel like you're falling.

  "Situation critical," the device announces. "Destination indeterminate. Chronal interference detected. Please specify new target coordinates."

  The device then produces a list of coordinates (your puzzle input). Are they places it thinks are safe or dangerous? It recommends you check manual page 729. The Elves did not give you a manual.

  If they're dangerous, maybe you can minimize the danger by finding the coordinate that gives the largest distance from the other points.

  Using only the Manhattan distance, determine the area around each coordinate by counting the number of integer X,Y locations that are closest to that coordinate (and aren't tied in distance to any other coordinate).

  Your goal is to find the size of the largest area that isn't infinite. For example, consider the following list of coordinates:

  1, 1
  1, 6
  8, 3
  3, 4
  5, 5
  8, 9
  If we name these coordinates A through F, we can draw them on a grid, putting 0,0 at the top left:

  ..........
  .A........
  ..........
  ........C.
  ...D......
  .....E....
  .B........
  ..........
  ..........
  ........F.
  This view is partial - the actual grid extends infinitely in all directions. Using the Manhattan distance, each location's closest coordinate can be determined, shown here in lowercase:

  aaaaa.cccc
  aAaaa.cccc
  aaaddecccc
  aadddeccCc
  ..dDdeeccc
  bb.deEeecc
  bBb.eeee..
  bbb.eeefff
  bbb.eeffff
  bbb.ffffFf
  Locations shown as . are equally far from two or more coordinates, and so they don't count as being closest to any.

  In this example, the areas of coordinates A, B, C, and F are infinite - while not shown here, their areas extend forever outside the visible grid. However, the areas of coordinates D and E are finite: D is closest to 9 locations, and E is closest to 17 (both including the coordinate's location itself). Therefore, in this example, the size of the largest area is 17.

  What is the size of the largest area that isn't infinite?

  """

  @doc "Part 1"
  @spec largest_area(String.t()) :: integer
  def largest_area(input) do
    coords = input |> parse()
    bounding_box = calc_bounding_box(coords)

    # Claims map is coord -> owner_coord
    claims_map = coords |> Enum.into(%{}, fn coord -> {coord, coord} end)
    work_list = claims_map |> Enum.into([])

    claims_map
    |> run_claims(work_list, bounding_box)
    |> reject_infinite_claims(bounding_box)
    |> largest_claim_size()
  end

  defp reject_infinite_claims(claims_map, bounding_box) do
    # Infinite claims are the ones that touch the bounding box
    infinite_claims =
      claims_map
      |> Enum.filter(fn {coord, _owner} -> coord_on_box?(coord, bounding_box) end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.uniq()

    claims_map
    |> Enum.reject(fn {_, owner} -> owner in infinite_claims end)
    |> Enum.into(%{})
  end

  defp largest_claim_size(claims_map) do
    claims_map
    |> Enum.group_by(fn {_coord, owner} -> owner end)
    |> Enum.map(fn {_, list} -> length(list) end)
    |> Enum.max()
  end

  defp run_claims(claims_map, [], _bounding_box) do
    claims_map
    |> Enum.reject(fn {_coord, value} -> value == :multi end)
    |> Enum.into(%{})
  end

  defp run_claims(claims_map, work_list, bounding_box) do
    new_claims =
      work_list
      |> Enum.reduce(%{}, fn {coord, owner}, map ->
        run_claims_for_coord(coord, owner, map, bounding_box, claims_map)
      end)

    new_worklist = Enum.reject(new_claims, fn {_coord, value} -> value == :multi end)
    claims_map = new_claims |> Enum.into(%{}) |> Map.merge(claims_map)
    run_claims(claims_map, new_worklist, bounding_box)
  end

  defp run_claims_for_coord(coord, owner, map, bounding_box, claims_map) do
    coord
    |> valid_directions(claims_map, bounding_box)
    |> Enum.reduce(map, fn new_coord, map ->
      Map.update(map, new_coord, owner, fn
        ^owner -> owner
        _ -> :multi
      end)
    end)
  end

  defp valid_directions({x, y}, claims_map, bounding_box) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.reject(fn coord ->
      coord_outside_box?(coord, bounding_box) or Map.has_key?(claims_map, coord)
    end)
  end

  defp calc_bounding_box(coords) do
    xs = coords |> Enum.map(&elem(&1, 0))
    ys = coords |> Enum.map(&elem(&1, 1))

    {
      {Enum.min(xs), Enum.min(ys)},
      {Enum.max(xs), Enum.max(ys)}
    }
  end

  defp coord_on_box?({x, y}, {{bx1, by1}, {bx2, by2}}) do
    x == bx1 or x == bx2 or y == by1 or y == by2
  end

  defp coord_outside_box?({x, y}, {{bx1, by1}, {bx2, by2}}) do
    x < bx1 or x > bx2 or y < by1 or y > by2
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end
end
