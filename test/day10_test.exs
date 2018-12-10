defmodule Advent.Day10Test do
  use ExUnit.Case

  alias Advent.Day10

  @example_input """
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
  """

  describe "part 1" do
    test "parsing" do
      input = """
      position=<14,  7> velocity=<-2,  0>
      position=<-3,  6> velocity=< 2, -1>
      """

      assert Day10.parse(input) == [
               {{14, 7}, {-2, 0}},
               {{-3, 6}, {2, -1}}
             ]
    end

    test "step" do
      data = [
        {{14, 7}, {-2, 0}},
        {{-3, 6}, {2, -1}}
      ]

      assert Day10.step(data) == [
               {{12, 7}, {-2, 0}},
               {{-1, 5}, {2, -1}}
             ]
    end

    test "bounding_area" do
      data = [
        {{14, 7}, {-2, 0}},
        {{-3, 6}, {2, -1}},
        {{0, 0}, {0, 0}}
      ]

      assert Day10.bounding_area(data) == 119
    end

    test "example input" do
      expected = """
      #   #  ###
      #   #   # 
      #   #   # 
      #####   # 
      #   #   # 
      #   #   # 
      #   #   # 
      #   #  ###
      """

      assert @example_input |> Day10.render_solution() == expected
    end

    test "puzzle input" do
      input = File.read!("inputs/day10_1.txt")

      expected = """
      #       #    #  #####   #    #  ######  #    #  #    #     ###
      #       #   #   #    #  #    #       #  #    #  #    #      # 
      #       #  #    #    #  #    #       #  #    #  #    #      # 
      #       # #     #    #  #    #      #   #    #  #    #      # 
      #       ##      #####   ######     #    ######  ######      # 
      #       ##      #       #    #    #     #    #  #    #      # 
      #       # #     #       #    #   #      #    #  #    #      # 
      #       #  #    #       #    #  #       #    #  #    #  #   # 
      #       #   #   #       #    #  #       #    #  #    #  #   # 
      ######  #    #  #       #    #  ######  #    #  #    #   ###  
      """

      assert input |> Day10.render_solution() == expected
    end
  end

  describe "part 2" do
    test "example input" do
      assert Day10.num_step_to_smallest(@example_input) == 3
    end

    test "puzzle input" do
      input = File.read!("inputs/day10_1.txt")
      assert Day10.num_step_to_smallest(input) == 10_159
    end
  end
end
