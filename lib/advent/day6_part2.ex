defmodule Advent.Day6Part2 do
  @moduledoc """
  --- Part Two ---
  On the other hand, if the coordinates are safe, maybe the best you can do is try to find a region near as many coordinates as possible.

  For example, suppose you want the sum of the Manhattan distance to all of the coordinates to be less than 32. For each location, add up the distances to all of the given coordinates; if the total of those distances is less than 32, that location is within the desired region. Using the same coordinates as above, the resulting region looks like this:

  ..........
  .A........
  ..........
  ...###..C.
  ..#D###...
  ..###E#...
  .B.###....
  ..........
  ..........
  ........F.
  In particular, consider the highlighted location 4,3 located at the top middle of the region. Its calculation is as follows, where abs() is the absolute value function:

  Distance to coordinate A: abs(4-1) + abs(3-1) =  5
  Distance to coordinate B: abs(4-1) + abs(3-6) =  6
  Distance to coordinate C: abs(4-8) + abs(3-3) =  4
  Distance to coordinate D: abs(4-3) + abs(3-4) =  2
  Distance to coordinate E: abs(4-5) + abs(3-5) =  3
  Distance to coordinate F: abs(4-8) + abs(3-9) = 10
  Total distance: 5 + 6 + 4 + 2 + 3 + 10 = 30
  Because the total distance to all coordinates (30) is less than 32, the location is within the region.

  This region, which also includes coordinates D and E, has a total size of 16.

  Your actual region will need to be much larger than this example, though, instead including all locations with a total distance of less than 10000.

  What is the size of the region containing all locations which have a total distance to all given coordinates of less than 10000?
  """

  @doc "Part 2"
  @spec area_size(String.t(), integer) :: integer
  def area_size(input, threshold) do
    coords = parse(input)
    start = find_first_coord({0, 0}, coords, threshold)

    find_area_size(%{start => true}, [start], coords, threshold)
  end

  defp find_area_size(map, [], _coords, _threshold) do
    map |> Map.values() |> Enum.count(&(&1 == true))
  end

  defp find_area_size(map, [current | work], coords, threshold) do
    new_coords =
      current
      |> valid_directions(map)
      |> Enum.map(fn coord -> {coord, include?(coord, coords, threshold)} end)

    map = Enum.reduce(new_coords, map, fn {coord, include}, map -> Map.put(map, coord, include) end)
    new_work = new_coords |> Enum.filter(fn {_, include} -> include end) |> Enum.map(&elem(&1, 0))
    find_area_size(map, new_work ++ work, coords, threshold)
  end

  defp valid_directions({x, y}, map) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.reject(&Map.has_key?(map, &1))
  end

  # Goes east and south until we encounter a part of the area
  defp find_first_coord({x, y}, coords, threshold) do
    {coord, dist} =
      [{x + 1, y}, {x, y + 1}]
      |> Enum.map(fn coord -> {coord, dists(coord, coords)} end)
      |> Enum.min_by(&elem(&1, 1))

    if dist < threshold do
      coord
    else
      find_first_coord(coord, coords, threshold)
    end
  end

  defp dists(coord, coords) do
    coords
    |> Enum.map(&dist(&1, coord))
    |> Enum.sum()
  end

  defp dist({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp include?(coord, coords, threshold) do
    dists(coord, coords) < threshold
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
