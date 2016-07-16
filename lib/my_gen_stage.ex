defmodule MyGenStage do
  @test_file "data/sample.txt"

  def example1() do
    File.read!(@test_file)
    |> String.split("\n")
    |> Enum.flat_map(fn line ->
      String.split(line, " ")
    end)
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, word, 1, &(&1 + 1))
    end)
    |> Enum.to_list()
  end
end
