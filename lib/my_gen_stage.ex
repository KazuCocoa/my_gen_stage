defmodule MyGenStage do
  @test_file "data/sample.txt"

  def example1() do
    File.read!(@test_file)
    |> String.split("\n")
    |> Enum.flat_map(fn line -> # here build a huge list...
      String.split(line, " ")
    end)
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, word, 1, &(&1 + 1))
    end)
    |> Enum.to_list()
  end

  # lazy solution
  def example_stream() do
    File.stream!(@test_file)
    |> Stream.flat_map(fn line ->
      String.split(line, " ")
    end)
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, word, 1, & &1 + 1)
    end)
    |> Enum.to_list()
  end
end
