defmodule Advent.Day7Test do
  use ExUnit.Case

  alias Advent.Day7

  describe "part 1" do
    test "example input" do
      input = """
      Step C must be finished before step A can begin.
      Step C must be finished before step F can begin.
      Step A must be finished before step B can begin.
      Step A must be finished before step D can begin.
      Step B must be finished before step E can begin.
      Step D must be finished before step E can begin.
      Step F must be finished before step E can begin.
      """

      assert Day7.order(input) == "CABDFE"
    end

    test "puzzle input" do
      input = File.read!("inputs/day7_1.txt")
      assert Day7.order(input) == "JRHSBCKUTVWDQAIGYOPXMFNZEL"
    end
  end

  describe "part 2" do
    test "example input" do
      input = """
      Step C must be finished before step A can begin.
      Step C must be finished before step F can begin.
      Step A must be finished before step B can begin.
      Step A must be finished before step D can begin.
      Step B must be finished before step E can begin.
      Step D must be finished before step E can begin.
      Step F must be finished before step E can begin.
      """

      assert Day7.time(input, 2, 0) == 15
    end

    test "puzzle input" do
      input = File.read!("inputs/day7_1.txt")
      assert Day7.time(input, 5, 60) == 975
    end
  end
end
