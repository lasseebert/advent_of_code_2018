defmodule Advent.Day9Test do
  use ExUnit.Case

  alias Advent.Day9
  alias Advent.Day9.Circle

  describe "Circle" do
    test "common operations" do
      # 3 0 2 1
      circle = Circle.new(3)
      circle = Circle.add_cw(circle, 1)
      circle = Circle.add_cw(circle, 2)
      circle = Circle.add_cw(circle, 0)
      circle = Circle.rotate_cw(circle)
      assert Circle.current(circle) == 0

      circle = Circle.rotate_cw(circle)
      assert Circle.current(circle) == 2

      circle = Circle.rotate_cw(circle)
      assert Circle.current(circle) == 1

      circle = Circle.rotate_cw(circle)
      assert Circle.current(circle) == 3

      circle = Circle.rotate_cw(circle)
      assert Circle.current(circle) == 0

      circle = Circle.remove_current(circle)
      assert Circle.current(circle) == 2

      circle = Circle.rotate_ccw(circle)
      assert Circle.current(circle) == 3

      circle = Circle.rotate_ccw(circle)
      assert Circle.current(circle) == 1
    end
  end

  describe "part 1" do
    test "example_input" do
      assert Day9.high_score(9, 25) == 32
      assert Day9.high_score(10, 1618) == 8_317
      assert Day9.high_score(13, 7999) == 146_373
      assert Day9.high_score(17, 1104) == 2_764
      assert Day9.high_score(21, 6111) == 54_718
      assert Day9.high_score(30, 5807) == 37_305
    end

    test "puzzle" do
      assert Day9.high_score(423, 71_944) == 418_237
    end
  end

  describe "part 2" do
    test "puzzle" do
      assert Day9.high_score(423, 7_194_400) == 3_505_711_612
    end
  end
end
