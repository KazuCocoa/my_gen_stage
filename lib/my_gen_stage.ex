defmodule MyGenStage do
  @test_file "data/sample.txt"

  alias Experimental.Flow

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

  # example to make more effective
  # def example_stream_async() do
  #   File.stream!(@test_file)
  #   |> Stream.flat_map(fn line ->
  #     String.split(line, " ")
  #   end)
  #   |> Stream.async() # new
  #   |> Enum.reduce(%{}, fn word, acc ->
  #     Map.update(acc, word, 1, & &1 + 1)
  #   end)
  #   |> Enum.to_list()
  # end

  # alias Experimental.Flow, as: Flow
  def example_with_genstage_as_prototype() do
    File.stream!(@test_file)
    |> Flow.from_enumerable()
    |> Flow.flat_map(&String.split(&1, " "))
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      Map.update(acc, word, 1, & &1 + &2)
    end)
    |> Enum.to_list()
  end
end
