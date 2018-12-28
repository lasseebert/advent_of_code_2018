defmodule Advent.Day23Test do
  use ExUnit.Case

  alias Advent.Day23

  @example_input_1 """
  pos=<0,0,0>, r=4
  pos=<1,0,0>, r=1
  pos=<4,0,0>, r=3
  pos=<0,2,0>, r=1
  pos=<0,5,0>, r=3
  pos=<0,0,3>, r=1
  pos=<1,1,1>, r=1
  pos=<1,1,2>, r=1
  pos=<1,3,1>, r=1
  """

  @example_input_2 """
  pos=<10,12,12>, r=2
  pos=<12,14,12>, r=2
  pos=<16,12,12>, r=4
  pos=<14,14,14>, r=6
  pos=<50,50,50>, r=200
  pos=<10,10,10>, r=5
  """

  describe "part 1" do
    test "example input" do
      assert Day23.part1(@example_input_1) == 7
    end

    test "puzzle input" do
      input = File.read!("inputs/day23_1.txt")
      assert Day23.part1(input) == 219
    end
  end

  describe "part 2" do
    test "example input" do
      assert Day23.part2(@example_input_2) == 36
    end

    test "puzzle input" do
      input = File.read!("inputs/day23_1.txt")
      assert Day23.part2(input) == 83_779_034
    end
  end
end
