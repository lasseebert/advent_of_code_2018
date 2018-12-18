defmodule Advent.Day18 do
  @moduledoc """
  https://adventofcode.com/2018/day/18
  """

  @doc "Part 1"
  def resource_value(input) do
    input
    |> parse()
    |> step_times(10)
    |> calc_resource_value()
  end

  @doc "Part 2"
  def resource_value_long_time(input) do
    count = 1_000_000_000

    {maps, repeat_start} =
      input
      |> parse()
      |> find_repeat()

    maps_length = length(maps)
    repeat_length = maps_length - repeat_start
    init_length = maps_length - repeat_length

    over_repeat = rem(count - init_length, repeat_length)

    maps
    |> Enum.at(init_length + over_repeat)
    |> calc_resource_value()
  end

  defp find_repeat(map) do
    do_find_repeat(%{map => 0}, map, 1)
  end

  defp do_find_repeat(maps, last, next_index) do
    next = step(last)

    case Map.fetch(maps, next) do
      {:ok, index} -> {maps |> Enum.sort_by(&elem(&1, 1)) |> Enum.map(&elem(&1, 0)), index}
      :error -> do_find_repeat(Map.put(maps, next, next_index), next, next_index + 1)
    end
  end

  defp calc_resource_value(map) do
    acres =
      map
      |> Map.values()
      |> Enum.group_by(& &1)
      |> Enum.into(%{}, fn {key, list} -> {key, length(list)} end)

    Map.get(acres, :tree, 0) * Map.get(acres, :lumber, 0)
  end

  defp step_times(map, 0), do: map
  defp step_times(map, n), do: map |> step() |> step_times(n - 1)

  defp step(map) do
    # print_map(map)
    Enum.into(map, %{}, fn {point, acre} -> {point, transform_acre(acre, point, map)} end)
  end

  defp transform_acre(acre, point, map) do
    adjacent = sum_adjacent(point, map)

    case {acre, adjacent} do
      {:open, %{tree: tree}} when tree >= 3 -> :tree
      {:open, _} -> :open
      {:tree, %{lumber: lumber}} when lumber >= 3 -> :lumber
      {:tree, _} -> :tree
      {:lumber, %{lumber: lumber, tree: tree}} when lumber >= 1 and tree >= 1 -> :lumber
      {:lumber, _} -> :open
    end
  end

  defp sum_adjacent(point, map) do
    point
    |> adjacent_points()
    |> Enum.reduce(%{}, fn adj_point, sum ->
      acre = Map.get(map, adj_point, :outside)
      Map.update(sum, acre, 1, &(&1 + 1))
    end)
  end

  defp adjacent_points({x, y}) do
    for x1 <- (x - 1)..(x + 1),
        y1 <- (y - 1)..(y + 1),
        {x1, y1} != {x, y} do
      {x1, y1}
    end
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {char, x}, map -> Map.put(map, {x, y}, parse_char(char)) end)
    end)
  end

  defp parse_char("."), do: :open
  defp parse_char("#"), do: :lumber
  defp parse_char("|"), do: :tree

  defp print_map(map) do
    IO.puts("")

    map
    |> Enum.sort_by(fn {{x, y}, _} -> {y, x} end)
    |> Enum.chunk_by(fn {{_x, y}, _} -> y end)
    |> Enum.map(fn line ->
      line
      |> Enum.map(fn {_point, acre} -> acre end)
      |> Enum.map(fn
        :tree -> "|"
        :lumber -> "#"
        :open -> "."
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
