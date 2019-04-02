defmodule AppOptex do
  alias AppOptex.AppOptexWorker

  @moduledoc """
  Documentation for AppOptex.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AppOptex.hello()
      :world

  """
  def measurement(name, value) do
    GenServer.cast(AppOptexWorker, {:measurements, [%{name: name, value: value}], %{test: true}})
  end
end
