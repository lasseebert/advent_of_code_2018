defmodule Advent.Day10 do
  @moduledoc """
  --- Day 10: The Stars Align ---
  It's no use; your navigation system simply isn't capable of providing walking directions in the arctic circle, and certainly not in 1018.

  The Elves suggest an alternative. In times like these, North Pole rescue operations will arrange points of light in the sky to guide missing Elves back to base. Unfortunately, the message is easy to miss: the points move slowly enough that it takes hours to align them, but have so much momentum that they only stay aligned for a second. If you blink at the wrong time, it might be hours before another message appears.

  You can see these points of light floating in the distance, and record their position in the sky and their velocity, the relative change in position per second (your puzzle input). The coordinates are all given from your perspective; given enough time, those positions and velocities will move the points into a cohesive message!

  Rather than wait, you decide to fast-forward the process and calculate what the points will eventually spell.

  For example, suppose you note the following points:

  position=< 9,  1> velocity=< 0,  2>
  position=< 7,  0> velocity=<-1,  0>
  position=< 3, -2> velocity=<-1,  1>
  position=< 6, 10> velocity=<-2, -1>
  position=< 2, -4> velocity=< 2,  2>
  position=<-6, 10> velocity=< 2, -2>
  position=< 1,  8> velocity=< 1, -1>
  position=< 1,  7> velocity=< 1,  0>
  position=<-3, 11> velocity=< 1, -2>
  position=< 7,  6> velocity=<-1, -1>
  position=<-2,  3> velocity=< 1,  0>
  position=<-4,  3> velocity=< 2,  0>
  position=<10, -3> velocity=<-1,  1>
  position=< 5, 11> velocity=< 1, -2>
  position=< 4,  7> velocity=< 0, -1>
  position=< 8, -2> velocity=< 0,  1>
  position=<15,  0> velocity=<-2,  0>
  position=< 1,  6> velocity=< 1,  0>
  position=< 8,  9> velocity=< 0, -1>
  position=< 3,  3> velocity=<-1,  1>
  position=< 0,  5> velocity=< 0, -1>
  position=<-2,  2> velocity=< 2,  0>
  position=< 5, -2> velocity=< 1,  2>
  position=< 1,  4> velocity=< 2,  1>
  position=<-2,  7> velocity=< 2, -2>
  position=< 3,  6> velocity=<-1, -1>
  position=< 5,  0> velocity=< 1,  0>
  position=<-6,  0> velocity=< 2,  0>
  position=< 5,  9> velocity=< 1, -2>
  position=<14,  7> velocity=<-2,  0>
  position=<-3,  6> velocity=< 2, -1>
  Each line represents one point. Positions are given as <X, Y> pairs: X represents how far left (negative) or right (positive) the point appears, while Y represents how far up (negative) or down (positive) the point appears.

  At 0 seconds, each point has the position given. Each second, each point's velocity is added to its position. So, a point with velocity <1, -2> is moving to the right, but is moving upward twice as quickly. If this point's initial position were <3, 9>, after 3 seconds, its position would become <6, 3>.

  Over time, the points listed above would move like this:

  Initially:
  ........#.............
  ................#.....
  .........#.#..#.......
  ......................
  #..........#.#.......#
  ...............#......
  ....#.................
  ..#.#....#............
  .......#..............
  ......#...............
  ...#...#.#...#........
  ....#..#..#.........#.
  .......#..............
  ...........#..#.......
  #...........#.........
  ...#.......#..........

  After 1 second:
  ......................
  ......................
  ..........#....#......
  ........#.....#.......
  ..#.........#......#..
  ......................
  ......#...............
  ....##.........#......
  ......#.#.............
  .....##.##..#.........
  ........#.#...........
  ........#...#.....#...
  ..#...........#.......
  ....#.....#.#.........
  ......................
  ......................

  After 2 seconds:
  ......................
  ......................
  ......................
  ..............#.......
  ....#..#...####..#....
  ......................
  ........#....#........
  ......#.#.............
  .......#...#..........
  .......#..#..#.#......
  ....#....#.#..........
  .....#...#...##.#.....
  ........#.............
  ......................
  ......................
  ......................

  After 3 seconds:
  ......................
  ......................
  ......................
  ......................
  ......#...#..###......
  ......#...#...#.......
  ......#...#...#.......
  ......#####...#.......
  ......#...#...#.......
  ......#...#...#.......
  ......#...#...#.......
  ......#...#..###......
  ......................
  ......................
  ......................
  ......................

  After 4 seconds:
  ......................
  ......................
  ......................
  ............#.........
  ........##...#.#......
  ......#.....#..#......
  .....#..##.##.#.......
  .......##.#....#......
  ...........#....#.....
  ..............#.......
  ....#......#...#......
  .....#.....##.........
  ...............#......
  ...............#......
  ......................
  ......................
  After 3 seconds, the message appeared briefly: HI. Of course, your message will be much longer and will take many more seconds to appear.

  What message will eventually appear in the sky?

  Your puzzle answer was LKPHZHHJ.

  --- Part Two ---
  Good thing you didn't have to wait, because that would have taken a long time - much longer than the 3 seconds in the example above.

  Impressed by your sub-hour communication capabilities, the Elves are curious: exactly how many seconds would they have needed to wait for that message to appear?
  """

  @type points :: [{position :: point, velocity :: point}]
  @type point :: {integer, integer}

  @doc "Part 1"
  @spec render_solution(String.t()) :: String.t()
  def render_solution(input) do
    points = parse(input)
    count = steps_to_minimum_area(points)

    points
    |> step(count)
    |> print()
  end

  @doc "Part 2"
  @spec num_step_to_smallest(String.t()) :: integer
  def num_step_to_smallest(input) do
    input
    |> parse()
    |> steps_to_minimum_area()
  end

  @doc "Moves all points a second"
  @spec step(points) :: points
  def step(points, count \\ 1) do
    Enum.map(points, &step_point(&1, count))
  end

  @doc "Returns the bounding box area of all points"
  @spec bounding_area(points) :: integer
  def bounding_area(points) do
    {{min_x, min_y}, {max_x, max_y}} = bounding_box(points)
    (max_x - min_x) * (max_y - min_y)
  end

  @doc "Parses input into a list of points with velocity"
  @spec parse(String.t()) :: points
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp find_upper(points, current_area, next_step_num) do
    next_step = step(points, next_step_num)
    next_area = bounding_area(next_step)

    if next_area > current_area do
      next_step_num
    else
      find_upper(points, next_area, next_step_num * 2)
    end
  end

  defp steps_to_minimum_area(points) do
    current_area = bounding_area(points)
    upper_bound = find_upper(points, current_area, 1)
    steps_to_minimum_area(points, 0, upper_bound)
  end

  defp steps_to_minimum_area(_points, lower, upper) when lower + 2 == upper do
    lower + 1
  end

  defp steps_to_minimum_area(points, lower, upper) do
    middle = div(lower + upper, 2)
    next_step_1 = step(points, middle)
    next_area_1 = bounding_area(next_step_1)
    next_step_2 = step(points, middle + 1)
    next_area_2 = bounding_area(next_step_2)

    if next_area_1 < next_area_2 do
      steps_to_minimum_area(points, lower, middle + 1)
    else
      steps_to_minimum_area(points, middle, upper)
    end
  end

  defp print(points) do
    points_map = points |> Enum.into([], fn {{x, y}, _} -> {x, y} end) |> MapSet.new()
    {{min_x, min_y}, {max_x, max_y}} = bounding_box(points)

    for y <- min_y..max_y, x <- min_x..max_x do
      char = if MapSet.member?(points_map, {x, y}), do: "#", else: " "
      newline = if x == max_x, do: "\n", else: ""
      char <> newline
    end
    |> Enum.join("")
  end

  defp step_point({{px, py}, {vx, vy}}, n) do
    {{px + vx * n, py + vy * n}, {vx, vy}}
  end

  defp bounding_box(points) do
    {min_x, max_x} = points |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = points |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min_max()
    {{min_x, min_y}, {max_x, max_y}}
  end

  defp parse_line(line) do
    [px, py, vx, vy] =
      ~r/(-?[0-9]+).*?(-?[0-9]+).*?(-?[0-9]+).*?(-?[0-9]+)/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    {{px, py}, {vx, vy}}
  end
end
