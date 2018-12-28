defmodule Advent.Day23 do
  @moduledoc """
  https://adventofcode.com/2018/day/23
  """

  def part1(input) do
    bots = parse(input)
    {strongest_bot, strongest_signal} = Enum.max_by(bots, &elem(&1, 1))
    Enum.count(bots, fn {bot, _signal} -> manhattan_distance(bot, strongest_bot) <= strongest_signal end)
  end

  def part2(input) do
    bots = parse(input)
    box = bounding_box(bots)
    queue = HeapQueue.new() |> HeapQueue.push({0, nil, nil}, {box, bots})

    queue
    |> find_best_point()
    |> Tuple.to_list()
    |> Enum.sum()
  end

  defp find_best_point(queue) do
    {{:value, _priority, {box, bots}}, queue} = HeapQueue.pop(queue)

    case box do
      {point, point} ->
        # Box has size 1 and is the one with the most bots in range closest to origin. Call it a success!
        point

      box ->
        # Divide and conquer
        {box_1, box_2} = divide_box(box)

        queue
        |> add_box_to_queue(box_1, bots)
        |> add_box_to_queue(box_2, bots)
        |> find_best_point()
    end
  end

  # Finds the box that spans all bots
  defp bounding_box(bots) do
    [{x1, x2}, {y1, y2}, {z1, z2}] =
      bots
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&Enum.min_max/1)

    {{x1, y1, z1}, {x2, y2, z2}}
  end

  # Divides a box into two smaller boxes on the widest axis
  defp divide_box({{x1, y1, z1}, {x2, y2, z2}}) do
    [
      {x2 - x1, :x},
      {y2 - y1, :y},
      {z2 - z1, :z}
    ]
    |> Enum.sort()
    |> Enum.reverse()
    |> hd()
    |> elem(1)
    |> case do
      :x -> {{{x1, y1, z1}, {div(x1 + x2, 2), y2, z2}}, {{div(x1 + x2, 2) + 1, y1, z1}, {x2, y2, z2}}}
      :y -> {{{x1, y1, z1}, {x2, div(y1 + y2, 2), z2}}, {{x1, div(y1 + y2, 2) + 1, z1}, {x2, y2, z2}}}
      :z -> {{{x1, y1, z1}, {x2, y2, div(z1 + z2, 2)}}, {{x1, y1, div(z1 + z2, 2) + 1}, {x2, y2, z2}}}
    end
  end

  defp add_box_to_queue(queue, box, bots) do
    bots = bots_in_range_of_box(box, bots)

    priority = {
      -length(bots),
      box_distance_to_origin(box),
      box_size(box)
    }

    HeapQueue.push(queue, priority, {box, bots})
  end

  defp bots_in_range_of_box(box, bots) do
    Enum.filter(bots, &bot_in_range_of_box?(box, &1))
  end

  defp bot_in_range_of_box?({{x1, y1, z1}, {x2, y2, z2}}, {{bx, by, bz}, range}) do
    axis_distance_to_box(x1, x2, bx) + axis_distance_to_box(y1, y2, by) + axis_distance_to_box(z1, z2, bz) <= range
  end

  defp axis_distance_to_box(low, high, bot) do
    cond do
      bot < low -> low - bot
      high < bot -> bot - high
      true -> 0
    end
  end

  defp box_distance_to_origin({low, _high}), do: low
  defp box_size({{x1, y1, z1}, {x2, y2, z2}}), do: (x2 - x1 + 1) * (y2 - y1 + 1) * (z2 - z1 + 1)
  defp manhattan_distance({x1, y1, z1}, {x2, y2, z2}), do: abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [x, y, z, r] =
      ~r/^pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)$/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    {{x, y, z}, r}
  end
end
