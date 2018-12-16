defmodule Advent.Day15 do
  @moduledoc """
  https://adventofcode.com/2018/day/15
  """

  defmodule Creature do
    @moduledoc "An elf or a goblin"
    defstruct [:type, :id, :attack_power, :hit_points]

    def new(type, id, attack_power, hit_points) do
      %__MODULE__{type: type, id: id, attack_power: attack_power, hit_points: hit_points}
    end

    def reduce_hp(creature, amount) do
      %{creature | hit_points: creature.hit_points - amount}
    end
  end

  @type state :: {maze :: map, creatures :: map}
  @type point :: {non_neg_integer, non_neg_integer}

  @hit_points 200
  @common_attack_power 3

  @doc "Part 1"
  @spec outcome(String.t()) :: integer
  def outcome(input) do
    {{maze, creatures}, steps} =
      input
      |> parse(@common_attack_power, @common_attack_power)
      |> count_full_steps_to_finish()

    remaining_hp =
      creatures
      |> Map.values()
      |> Enum.map(&Map.fetch!(maze, &1))
      |> Enum.map(& &1.hit_points)
      |> Enum.sum()

    remaining_hp * steps
  end

  defp count_full_steps_to_finish(state, steps \\ 0) do
    case step(state) do
      {:ok, state} -> count_full_steps_to_finish(state, steps + 1)
      {:done, state} -> {state, steps}
    end
  end

  defp step({_maze, creatures} = state) do
    creatures
    |> Enum.sort_by(fn {_id, {x, y}} -> {y, x} end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce_while(state, fn id, state ->
      case turn(state, id) do
        {:ok, state} -> {:cont, state}
        {:done, state} -> {:halt, {:done, state}}
      end
    end)
    |> case do
      {:done, state} -> {:done, state}
      state -> {:ok, state}
    end
  end

  defp turn({_maze, creatures} = state, id) do
    if Map.has_key?(creatures, id) do
      case move(state, id) do
        {:ok, state} ->
          state = attack(state, id)
          {:ok, state}

        {:done, state} ->
          {:done, state}
      end
    else
      {:ok, state}
    end
  end

  defp move({maze, creatures} = state, id) do
    origin_point = Map.fetch!(creatures, id)
    creature = Map.fetch!(maze, origin_point)

    creature.type
    |> invert_type()
    |> creature_points(state)
    |> case do
      [] -> {:done, state}
      creature_points -> move_to_creatures(state, id, origin_point, creature_points)
    end
  end

  defp move_to_creatures({maze, _creatures} = state, id, origin_point, creature_points) do
    if Enum.any?(creature_points, &next_to?(&1, origin_point)) do
      {:ok, state}
    else
      creature_points
      |> Enum.flat_map(&reach(&1, maze))
      |> closest_point_in_reading_order(maze, origin_point)
      |> case do
        {:ok, target_point} ->
          state = move_to_target(state, id, origin_point, target_point)
          {:ok, state}

        :no_path ->
          {:ok, state}
      end
    end
  end

  defp next_to?({x1, y1}, {x2, y2}) do
    (abs(x1 - x2) == 1 and y1 == y2) or (abs(y1 - y2) == 1 and x1 == x2)
  end

  defp move_to_target({maze, creatures}, id, origin, target) do
    creature = Map.fetch!(maze, origin)

    {:ok, move_to_point} =
      origin
      |> reach(maze)
      |> closest_point_in_reading_order(maze, target)

    creatures = creatures |> Map.put(id, move_to_point)
    maze = maze |> Map.put(origin, :empty) |> Map.put(move_to_point, creature)
    {maze, creatures}
  end

  defp closest_point_in_reading_order(targets, maze, origin) do
    targets = MapSet.new(targets)

    if MapSet.member?(targets, origin) do
      {:ok, origin}
    else
      visited = MapSet.new()
      last_nodes = [origin]
      closest_point_in_reading_order(targets, maze, visited, last_nodes)
    end
  end

  @spec closest_point_in_reading_order(MapSet.t(), map, MapSet.t(), [point]) :: {:ok, point} | :no_path
  defp closest_point_in_reading_order(_targets, _maze, _visited, []), do: :no_path

  defp closest_point_in_reading_order(targets, maze, visited, last_nodes) do
    nodes =
      last_nodes
      |> Enum.flat_map(&reach(&1, maze))
      |> Enum.uniq()
      |> Enum.reject(&MapSet.member?(visited, &1))
      |> Enum.sort_by(fn {x, y} -> {y, x} end)

    nodes
    |> Enum.reduce_while(visited, fn node, visited ->
      if MapSet.member?(targets, node) do
        {:halt, {:ok, node}}
      else
        {:cont, MapSet.put(visited, node)}
      end
    end)
    |> case do
      {:ok, node} -> {:ok, node}
      visited -> closest_point_in_reading_order(targets, maze, visited, nodes)
    end
  end

  defp invert_type(:goblin), do: :elf
  defp invert_type(:elf), do: :goblin

  defp creature_points(type, {maze, creatures}) do
    creatures
    |> Map.values()
    |> Enum.filter(fn point ->
      case Map.fetch!(maze, point) do
        %Creature{type: ^type} -> true
        %Creature{} -> false
      end
    end)
  end

  defp adjacent({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
  end

  defp reach(point, maze) do
    point
    |> adjacent()
    |> Enum.filter(&(Map.fetch!(maze, &1) == :empty))
  end

  defp attack({maze, creatures} = state, id) do
    point = Map.fetch!(creatures, id)
    creature = Map.fetch!(maze, point)
    target_type = invert_type(creature.type)

    point
    |> adjacent()
    |> Enum.map(fn adj_point -> {adj_point, Map.fetch!(maze, adj_point)} end)
    |> Enum.filter(fn
      {_point, %Creature{type: ^target_type}} -> true
      {_point, _} -> false
    end)
    |> case do
      [] ->
        state

      targets ->
        {target_point, target_creature} =
          targets
          |> Enum.sort_by(fn {{x, y}, creature} -> {creature.hit_points, y, x} end)
          |> hd()

        do_attack(state, creature.attack_power, target_point, target_creature)
    end
  end

  defp do_attack({maze, creatures}, attack_power, target_point, target_creature) do
    target_creature = Creature.reduce_hp(target_creature, attack_power)

    if target_creature.hit_points <= 0 do
      maze = Map.put(maze, target_point, :empty)
      creatures = Map.delete(creatures, target_creature.id)
      {maze, creatures}
    else
      maze = Map.put(maze, target_point, target_creature)
      {maze, creatures}
    end
  end

  defp parse(input, elf_attack_power, goblin_attack_power) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, maze ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(maze, fn {char, x}, maze ->
        field = parse_field(char, {x, y}, elf_attack_power, goblin_attack_power)
        Map.put(maze, {x, y}, field)
      end)
    end)
    |> extract_creatures()
  end

  defp extract_creatures(maze) do
    creatures =
      maze
      |> Enum.filter(fn
        {_point, %Creature{}} -> true
        _ -> false
      end)
      |> Enum.into(%{}, fn {point, %{id: id}} -> {id, point} end)

    {maze, creatures}
  end

  defp parse_field("#", _, _, _), do: :wall
  defp parse_field(".", _, _, _), do: :empty
  defp parse_field("G", {x, y}, _, ap), do: Creature.new(:goblin, x * 1000 + y, ap, @hit_points)
  defp parse_field("E", {x, y}, ap, _), do: Creature.new(:elf, x * 1000 + y, ap, @hit_points)
end
