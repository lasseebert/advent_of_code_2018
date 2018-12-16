defmodule Advent.Day15 do
  @moduledoc """
  https://adventofcode.com/2018/day/15
  """

  defmodule Creature do
    @moduledoc "An elf or a goblin"
    defstruct [:type, :id, :attack_power, :hit_points]

    def new(type, id, hit_points) do
      %__MODULE__{type: type, id: id, hit_points: hit_points}
    end

    def reduce_hp(creature, amount) do
      %{creature | hit_points: creature.hit_points - amount}
    end

    def set_attack_power(creature, attack_power) do
      %{creature | attack_power: attack_power}
    end
  end

  defmodule State do
    @moduledoc "The maze and all creatures"
    defstruct [:maze, :creatures]

    def new(maze, creatures) do
      %__MODULE__{maze: maze, creatures: creatures}
    end

    def set_attack_power(state, creature_type, attack_power) do
      maze =
        state.maze
        |> Enum.into(%{}, fn
          {point, %Creature{type: ^creature_type} = creature} ->
            {point, Creature.set_attack_power(creature, attack_power)}

          other ->
            other
        end)

      %{state | maze: maze}
    end

    def count_elves(state) do
      state.creatures
      |> Map.values()
      |> Enum.map(&Map.fetch!(state.maze, &1))
      |> Enum.count(fn
        %Creature{type: :elf} -> true
        _ -> false
      end)
    end
  end

  @type state :: {maze :: map, creatures :: map}
  @type point :: {non_neg_integer, non_neg_integer}

  @hit_points 200
  @common_attack_power 3

  @doc "Part 1"
  @spec outcome(String.t()) :: integer
  def outcome(input) do
    input
    |> parse()
    |> State.set_attack_power(:elf, @common_attack_power)
    |> State.set_attack_power(:goblin, @common_attack_power)
    |> calc_outcome()
  end

  @doc "Part 2"
  @spec outcome_elf_win(String.t()) :: integer
  def outcome_elf_win(input) do
    state = input |> parse() |> State.set_attack_power(:goblin, @common_attack_power)

    upper_bound = find_upper_bound(state, 4)
    ap = binary_search(state, 4, upper_bound)

    input
    |> parse()
    |> State.set_attack_power(:elf, ap)
    |> State.set_attack_power(:goblin, @common_attack_power)
    |> calc_outcome()
  end

  defp binary_search(_, same, same), do: same

  defp binary_search(init_state, lower, upper) do
    elf_ap = div(lower + upper, 2)

    {end_state, _steps} =
      init_state
      |> State.set_attack_power(:elf, elf_ap)
      |> count_full_steps_to_finish()

    if State.count_elves(init_state) == State.count_elves(end_state) do
      binary_search(init_state, lower, elf_ap)
    else
      binary_search(init_state, elf_ap + 1, upper)
    end
  end

  defp find_upper_bound(init_state, elf_ap) do
    {end_state, _steps} =
      init_state
      |> State.set_attack_power(:elf, elf_ap)
      |> count_full_steps_to_finish()

    if State.count_elves(init_state) == State.count_elves(end_state) do
      elf_ap
    else
      find_upper_bound(init_state, elf_ap * 2)
    end
  end

  defp calc_outcome(state) do
    {state, steps} = count_full_steps_to_finish(state)

    remaining_hp =
      state.creatures
      |> Map.values()
      |> Enum.map(&Map.fetch!(state.maze, &1))
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

  defp step(state) do
    state.creatures
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

  defp turn(state, id) do
    if Map.has_key?(state.creatures, id) do
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

  defp move(state, id) do
    origin_point = Map.fetch!(state.creatures, id)
    creature = Map.fetch!(state.maze, origin_point)

    creature.type
    |> invert_type()
    |> creature_points(state)
    |> case do
      [] -> {:done, state}
      creature_points -> move_to_creatures(state, id, origin_point, creature_points)
    end
  end

  defp move_to_creatures(state, id, origin_point, creature_points) do
    if Enum.any?(creature_points, &next_to?(&1, origin_point)) do
      {:ok, state}
    else
      creature_points
      |> Enum.flat_map(&reach(&1, state.maze))
      |> closest_point_in_reading_order(state.maze, origin_point)
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

  defp move_to_target(state, id, origin, target) do
    creature = Map.fetch!(state.maze, origin)

    {:ok, move_to_point} =
      origin
      |> reach(state.maze)
      |> closest_point_in_reading_order(state.maze, target)

    creatures = state.creatures |> Map.put(id, move_to_point)
    maze = state.maze |> Map.put(origin, :empty) |> Map.put(move_to_point, creature)
    %{state | maze: maze, creatures: creatures}
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

  defp creature_points(type, state) do
    state.creatures
    |> Map.values()
    |> Enum.filter(fn point ->
      case Map.fetch!(state.maze, point) do
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

  defp attack(state, id) do
    point = Map.fetch!(state.creatures, id)
    creature = Map.fetch!(state.maze, point)
    target_type = invert_type(creature.type)

    point
    |> adjacent()
    |> Enum.map(fn adj_point -> {adj_point, Map.fetch!(state.maze, adj_point)} end)
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

  defp do_attack(state, attack_power, target_point, target_creature) do
    target_creature = Creature.reduce_hp(target_creature, attack_power)

    if target_creature.hit_points <= 0 do
      maze = Map.put(state.maze, target_point, :empty)
      creatures = Map.delete(state.creatures, target_creature.id)
      %{state | maze: maze, creatures: creatures}
    else
      maze = Map.put(state.maze, target_point, target_creature)
      %{state | maze: maze}
    end
  end

  defp parse(input) do
    maze =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, maze ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(maze, fn {char, x}, maze ->
          field = parse_field(char, {x, y})
          Map.put(maze, {x, y}, field)
        end)
      end)

    creatures = extract_creatures(maze)
    State.new(maze, creatures)
  end

  defp extract_creatures(maze) do
    maze
    |> Enum.filter(fn
      {_point, %Creature{}} -> true
      _ -> false
    end)
    |> Enum.into(%{}, fn {point, %{id: id}} -> {id, point} end)
  end

  defp parse_field("#", _), do: :wall
  defp parse_field(".", _), do: :empty
  defp parse_field("G", {x, y}), do: Creature.new(:goblin, x * 1000 + y, @hit_points)
  defp parse_field("E", {x, y}), do: Creature.new(:elf, x * 1000 + y, @hit_points)
end
