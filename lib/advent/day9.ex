defmodule Advent.Day9 do
  @moduledoc """
  --- Day 9: Marble Mania ---
  You talk to the Elves while you wait for your navigation system to initialize. To pass the time, they introduce you to their favorite marble game.

  The Elves play this game by taking turns arranging the marbles in a circle according to very particular rules. The marbles are numbered starting with 0 and increasing by 1 until every marble has a number.

  First, the marble numbered 0 is placed in the circle. At this point, while it contains only a single marble, it is still a circle: the marble is both clockwise from itself and counter-clockwise from itself. This marble is designated the current marble.

  Then, each Elf takes a turn placing the lowest-numbered remaining marble into the circle between the marbles that are 1 and 2 marbles clockwise of the current marble. (When the circle is large enough, this means that there is one marble between the marble that was just placed and the current marble.) The marble that was just placed then becomes the current marble.

  However, if the marble that is about to be placed has a number which is a multiple of 23, something entirely different happens. First, the current player keeps the marble they would have placed, adding it to their score. In addition, the marble 7 marbles counter-clockwise from the current marble is removed from the circle and also added to the current player's score. The marble located immediately clockwise of the marble that was removed becomes the new current marble.

  For example, suppose there are 9 players. After the marble with value 0 is placed in the middle, each player (shown in square brackets) takes a turn. The result of each of those turns would produce circles of marbles like this, where clockwise is to the right and the resulting current marble is in parentheses:

  [-] (0)
  [1]  0 (1)
  [2]  0 (2) 1 
  [3]  0  2  1 (3)
  [4]  0 (4) 2  1  3 
  [5]  0  4  2 (5) 1  3 
  [6]  0  4  2  5  1 (6) 3 
  [7]  0  4  2  5  1  6  3 (7)
  [8]  0 (8) 4  2  5  1  6  3  7 
  [9]  0  8  4 (9) 2  5  1  6  3  7 
  [1]  0  8  4  9  2(10) 5  1  6  3  7 
  [2]  0  8  4  9  2 10  5(11) 1  6  3  7 
  [3]  0  8  4  9  2 10  5 11  1(12) 6  3  7 
  [4]  0  8  4  9  2 10  5 11  1 12  6(13) 3  7 
  [5]  0  8  4  9  2 10  5 11  1 12  6 13  3(14) 7 
  [6]  0  8  4  9  2 10  5 11  1 12  6 13  3 14  7(15)
  [7]  0(16) 8  4  9  2 10  5 11  1 12  6 13  3 14  7 15 
  [8]  0 16  8(17) 4  9  2 10  5 11  1 12  6 13  3 14  7 15 
  [9]  0 16  8 17  4(18) 9  2 10  5 11  1 12  6 13  3 14  7 15 
  [1]  0 16  8 17  4 18  9(19) 2 10  5 11  1 12  6 13  3 14  7 15 
  [2]  0 16  8 17  4 18  9 19  2(20)10  5 11  1 12  6 13  3 14  7 15 
  [3]  0 16  8 17  4 18  9 19  2 20 10(21) 5 11  1 12  6 13  3 14  7 15 
  [4]  0 16  8 17  4 18  9 19  2 20 10 21  5(22)11  1 12  6 13  3 14  7 15 
  [5]  0 16  8 17  4 18(19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15 
  [6]  0 16  8 17  4 18 19  2(24)20 10 21  5 22 11  1 12  6 13  3 14  7 15 
  [7]  0 16  8 17  4 18 19  2 24 20(25)10 21  5 22 11  1 12  6 13  3 14  7 15
  The goal is to be the player with the highest score after the last marble is used up. Assuming the example above ends after the marble numbered 25, the winning score is 23+9=32 (because player 5 kept marble 23 and removed marble 9, while no other player got any points in this very short example game).

  Here are a few more examples:

  10 players; last marble is worth 1618 points: high score is 8317
  13 players; last marble is worth 7999 points: high score is 146373
  17 players; last marble is worth 1104 points: high score is 2764
  21 players; last marble is worth 6111 points: high score is 54718
  30 players; last marble is worth 5807 points: high score is 37305
  What is the winning Elf's score?

  --- Part Two ---
  Amused by the speed of your answer, the Elves are curious:

  What would the new winning Elf's score be if the number of the last marble were 100 times larger?
  """

  defmodule Circle do
    @moduledoc """
    A circular doubly linked list implemented with a map of {node, cw, ccw} plus a pointer to current node.

    This ensures around O(1) (map lookup) time for all operations:
    - Get current node
    - Rotate
    - Add
    - Remove
    """

    @type t :: {map, any}

    @doc "Builds a new Circle with a single current node"
    @spec new(any) :: t
    def new(current) do
      {%{current => {current, current, current}}, current}
    end

    @doc "Returns the current node"
    @spec current(t) :: any
    def current({_map, pointer}), do: pointer

    @doc "Changes the current node clockwise"
    @spec rotate_cw(t) :: t
    def rotate_cw({map, pointer}) do
      pointer = map |> Map.fetch!(pointer) |> elem(1)
      {map, pointer}
    end

    @doc "Changes the current node counter-clockwise"
    @spec rotate_ccw(t) :: t
    def rotate_ccw({map, pointer}) do
      pointer = map |> Map.fetch!(pointer) |> elem(2)
      {map, pointer}
    end

    @doc "Rotates n times"
    @spec rotate_ccw(t, non_neg_integer) :: t
    def rotate_ccw(circle, 0), do: circle
    def rotate_ccw(circle, n) when n > 0, do: circle |> rotate_ccw() |> rotate_ccw(n - 1)

    @doc "Adds a new node clockwise to current"
    @spec add_cw(t, any) :: t
    def add_cw({map, pointer}, value) do
      current_cw = map |> Map.fetch!(pointer) |> elem(1)

      map =
        map
        |> Map.update!(pointer, fn {n, _cw, ccw} -> {n, value, ccw} end)
        |> Map.update!(current_cw, fn {n, cw, _ccw} -> {n, cw, value} end)
        |> Map.put(value, {value, current_cw, pointer})

      {map, pointer}
    end

    @doc "Adds a new node counter-clockwise to current"
    @spec add_ccw(t, any) :: t
    def add_ccw({map, pointer}, value) do
      current_ccw = map |> Map.fetch!(pointer) |> elem(2)

      map =
        map
        |> Map.update!(pointer, fn {n, cw, _ccw} -> {n, cw, value} end)
        |> Map.update!(current_ccw, fn {n, _cw, ccw} -> {n, value, ccw} end)
        |> Map.put(value, {value, pointer, current_ccw})

      {map, pointer}
    end

    @doc "Removes the current node. The new current becomes the clockwise node of the old current"
    @spec remove_current(t) :: t
    def remove_current({map, pointer}) do
      {^pointer, current_cw, current_ccw} = Map.fetch!(map, pointer)

      map =
        map
        |> Map.update!(current_cw, fn {n, cw, _ccw} -> {n, cw, current_ccw} end)
        |> Map.update!(current_ccw, fn {n, _cw, ccw} -> {n, current_cw, ccw} end)
        |> Map.delete(pointer)

      {map, current_cw}
    end
  end

  @doc "Part 1"
  @spec high_score(integer, integer) :: integer
  def high_score(num_players, max_value) do
    circle = Circle.new(0)
    scores = 1..num_players |> Enum.into(%{}, &{&1, 0})

    {_circle, scores} =
      1..num_players
      |> Enum.into([])
      |> Stream.cycle()
      |> Stream.zip(1..max_value)
      |> Enum.reduce({circle, scores}, fn {player, marble}, {circle, scores} ->
        if rem(marble, 23) == 0 do
          circle = Circle.rotate_ccw(circle, 7)
          removed_marble = Circle.current(circle)
          circle = Circle.remove_current(circle)

          scores = Map.update!(scores, player, &(&1 + removed_marble + marble))

          {circle, scores}
        else
          circle =
            circle
            |> Circle.rotate_cw()
            |> Circle.add_cw(marble)
            |> Circle.rotate_cw()

          {circle, scores}
        end
      end)

    scores
    |> Map.values()
    |> Enum.max()
  end
end
