defmodule Advent.Day22 do
  @moduledoc """
  https://adventofcode.com/2018/day/22
  """

  defmodule Graph do
    def new do
      %{}
    end

    def add_edge(graph, from, to, cost) do
      graph
      |> add_single_edge(from, to, cost)
      |> add_single_edge(to, from, cost)
    end

    def connected_nodes(graph, node) do
      graph
      |> Map.get(node, %{})
      |> Map.keys()
    end

    def cost(graph, from, to) do
      graph
      |> Map.fetch!(from)
      |> Map.fetch!(to)
    end

    defp add_single_edge(graph, from, to, cost) do
      Map.update(graph, from, %{to => cost}, &Map.put(&1, to, cost))
    end
  end

  def part1(depth, target) do
    {0, 0}
    |> rectancle_points(target)
    |> with_types(depth, target)
    |> Map.values()
    |> Enum.map(&find_risk_level/1)
    |> Enum.sum()
  end

  def part2(depth, target) do
    corner = point_add(target, {100, 100})

    grid =
      {0, 0}
      |> rectancle_points(corner)
      |> with_types(depth, target)

    graph =
      grid
      |> Enum.reduce(Graph.new(), fn {point, type}, graph ->
        [item_1, item_2] = items = valid_equipment(type)

        point
        |> adjacent_points(corner)
        |> Enum.reduce(graph, fn adj_point, graph ->
          adj_items = valid_equipment(Map.fetch!(grid, adj_point))

          MapSet.intersection(MapSet.new(items), MapSet.new(adj_items))
          |> Enum.reduce(graph, fn item, graph ->
            Graph.add_edge(graph, {point, item}, {adj_point, item}, 1)
          end)
        end)
        |> Graph.add_edge({point, item_1}, {point, item_2}, 7)
      end)

    dijkstra_path_length(graph, {{0, 0}, :torch}, {target, :torch})
  end

  defp dijkstra_path_length(graph, source, target) do
    visited = MapSet.new()
    unvisited = %{source => 0}
    dijkstra_path_length(graph, visited, unvisited, target)
  end

  defp dijkstra_path_length(graph, visited, unvisited, target) do
    {current, current_dist} = unvisited |> Enum.min_by(&elem(&1, 1))

    if current == target do
      current_dist
    else
      unvisited =
        graph
        |> Graph.connected_nodes(current)
        |> Enum.reject(&MapSet.member?(visited, &1))
        |> Enum.reduce(unvisited, fn node, unvisited ->
          dist = Graph.cost(graph, current, node) + current_dist
          Map.update(unvisited, node, dist, &Enum.min([dist, &1]))
        end)
        |> Map.delete(current)

      visited = MapSet.put(visited, current)

      dijkstra_path_length(graph, visited, unvisited, target)
    end
  end

  defp valid_equipment(:rocky), do: [:torch, :climb]
  defp valid_equipment(:wet), do: [:climb, :none]
  defp valid_equipment(:narrow), do: [:torch, :none]

  defp adjacent_points({x, y}, {max_x, max_y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.reject(fn {x, y} -> x < 0 or x > max_x or y < 0 or y > max_y end)
  end

  defp point_add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  defp rectancle_points({x1, y1}, {x2, y2}) do
    for x <- x1..x2, y <- y1..y2 do
      {x, y}
    end
  end

  defp with_types(points, depth, target) do
    points
    |> with_erosion_levels(depth, target)
    |> Enum.into(%{}, fn {point, erosion_level} -> {point, find_type(erosion_level)} end)
  end

  defp with_erosion_levels(points, depth, target) do
    points
    |> Enum.sort()
    |> Enum.reduce(%{}, fn point, cache ->
      geo_index = calc_geo_index(point, cache, target)
      erosion_level = rem(geo_index + depth, 20183)
      Map.put(cache, point, erosion_level)
    end)
  end

  defp calc_geo_index({0, 0}, _cache, _target), do: 0
  defp calc_geo_index(target, _cache, target), do: 0
  defp calc_geo_index({x, 0}, _cache, _target), do: x * 16807
  defp calc_geo_index({0, y}, _cache, _target), do: y * 48271
  defp calc_geo_index({x, y}, cache, _target), do: Map.fetch!(cache, {x - 1, y}) * Map.fetch!(cache, {x, y - 1})

  defp find_type(erosion_level) do
    case rem(erosion_level, 3) do
      0 -> :rocky
      1 -> :wet
      2 -> :narrow
    end
  end

  defp find_risk_level(:rocky), do: 0
  defp find_risk_level(:wet), do: 1
  defp find_risk_level(:narrow), do: 2
end
