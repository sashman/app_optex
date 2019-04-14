defmodule AppOptex.Queue do
  def batch_queue(queue) do
    queue
    |> Enum.reduce({[], %{}}, fn {measurements, tags}, {acc_measurements, acc_tags} ->
      {acc_measurements ++ measurements, Map.merge(acc_tags, tags)}
    end)
  end
end
