defmodule Advent.Day14 do
  @moduledoc """
  --- Day 14: Chocolate Charts ---
  You finally have a chance to look at all of the produce moving around. Chocolate, cinnamon, mint, chili peppers, nutmeg, vanilla... the Elves must be growing these plants to make hot chocolate! As you realize this, you hear a conversation in the distance. When you go to investigate, you discover two Elves in what appears to be a makeshift underground kitchen/laboratory.

  The Elves are trying to come up with the ultimate hot chocolate recipe; they're even maintaining a scoreboard which tracks the quality score (0-9) of each recipe.

  Only two recipes are on the board: the first recipe got a score of 3, the second, 7. Each of the two Elves has a current recipe: the first Elf starts with the first recipe, and the second Elf starts with the second recipe.

  To create new recipes, the two Elves combine their current recipes. This creates new recipes from the digits of the sum of the current recipes' scores. With the current recipes' scores of 3 and 7, their sum is 10, and so two new recipes would be created: the first with score 1 and the second with score 0. If the current recipes' scores were 2 and 3, the sum, 5, would only create one recipe (with a score of 5) with its single digit.

  The new recipes are added to the end of the scoreboard in the order they are created. So, after the first round, the scoreboard is 3, 7, 1, 0.

  After all new recipes are added to the scoreboard, each Elf picks a new current recipe. To do this, the Elf steps forward through the scoreboard a number of recipes equal to 1 plus the score of their current recipe. So, after the first round, the first Elf moves forward 1 + 3 = 4 times, while the second Elf moves forward 1 + 7 = 8 times. If they run out of recipes, they loop back around to the beginning. After the first round, both Elves happen to loop around until they land on the same recipe that they had in the beginning; in general, they will move to different recipes.

  Drawing the first Elf as parentheses and the second Elf as square brackets, they continue this process:

  (3)[7]
  (3)[7] 1  0 
  3  7  1 [0](1) 0 
  3  7  1  0 [1] 0 (1)
  (3) 7  1  0  1  0 [1] 2 
  3  7  1  0 (1) 0  1  2 [4]
  3  7  1 [0] 1  0 (1) 2  4  5 
  3  7  1  0 [1] 0  1  2 (4) 5  1 
  3 (7) 1  0  1  0 [1] 2  4  5  1  5 
  3  7  1  0  1  0  1  2 [4](5) 1  5  8 
  3 (7) 1  0  1  0  1  2  4  5  1  5  8 [9]
  3  7  1  0  1  0  1 [2] 4 (5) 1  5  8  9  1  6 
  3  7  1  0  1  0  1  2  4  5 [1] 5  8  9  1 (6) 7 
  3  7  1  0 (1) 0  1  2  4  5  1  5 [8] 9  1  6  7  7 
  3  7 [1] 0  1  0 (1) 2  4  5  1  5  8  9  1  6  7  7  9 
  3  7  1  0 [1] 0  1  2 (4) 5  1  5  8  9  1  6  7  7  9  2 
  The Elves think their skill will improve after making a few recipes (your puzzle input). However, that could take ages; you can speed this up considerably by identifying the scores of the ten recipes after that. For example:

  If the Elves think their skill will improve after making 9 recipes, the scores of the ten recipes after the first nine on the scoreboard would be 5158916779 (highlighted in the last line of the diagram).
  After 5 recipes, the scores of the next ten would be 0124515891.
  After 18 recipes, the scores of the next ten would be 9251071085.
  After 2018 recipes, the scores of the next ten would be 5941429882.
  What are the scores of the ten recipes immediately after the number of recipes in your puzzle input?
  """

  @doc "Part 1"
  @spec part1(integer) :: String.t()
  def part1(count) do
    state = init_state() |> loop_to_count(count + 10)

    count..(count + 9)
    |> Enum.map(&Map.fetch!(state.list, &1))
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("")
  end

  @doc "Part 2"
  @spec part2(String.t()) :: integer
  def part2(scores_string) do
    scores = scores_string |> String.graphemes() |> Enum.map(&String.to_integer/1)
    state = init_state(length(scores)) |> loop_to_scores(scores)

    state.next - length(scores)
  end

  defp init_state(count_last_scores \\ 0) do
    %{
      list: %{0 => 3, 1 => 7},
      elves: [0, 1],
      next: 2,
      last_scores: List.duplicate(nil, count_last_scores)
    }
  end

  defp loop_to_scores(%{last_scores: last_scores} = state, target) when target == last_scores, do: state

  defp loop_to_scores(state, target) do
    state
    |> add_recipies(target)
    |> move_elves()
    |> loop_to_scores(target)
  end

  defp loop_to_count(%{next: next} = state, count) when next > count, do: state

  defp loop_to_count(state, count) do
    state
    |> add_recipies()
    |> move_elves()
    |> loop_to_count(count)
  end

  defp add_recipies(state, target \\ nil) do
    state
    |> new_scores()
    |> Enum.reduce_while(state, fn score, state ->
      state = add_score(state, score)

      if state.last_scores == target do
        {:halt, state}
      else
        {:cont, state}
      end
    end)
  end

  defp new_scores(state) do
    state.elves
    |> Enum.map(&Map.fetch!(state.list, &1))
    |> Enum.sum()
    |> sum_to_scores()
  end

  defp sum_to_scores(n) when n < 10, do: [n]
  defp sum_to_scores(n), do: [div(n, 10), rem(n, 10)]

  defp add_score(state, score) do
    %{
      state
      | list: state.list |> Map.put(state.next, score),
        next: state.next + 1,
        last_scores: add_last_score(score, state.last_scores)
    }
  end

  defp add_last_score(_score, []), do: []
  defp add_last_score(score, [_v1, v2, v3, v4, v5]), do: [v2, v3, v4, v5, score]
  defp add_last_score(score, [_v1, v2, v3, v4, v5, v6]), do: [v2, v3, v4, v5, v6, score]

  defp move_elves(state) do
    elves =
      state.elves
      |> Enum.map(fn index ->
        score = Map.fetch!(state.list, index)
        rem(index + score + 1, state.next)
      end)

    %{state | elves: elves}
  end
end
