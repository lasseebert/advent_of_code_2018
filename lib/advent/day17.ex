defmodule Advent.Day17 do
  @moduledoc """
  https://adventofcode.com/2018/day/17
  """

  @doc "Part 1"
  def count_wet_tiles(input) do
    map = parse(input)
    {min_y, max_y} = map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    {map, :done} = flow_down(map, {500, 0}, max_y)

    map
    |> Enum.filter(fn {{_x, y}, _} -> min_y <= y and y <= max_y end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.count(&(&1 == :wet_sand or &1 == :water))
  end

  @doc "Part 2"
  def count_water_tiles(input) do
    map = parse(input)
    {min_y, max_y} = map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    {map, :done} = flow_down(map, {500, 0}, max_y)

    map
    |> Enum.filter(fn {{_x, y}, _} -> min_y <= y and y <= max_y end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.count(&(&1 == :water))
  end

  defp flow_down(map, {_x, y}, max_y) when y > max_y, do: {map, :done}

  defp flow_down(map, point, max_y) do
    under = move(:down, point)

    map
    |> get_map_value(under)
    |> case do
      :clay -> :closed
      :water -> :closed
      :dry_sand -> :open
      :wet_sand -> :already_visited
    end
    |> case do
      :closed -> seek_left_and_right(map, point, max_y)
      :open -> flow_further_down(map, point, max_y)
      :already_visited -> {map, :done}
    end
  end

  defp flow_further_down(map, point, max_y) do
    under = move(:down, point)
    {map, result} = map |> Map.put(under, :wet_sand) |> flow_down(under, max_y)

    case result do
      :return -> seek_left_and_right(map, point, max_y)
      :done -> {map, :done}
    end
  end

  defp seek_left_and_right(map, point, max_y) do
    {map, left_result} = flow(map, :left, point, max_y)
    {map, right_result} = flow(map, :right, point, max_y)

    case {left_result, right_result} do
      {:closed, :closed} -> map |> Map.put(point, :water) |> fill_row(point)
      {:open, _} -> {map, :done}
      {_, :open} -> {map, :done}
    end
  end

  defp fill_row(map, point) do
    map =
      map
      |> fill(:left, point)
      |> fill(:right, point)

    {map, :return}
  end

  defp fill(map, dir, point) do
    next = move(dir, point)

    case get_map_value(map, next) do
      :clay -> map
      :water -> map
      :wet_sand -> map |> Map.put(next, :water) |> fill(dir, next)
    end
  end

  defp flow(map, dir, point, max_y) do
    next = move(dir, point)
    next_under = move(:down, next)

    next_action =
      map
      |> get_map_value(next)
      |> case do
        :clay -> :closed
        :water -> :already_visited
        :dry_sand -> :open
        :wet_sand -> :open
      end

    next_under_action =
      map
      |> get_map_value(next_under)
      |> case do
        :clay -> :closed
        :water -> :closed
        :dry_sand -> :open
        :wet_sand -> :already_visited
      end

    case {next_action, next_under_action} do
      {:closed, _} ->
        {map, :closed}

      {:open, :closed} ->
        map |> Map.put(next, :wet_sand) |> flow(dir, next, max_y)

      {:open, :open} ->
        {map, down_result} =
          map
          |> Map.put(next, :wet_sand)
          |> flow_down(next, max_y)

        case down_result do
          :done -> {map, :open}
          :return -> flow(map, dir, next, max_y)
        end

      {:already_visited, :closed} ->
        {map, :closed}

      {:open, :already_visited} ->
        {map, :open}
    end
  end

  defp get_map_value(map, point), do: Map.get(map, point, :dry_sand)

  defp move(:down, {x, y}), do: {x, y + 1}
  defp move(:left, {x, y}), do: {x - 1, y}
  defp move(:right, {x, y}), do: {x + 1, y}

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, fn {x_range, y_range}, map ->
      for x <- x_range,
          y <- y_range do
        {x, y}
      end
      |> Enum.reduce(map, &Map.put(&2, &1, :clay))
    end)
  end

  defp parse_line(line) do
    [var1, val1, var2, ran1, ran2] =
      ~r/([xy])=(\d+), ([xy])=(\d+)\.\.(\d+)/
      |> Regex.run(line, capture: :all_but_first)

    var1 = parse_var(var1)
    var2 = parse_var(var2)
    val1 = String.to_integer(val1)
    ran1 = String.to_integer(ran1)
    ran2 = String.to_integer(ran2)

    [{var1, val1..val1}, {var2, ran1..ran2}]
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
    |> List.to_tuple()
  end

  defp parse_var("x"), do: :x
  defp parse_var("y"), do: :y

  # defp print_area(map, {mid_x, mid_y}) do
  #  margin = 30

  #  printed_map =
  #    (mid_y - margin)..(mid_y + margin)
  #    |> Enum.map(fn y ->
  #      (mid_x - margin)..(mid_x + margin)
  #      |> Enum.map(fn x ->
  #        if {x, y} == {mid_x, mid_y} do
  #          "X"
  #        else
  #          map
  #          |> get_map_value({x, y})
  #          |> case do
  #            :dry_sand -> " "
  #            :clay -> "#"
  #            :wet_sand -> "|"
  #            :water -> "~"
  #          end
  #        end
  #      end)
  #      |> Enum.join("")
  #    end)
  #    |> Enum.join("\n")

  #  IO.puts("\n===========================\nPrinted map at {#{mid_x}, #{mid_y}}:\n" <> printed_map)
  #  map
  # end
end
