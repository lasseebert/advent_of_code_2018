defmodule Advent.Day4Test do
  use ExUnit.Case

  alias Advent.Day4

  def example_input do
    """
    [1518-11-01 00:00] Guard #10 begins shift
    [1518-11-01 00:05] falls asleep
    [1518-11-01 00:25] wakes up
    [1518-11-01 00:30] falls asleep
    [1518-11-01 00:55] wakes up
    [1518-11-01 23:58] Guard #99 begins shift
    [1518-11-02 00:40] falls asleep
    [1518-11-02 00:50] wakes up
    [1518-11-03 00:05] Guard #10 begins shift
    [1518-11-03 00:24] falls asleep
    [1518-11-03 00:29] wakes up
    [1518-11-04 00:02] Guard #99 begins shift
    [1518-11-04 00:36] falls asleep
    [1518-11-04 00:46] wakes up
    [1518-11-05 00:03] Guard #99 begins shift
    [1518-11-05 00:45] falls asleep
    [1518-11-05 00:55] wakes up
    """
  end

  describe "part 1" do
    test "example input" do
      assert Day4.strategy_1(example_input()) == 240
    end

    test "puzzle input" do
      assert "inputs/day4_1.txt" |> File.read!() |> Day4.strategy_1() == 12169
    end
  end

  describe "part 2" do
    test "example input" do
      assert Day4.strategy_2(example_input()) == 4455
    end

    test "puzzle input" do
      assert "inputs/day4_1.txt" |> File.read!() |> Day4.strategy_2() == 16164
    end
  end
end
