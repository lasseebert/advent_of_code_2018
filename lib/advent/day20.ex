defmodule Advent.Day20 do
  @moduledoc """
  https://adventofcode.com/2018/day/20
  """

  @dirs [:east, :west, :north, :south]

  def part1(input) do
    input
    |> parse()
    |> build_paths()
    |> shortest_path_map()
    |> Map.values()
    |> Enum.max()
  end

  def part2(input) do
    input
    |> parse()
    |> build_paths()
    |> shortest_path_map()
    |> Map.values()
    |> Enum.count(& &1 >= 1000)
  end

  defp shortest_path_map(paths) do
    shortest_path_map(paths, [{0, 0}], MapSet.new(), %{{0, 0} => 0})
  end

  defp shortest_path_map(_paths, [], _visited, map), do: map

  defp shortest_path_map(paths, [point | worklist], visited, map) do
    if MapSet.member?(visited, point) do
      shortest_path_map(paths, worklist, visited, map)
    else
      current_distance = Map.fetch!(map, point)

      {map, worklist} =
        paths
        |> Map.fetch!(point)
        |> Enum.reduce({map, worklist}, fn neighbour, {map, worklist} ->
          map = Map.update(map, neighbour, current_distance + 1, &Enum.min([current_distance + 1, &1]))
          worklist = [neighbour | worklist]
          {map, worklist}
        end)

      visited = MapSet.put(visited, point)

      shortest_path_map(paths, worklist, visited, map)
    end
  end

  defp build_paths(directions) do
    {map, _point} = build_paths(directions, %{}, {0, 0})
    map
  end

  defp build_paths([], map, from_point) do
    {map, from_point}
  end

  defp build_paths([dir | rest], map, from_point) when dir in @dirs do
    to_point = move(from_point, dir)

    map =
      map
      |> Map.update(from_point, MapSet.new([to_point]), &MapSet.put(&1, to_point))
      |> Map.update(to_point, MapSet.new([from_point]), &MapSet.put(&1, from_point))

    build_paths(rest, map, to_point)
  end

  defp build_paths([{:branch, blocks} | rest], map, from_point) do
    {map, next_points} =
      Enum.reduce(blocks, {map, MapSet.new()}, fn block, {map, next_points} ->
        {map, to_point} = build_paths(block, map, from_point)
        {map, MapSet.put(next_points, to_point)}
      end)

    map =
      next_points
      |> Enum.reduce(map, fn point, map ->
        {map, _point} = build_paths(rest, map, point)
        map
      end)

    {map, :not_a_point}
  end

  defp move({x, y}, :north), do: {x, y - 1}
  defp move({x, y}, :east), do: {x + 1, y}
  defp move({x, y}, :west), do: {x - 1, y}
  defp move({x, y}, :south), do: {x, y + 1}

  defp parse(input) do
    input
    |> tokenize()
    |> compile()
  end

  defp tokenize(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(fn
      "N" -> :north
      "S" -> :south
      "E" -> :east
      "W" -> :west
      "(" -> :left_parenthesis
      ")" -> :right_parenthesis
      "|" -> :or
      "^" -> :skip
      "$" -> :skip
    end)
    |> Enum.reject(&(&1 == :skip))
  end

  defp compile(tokens) do
    {route, []} = read_route(tokens, [])
    route
  end

  defp read_route([], acc) do
    {Enum.reverse(acc), []}
  end

  defp read_route([:or | _] = tokens, acc) do
    {Enum.reverse(acc), tokens}
  end

  defp read_route([:right_parenthesis | _] = tokens, acc) do
    {Enum.reverse(acc), tokens}
  end

  defp read_route([dir | rest], acc) when dir in @dirs do
    read_route(rest, [dir | acc])
  end

  defp read_route([:left_parenthesis | rest], acc) do
    {blocks, rest} = read_routes(rest, [])
    read_route(rest, [{:branch, blocks} | acc])
  end

  defp read_routes([], acc) do
    {Enum.reverse(acc), []}
  end

  defp read_routes([:or, :right_parenthesis | rest], acc) do
    {Enum.reverse([[] | acc]), rest}
  end

  defp read_routes([:or | rest], acc) do
    read_routes(rest, acc)
  end

  defp read_routes([:right_parenthesis | rest], acc) do
    {Enum.reverse(acc), rest}
  end

  defp read_routes(tokens, acc) do
    {block, rest} = read_route(tokens, [])
    read_routes(rest, [block | acc])
  end
end
