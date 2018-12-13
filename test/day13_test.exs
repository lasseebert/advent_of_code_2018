defmodule Advent.Day13Test do
  use ExUnit.Case

  alias Advent.Day13

  describe "part 1" do
    test "example input" do
      input =
        ~S(
/->-\        
|   |  /----\
| /-+--+-\  |
| | |  | v  |
\-+-/  \-+--/
\------/     )

      assert Day13.crash_location(input) == {7, 3}
    end

    test "puzzle input" do
      input = File.read!("inputs/day13_1.txt")
      assert Day13.crash_location(input) == {65, 73}
    end
  end

  describe "part 2" do
    test "example input" do
      input =
        ~S(
/>-<\  
|   |  
| /<+-\
| | | v
\>+</ |
  |   ^
  \<->/)

      assert Day13.last_cart_location(input) == {6, 4}
    end

    test "puzzle input" do
      input = File.read!("inputs/day13_1.txt")
      assert Day13.last_cart_location(input) == {54, 66}
    end
  end
end
