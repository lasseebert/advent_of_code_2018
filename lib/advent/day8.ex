defmodule Advent.Day8 do
  @moduledoc """
  --- Day 8: Memory Maneuver ---
  The sleigh is much easier to pull than you'd expect for something its weight. Unfortunately, neither you nor the Elves know which way the North Pole is from here.

  You check your wrist device for anything that might help. It seems to have some kind of navigation system! Activating the navigation system produces more bad news: "Failed to start navigation system. Could not read software license file."

  The navigation system's license file consists of a list of numbers (your puzzle input). The numbers define a data structure which, when processed, produces some kind of tree that can be used to calculate the license number.

  The tree is made up of nodes; a single, outermost node forms the tree's root, and it contains all other nodes in the tree (or contains nodes that contain nodes, and so on).

  Specifically, a node consists of:

  A header, which is always exactly two numbers:
  The quantity of child nodes.
  The quantity of metadata entries.
  Zero or more child nodes (as specified in the header).
  One or more metadata entries (as specified in the header).
  Each child node is itself a node that has its own header, child nodes, and metadata. For example:

  2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
  A----------------------------------
    B----------- C-----------
                     D-----
  In this example, each node of the tree is also marked with an underline starting with a letter for easier identification. In it, there are four nodes:

  A, which has 2 child nodes (B, C) and 3 metadata entries (1, 1, 2).
  B, which has 0 child nodes and 3 metadata entries (10, 11, 12).
  C, which has 1 child node (D) and 1 metadata entry (2).
  D, which has 0 child nodes and 1 metadata entry (99).
  The first check done on the license file is to simply add up all of the metadata entries. In this example, that sum is 1+1+2+10+11+12+2+99=138.

  What is the sum of all metadata entries?
  """

  defmodule Tree do
    @moduledoc """
    A recursive tree structure
    """

    defstruct [:children, :meta]

    @doc "Builds a tree from the values"
    def build(values) do
      {node, []} = _build(values)
      node
    end

    @doc "Returns the sum of meta in the tree"
    def sum_meta(tree) do
      children_sum = tree.children |> Enum.map(&sum_meta/1) |> Enum.sum()
      own_sum = Enum.sum(tree.meta)
      children_sum + own_sum
    end

    def _build([num_children, num_meta | rest]) do
      {children, rest} = build_children(num_children, [], rest)
      {meta, rest} = Enum.split(rest, num_meta)

      node = %__MODULE__{children: children, meta: meta}
      {node, rest}
    end

    defp build_children(0, acc, rest), do: {acc, rest}

    defp build_children(n, acc, rest) do
      {child, rest} = _build(rest)
      build_children(n - 1, [child | acc], rest)
    end
  end

  @doc "Part 1"
  @spec sum_meta(String.t()) :: integer
  def sum_meta(input) do
    input
    |> parse()
    |> Tree.sum_meta()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Tree.build()
  end
end
