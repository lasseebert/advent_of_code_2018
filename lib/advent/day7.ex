defmodule Advent.Day7 do
  @moduledoc """
  --- Day 7: The Sum of Its Parts ---
  You find yourself standing on a snow-covered coastline; apparently, you landed a little off course. The region is too hilly to see the North Pole from here, but you do spot some Elves that seem to be trying to unpack something that washed ashore. It's quite cold out, so you decide to risk creating a paradox by asking them for directions.

  "Oh, are you the search party?" Somehow, you can understand whatever Elves from the year 1018 speak; you assume it's Ancient Nordic Elvish. Could the device on your wrist also be a translator? "Those clothes don't look very warm; take this." They hand you a heavy coat.

  "We do need to find our way back to the North Pole, but we have higher priorities at the moment. You see, believe it or not, this box contains something that will solve all of Santa's transportation problems - at least, that's what it looks like from the pictures in the instructions." It doesn't seem like they can read whatever language it's in, but you can: "Sleigh kit. Some assembly required."

  "'Sleigh'? What a wonderful name! You must help us assemble this 'sleigh' at once!" They start excitedly pulling more parts out of the box.

  The instructions specify a series of steps and requirements about which steps must be finished before others can begin (your puzzle input). Each step is designated by a single letter. For example, suppose you have the following instructions:

  Step C must be finished before step A can begin.
  Step C must be finished before step F can begin.
  Step A must be finished before step B can begin.
  Step A must be finished before step D can begin.
  Step B must be finished before step E can begin.
  Step D must be finished before step E can begin.
  Step F must be finished before step E can begin.
  Visually, these requirements look like this:


  -->A--->B--
  /    \      \
  C      -->D----->E
  \           /
  ---->F-----
  Your first goal is to determine the order in which the steps should be completed. If more than one step is ready, choose the step which is first alphabetically. In this example, the steps would be completed as follows:

  Only C is available, and so it is done first.
  Next, both A and F are available. A is first alphabetically, so it is done next.
  Then, even though F was available earlier, steps B and D are now also available, and B is the first alphabetically of the three.
  After that, only D and F are available. E is not available because only some of its prerequisites are complete. Therefore, D is completed next.
  F is the only choice, so it is done next.
  Finally, E is completed.
  So, in this example, the correct order is CABDFE.

  In what order should the steps in your instructions be completed?

  --- Part Two ---
  As you're about to begin construction, four of the Elves offer to help. "The sun will set soon; it'll go faster if we work together." Now, you need to account for multiple people working on steps simultaneously. If multiple steps are available, workers should still begin them in alphabetical order.

  Each step takes 60 seconds plus an amount corresponding to its letter: A=1, B=2, C=3, and so on. So, step A takes 60+1=61 seconds, while step Z takes 60+26=86 seconds. No time is required between steps.

  To simplify things for the example, however, suppose you only have help from one Elf (a total of two workers) and that each step takes 60 fewer seconds (so that step A takes 1 second and step Z takes 26 seconds). Then, using the same instructions as above, this is how each second would be spent:

  Second   Worker 1   Worker 2   Done
   0        C          .        
   1        C          .        
   2        C          .        
   3        A          F       C
   4        B          F       CA
   5        B          F       CA
   6        D          F       CAB
   7        D          F       CAB
   8        D          F       CAB
   9        D          .       CABF
  10        E          .       CABFD
  11        E          .       CABFD
  12        E          .       CABFD
  13        E          .       CABFD
  14        E          .       CABFD
  15        .          .       CABFDE
  Each row represents one second of time. The Second column identifies how many seconds have passed as of the beginning of that second. Each worker column shows the step that worker is currently doing (or . if they are idle). The Done column shows completed steps.

  Note that the order of the steps has changed; this is because steps now take time to finish and multiple workers can begin multiple steps simultaneously.

  In this example, it would take 15 seconds for two workers to complete these steps.

  With 5 workers and the 60+ second step durations described above, how long will it take to complete all of the steps?
  """

  defmodule Graph do
    defstruct [:ready, :blocks, :depends]

    def new(block_list) do
      # Map of %{node => [nodes]} meaning node blocks nodes
      blocks = Enum.reduce(block_list, %{}, fn {a, b}, map -> Map.update(map, a, [b], fn list -> [b | list] end) end)

      # Map of %{node => MapSet(nodes)} meaning node depends on nodes
      depends =
        block_list
        |> Enum.reduce(%{}, fn {a, b}, map ->
          Map.update(map, b, MapSet.new([a]), fn set -> MapSet.put(set, a) end)
        end)

      # List of nodes that does not depend on other nodes
      ready =
        block_list
        |> Enum.flat_map(fn {a, b} -> [a, b] end)
        |> Enum.uniq()
        |> Enum.reject(&Map.has_key?(depends, &1))

      %__MODULE__{ready: ready, blocks: blocks, depends: depends}
    end

    def step(%{ready: ready} = graph) do
      first = ready |> Enum.sort() |> hd
      graph = step(graph, first)
      {graph, first}
    end

    def step(%{ready: ready, depends: depends, blocks: blocks} = graph, node) do
      ready = List.delete(ready, node)

      {ready, depends} =
        blocks
        |> Map.get(node, %{})
        |> Enum.reduce({ready, depends}, fn dependent, {ready, depends} ->
          blockers = depends |> Map.fetch!(dependent) |> MapSet.delete(node)

          # Add to ready if no more blockers exist
          ready = if MapSet.size(blockers) == 0, do: [dependent | ready], else: ready

          # Update blockers
          depends = Map.put(depends, dependent, blockers)

          {ready, depends}
        end)

      %{graph | ready: ready, depends: depends}
    end
  end

  @doc "Part 1"
  @spec order(String.t()) :: String.t()
  def order(input) do
    input
    |> parse()
    |> run("")
  end

  defp run(%{ready: []}, acc) do
    acc
  end

  defp run(graph, acc) do
    {graph, node} = Graph.step(graph)
    acc = acc <> node
    run(graph, acc)
  end

  @doc "Part 2"
  @spec time(String.t(), integer, integer) :: integer
  def time(input, num_workers, added_time) do
    graph = parse(input)
    workers = []
    time = -1

    run_time(graph, workers, num_workers, added_time, time)
  end

  defp run_time(%{ready: []}, [], _, _, time) do
    time
  end

  defp run_time(graph, workers, num_workers, added_time, time) do
    workers = workers |> Enum.map(fn {node, time} -> {node, time - 1} end)
    {done_workers, workers} = Enum.split_with(workers, fn {_node, time} -> time == 0 end)
    graph = Enum.reduce(done_workers, graph, fn {node, _}, graph -> Graph.step(graph, node) end)

    workers = put_to_work(graph, workers, num_workers, added_time)
    run_time(graph, workers, num_workers, added_time, time + 1)
  end

  defp put_to_work(graph, workers, num_workers, added_time) do
    cond do
      length(workers) == num_workers ->
        workers

      length(graph.ready) == length(workers) ->
        workers

      true ->
        ongoing = workers |> Enum.map(&elem(&1, 0))
        node = graph.ready |> Enum.find(fn node -> node not in ongoing end)
        put_to_work(graph, [{node, work_time(node) + added_time} | workers], num_workers, added_time)
    end
  end

  defp work_time(node) do
    <<ascii>> = node
    ascii - ?A + 1
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Graph.new()
  end

  defp parse_line(line) do
    [a, b] = Regex.run(~r/ ([A-Z]) .* ([A-Z]) /, line, capture: :all_but_first)
    {a, b}
  end
end
