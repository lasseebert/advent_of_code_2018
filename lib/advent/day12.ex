defmodule Advent.Day12 do
  @moduledoc """
  --- Day 12: Subterranean Sustainability ---
  The year 518 is significantly more underground than your history books implied. Either that, or you've arrived in a vast cavern network under the North Pole.

  After exploring a little, you discover a long tunnel that contains a row of small pots as far as you can see to your left and right. A few of them contain plants - someone is trying to grow things in these geothermally-heated caves.

  The pots are numbered, with 0 in front of you. To the left, the pots are numbered -1, -2, -3, and so on; to the right, 1, 2, 3.... Your puzzle input contains a list of pots from 0 to the right and whether they do (#) or do not (.) currently contain a plant, the initial state. (No other pots currently contain plants.) For example, an initial state of #..##.... indicates that pots 0, 3, and 4 currently contain plants.

  Your puzzle input also contains some notes you find on a nearby table: someone has been trying to figure out how these plants spread to nearby pots. Based on the notes, for each generation of plants, a given pot has or does not have a plant based on whether that pot (and the two pots on either side of it) had a plant in the last generation. These are written as LLCRR => N, where L are pots to the left, C is the current pot being considered, R are the pots to the right, and N is whether the current pot will have a plant in the next generation. For example:

  A note like ..#.. => . means that a pot that contains a plant but with no plants within two pots of it will not have a plant in it during the next generation.
  A note like ##.## => . means that an empty pot with two plants on each side of it will remain empty in the next generation.
  A note like .##.# => # means that a pot has a plant in a given generation if, in the previous generation, there were plants in that pot, the one immediately to the left, and the one two pots to the right, but not in the ones immediately to the right and two to the left.
  It's not clear what these plants are for, but you're sure it's important, so you'd like to make sure the current configuration of plants is sustainable by determining what will happen after 20 generations.

  For example, given the following input:

  initial state: #..#.#..##......###...###

  ...## => #
  ..#.. => #
  .#... => #
  .#.#. => #
  .#.## => #
  .##.. => #
  .#### => #
  #.#.# => #
  #.### => #
  ##.#. => #
  ##.## => #
  ###.. => #
  ###.# => #
  ####. => #
  For brevity, in this example, only the combinations which do produce a plant are listed. (Your input includes all possible combinations.) Then, the next 20 generations will look like this:

                 1         2         3     
       0         0         0         0     
  0: ...#..#.#..##......###...###...........
  1: ...#...#....#.....#..#..#..#...........
  2: ...##..##...##....#..#..#..##..........
  3: ..#.#...#..#.#....#..#..#...#..........
  4: ...#.#..#...#.#...#..#..##..##.........
  5: ....#...##...#.#..#..#...#...#.........
  6: ....##.#.#....#...#..##..##..##........
  7: ...#..###.#...##..#...#...#...#........
  8: ...#....##.#.#.#..##..##..##..##.......
  9: ...##..#..#####....#...#...#...#.......
  10: ..#.#..#...#.##....##..##..##..##......
  11: ...#...##...#.#...#.#...#...#...#......
  12: ...##.#.#....#.#...#.#..##..##..##.....
  13: ..#..###.#....#.#...#....#...#...#.....
  14: ..#....##.#....#.#..##...##..##..##....
  15: ..##..#..#.#....#....#..#.#...#...#....
  16: .#.#..#...#.#...##...#...#.#..##..##...
  17: ..#...##...#.#.#.#...##...#....#...#...
  18: ..##.#.#....#####.#.#.#...##...##..##..
  19: .#..###.#..#.#.#######.#.#.#..#.#...#..
  20: .#....##....#####...#######....#.#..##.
  The generation is shown along the left, where 0 is the initial state. The pot numbers are shown along the top, where 0 labels the center pot, negative-numbered pots extend to the left, and positive pots extend toward the right. Remember, the initial state begins at pot 0, which is not the leftmost pot used in this example.

  After one generation, only seven plants remain. The one in pot 0 matched the rule looking for ..#.., the one in pot 4 matched the rule looking for .#.#., pot 9 matched .##.., and so on.

  In this example, after 20 generations, the pots shown as # contain plants, the furthest left of which is pot -2, and the furthest right of which is pot 34. Adding up all the numbers of plant-containing pots after the 20th generation produces 325.

  After 20 generations, what is the sum of the numbers of all pots which contain a plant?
  """

  @type state :: MapSet.t()
  @type rules :: MapSet.t()

  @doc "Part 1 and 2"
  @spec sum_pots(String.t(), integer) :: integer
  def sum_pots(input, count) do
    {state, rules} = parse(input)

    {head, repeat, offset} = find_repeat(state, rules, [])

    if count < length(head) do
      {state, offset} = head |> Enum.at(count)
      Enum.sum(state) + length(state) * offset
    else
      rounds = div(count - length(head), length(repeat))
        index = rem(count, length(repeat))

      {finish_state, state_offset} = Enum.at(repeat, index)
      total_offset = offset * rounds + state_offset
      Enum.sum(finish_state) + total_offset * length(finish_state)
    end
  end

  def sum_pots_slow(input, count) do
    {state, rules} = parse(input)

    state
    |> step_many(rules, count)
    |> Enum.sum()
  end

  defp step_many(state, _rules, 0), do: state
  defp step_many(state, rules, n) when n > 0, do: state |> step(rules) |> step_many(rules, n - 1)

  defp find_repeat(state, rules, repeat) do
    offset = Enum.min(state)
    state_key = state |> Enum.map(&(&1 - offset)) |> Enum.sort()

    if Enum.any?(repeat, fn {key, _offset} -> key == state_key end) do
      repeat = Enum.reverse(repeat)
      {_, start_offset} = start = repeat |> Enum.find(repeat, fn {key, _offset} -> key == state_key end)
      {head, repeat} = Enum.split_while(repeat, fn row -> row != start end)
      repeat_offset = offset - start_offset
      {head, repeat, repeat_offset}
    else
      repeat = [{state_key, offset} | repeat]

      state
      |> step(rules)
      |> find_repeat(rules, repeat)
    end
  end

  defp step(state, rules) do
    {min, max} = Enum.min_max(state)

    (min - 2)..(max + 2)
    |> Enum.reduce(MapSet.new(), fn index, new_state ->
      if plant_next_step?(state, rules, index) do
        MapSet.put(new_state, index)
      else
        new_state
      end
    end)
  end

  defp plant_next_step?(state, rules, index) do
    signature = (index - 2)..(index + 2) |> Enum.map(&MapSet.member?(state, &1))
    MapSet.member?(rules, signature)
  end

  @spec parse(String.t()) :: {state, rules}
  defp parse(input) do
    [state_string | lines] = input |> String.split("\n", trim: true)

    state = parse_state(state_string)
    rules = parse_rules(lines)

    {state, rules}
  end

  defp parse_state("initial state: " <> pots_string) do
    pots_string
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reject(fn {char, _index} -> char == "." end)
    |> Enum.map(fn {"#", index} -> index end)
    |> MapSet.new()
  end

  defp parse_rules(lines) do
    lines
    |> Enum.map(&String.split(&1, " => "))
    |> Enum.reject(fn [_sig, char] -> char == "." end)
    |> Enum.map(fn [sig, _char] -> sig end)
    |> Enum.map(fn sig ->
      sig
      |> String.graphemes()
      |> Enum.map(fn
        "." -> false
        "#" -> true
      end)
    end)
    |> MapSet.new()
  end
end
