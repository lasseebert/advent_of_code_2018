defmodule Advent.Day13 do
  @moduledoc """
  --- Day 13: Mine Cart Madness ---
  A crop of this size requires significant logistics to transport produce, soil, fertilizer, and so on. The Elves are very busy pushing things around in carts on some kind of rudimentary system of tracks they've come up with.

  Seeing as how cart-and-track systems don't appear in recorded history for another 1000 years, the Elves seem to be making this up as they go along. They haven't even figured out how to avoid collisions yet.

  You map out the tracks (your puzzle input) and see where you can help.

  Tracks consist of straight paths (| and -), curves (/ and \), and intersections (+). Curves connect exactly two perpendicular pieces of track; for example, this is a closed loop:

  /----\
  |    |
  |    |
  \----/
  Intersections occur when two perpendicular paths cross. At an intersection, a cart is capable of turning left, turning right, or continuing straight. Here are two loops connected by two intersections:

  /-----\
  |     |
  |  /--+--\
  |  |  |  |
  \--+--/  |
   |     |
   \-----/
  Several carts are also on the tracks. Carts always face either up (^), down (v), left (<), or right (>). (On your initial map, the track under each cart is a straight path matching the direction the cart is facing.)

  Each time a cart has the option to turn (by arriving at any intersection), it turns left the first time, goes straight the second time, turns right the third time, and then repeats those directions starting again with left the fourth time, straight the fifth time, and so on. This process is independent of the particular intersection at which the cart has arrived - that is, the cart has no per-intersection memory.

  Carts all move at the same speed; they take turns moving a single step at a time. They do this based on their current location: carts on the top row move first (acting from left to right), then carts on the second row move (again from left to right), then carts on the third row, and so on. Once each cart has moved one step, the process repeats; each of these loops is called a tick.

  For example, suppose there are two carts on a straight track:

  |  |  |  |  |
  v  |  |  |  |
  |  v  v  |  |
  |  |  |  v  X
  |  |  ^  ^  |
  ^  ^  |  |  |
  |  |  |  |  |
  First, the top cart moves. It is facing down (v), so it moves down one square. Second, the bottom cart moves. It is facing up (^), so it moves up one square. Because all carts have moved, the first tick ends. Then, the process repeats, starting with the first cart. The first cart moves down, then the second cart moves up - right into the first cart, colliding with it! (The location of the crash is marked with an X.) This ends the second and last tick.

  Here is a longer example:

  /->-\        
  |   |  /----\
  | /-+--+-\  |
  | | |  | v  |
  \-+-/  \-+--/
  \------/   

  /-->\        
  |   |  /----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \->--/
  \------/   

  /---v        
  |   |  /----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \-+>-/
  \------/   

  /---\        
  |   v  /----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \-+->/
  \------/   

  /---\        
  |   |  /----\
  | /->--+-\  |
  | | |  | |  |
  \-+-/  \-+--^
  \------/   

  /---\        
  |   |  /----\
  | /-+>-+-\  |
  | | |  | |  ^
  \-+-/  \-+--/
  \------/   

  /---\        
  |   |  /----\
  | /-+->+-\  ^
  | | |  | |  |
  \-+-/  \-+--/
  \------/   

  /---\        
  |   |  /----<
  | /-+-->-\  |
  | | |  | |  |
  \-+-/  \-+--/
  \------/   

  /---\        
  |   |  /---<\
  | /-+--+>\  |
  | | |  | |  |
  \-+-/  \-+--/
  \------/   

  /---\        
  |   |  /--<-\
  | /-+--+-v  |
  | | |  | |  |
  \-+-/  \-+--/
  \------/   

  /---\        
  |   |  /-<--\
  | /-+--+-\  |
  | | |  | v  |
  \-+-/  \-+--/
  \------/   

  /---\        
  |   |  /<---\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \-<--/
  \------/   

  /---\        
  |   |  v----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \<+--/
  \------/   

  /---\        
  |   |  /----\
  | /-+--v-\  |
  | | |  | |  |
  \-+-/  ^-+--/
  \------/   

  /---\        
  |   |  /----\
  | /-+--+-\  |
  | | |  X |  |
  \-+-/  \-+--/
  \------/   
  After following their respective paths for a while, the carts eventually crash. To help prevent crashes, you'd like to know the location of the first crash. Locations are given in X,Y coordinates, where the furthest left column is X=0 and the furthest top row is Y=0:

           111
  0123456789012
  0/---\        
  1|   |  /----\
  2| /-+--+-\  |
  3| | |  X |  |
  4\-+-/  \-+--/
  5  \------/   
  In this example, the location of the first crash is 7,3.
  """

  @type point :: {non_neg_integer, non_neg_integer}
  @type tracks :: %{optional(point) => track}
  @type track :: :slash_curve | :backslash_curve | :horizontal | :vertical | :intersection
  @type carts :: %{optional(point) => cart}
  @type cart :: {direction, turn}
  @type direction :: :north | :south | :east | :west
  @type turn :: :left | :right | :straight

  @doc "Part 1"
  @spec crash_location(String.t()) :: point
  def crash_location(input) do
    {tracks, carts} = parse(input)
    run_to_crash(tracks, carts)
  end

  @doc "Part 2"
  @spec crash_location(String.t()) :: point
  def last_cart_location(input) do
    {tracks, carts} = parse(input)
    run_to_one(tracks, carts)
  end

  defp run_to_crash(tracks, carts) do
    case tick_halt_on_crash(tracks, carts) do
      {:ok, carts} -> run_to_crash(tracks, carts)
      {:crash, point} -> point
    end
  end

  defp run_to_one(tracks, carts) do
    carts = tick_remove_crash(tracks, carts)

    if carts |> Map.keys() |> length() == 1 do
      carts |> Map.keys() |> hd()
    else
      run_to_one(tracks, carts)
    end
  end

  @spec tick_halt_on_crash(tracks, carts) :: {:ok, carts} | {:crash, point}
  defp tick_halt_on_crash(tracks, carts) do
    carts
    |> Map.keys()
    |> Enum.sort_by(fn {x, y} -> {y, x} end)
    |> Enum.reduce_while(carts, fn cart_point, carts ->
      cart = Map.fetch!(carts, cart_point)
      carts = Map.delete(carts, cart_point)

      case move_cart(tracks, carts, {cart_point, cart}) do
        {:ok, {new_point, new_cart}} ->
          carts = Map.put(carts, new_point, new_cart)
          {:cont, carts}

        {:crash, point} ->
          {:halt, {:crash, point}}
      end
    end)
    |> case do
      {:crash, point} -> {:crash, point}
      carts -> {:ok, carts}
    end
  end

  defp tick_remove_crash(tracks, carts) do
    carts
    |> Map.keys()
    |> Enum.sort_by(fn {x, y} -> {y, x} end)
    |> Enum.reduce(carts, fn cart_point, carts ->
      case Map.fetch(carts, cart_point) do
        {:ok, cart} ->
          carts = Map.delete(carts, cart_point)

          case move_cart(tracks, carts, {cart_point, cart}) do
            {:ok, {new_point, new_cart}} ->
              Map.put(carts, new_point, new_cart)

            {:crash, point} ->
              Map.delete(carts, point)
          end

        :error ->
          carts
      end
    end)
  end

  @spec move_cart(tracks, carts, {point, cart}) :: {:ok, {point, cart}} | {:crash, point}
  def move_cart(tracks, other_carts, {point, cart}) do
    new_point = move_forward(point, cart)

    if Map.has_key?(other_carts, new_point) do
      {:crash, new_point}
    else
      new_cart = turn(tracks, new_point, cart)
      {:ok, {new_point, new_cart}}
    end
  end

  defp move_forward({x, y}, {:north, _}), do: {x, y - 1}
  defp move_forward({x, y}, {:south, _}), do: {x, y + 1}
  defp move_forward({x, y}, {:west, _}), do: {x - 1, y}
  defp move_forward({x, y}, {:east, _}), do: {x + 1, y}

  defp turn(tracks, point, cart) do
    track = Map.fetch!(tracks, point)

    case {track, cart} do
      {:horizontal, cart} -> cart
      {:vertical, cart} -> cart
      {:slash_curve, {:east, turn}} -> {:north, turn}
      {:slash_curve, {:west, turn}} -> {:south, turn}
      {:slash_curve, {:north, turn}} -> {:east, turn}
      {:slash_curve, {:south, turn}} -> {:west, turn}
      {:backslash_curve, {:east, turn}} -> {:south, turn}
      {:backslash_curve, {:west, turn}} -> {:north, turn}
      {:backslash_curve, {:north, turn}} -> {:west, turn}
      {:backslash_curve, {:south, turn}} -> {:east, turn}
      {:intersection, {:south, :left}} -> {:east, :straight}
      {:intersection, {:south, :straight}} -> {:south, :right}
      {:intersection, {:south, :right}} -> {:west, :left}
      {:intersection, {:north, :left}} -> {:west, :straight}
      {:intersection, {:north, :straight}} -> {:north, :right}
      {:intersection, {:north, :right}} -> {:east, :left}
      {:intersection, {:east, :left}} -> {:north, :straight}
      {:intersection, {:east, :straight}} -> {:east, :right}
      {:intersection, {:east, :right}} -> {:south, :left}
      {:intersection, {:west, :left}} -> {:south, :straight}
      {:intersection, {:west, :straight}} -> {:west, :right}
      {:intersection, {:west, :right}} -> {:north, :left}
    end
  end

  @spec parse(String.t()) :: {tracks, carts}
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Enum.reduce({%{}, %{}}, fn {point, char}, {tracks, carts} ->
      case char do
        "|" -> {Map.put(tracks, point, :vertical), carts}
        "-" -> {Map.put(tracks, point, :horizontal), carts}
        "/" -> {Map.put(tracks, point, :slash_curve), carts}
        "\\" -> {Map.put(tracks, point, :backslash_curve), carts}
        "+" -> {Map.put(tracks, point, :intersection), carts}
        "v" -> {Map.put(tracks, point, :vertical), Map.put(carts, point, {:south, :left})}
        "^" -> {Map.put(tracks, point, :vertical), Map.put(carts, point, {:north, :left})}
        "<" -> {Map.put(tracks, point, :horizontal), Map.put(carts, point, {:west, :left})}
        ">" -> {Map.put(tracks, point, :horizontal), Map.put(carts, point, {:east, :left})}
        " " -> {tracks, carts}
      end
    end)
  end
end
