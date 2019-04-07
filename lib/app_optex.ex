defmodule AppOptex do
  alias AppOptex.Worker

  @moduledoc """
  Client library for sending and reading AppOptics API measurements. To auth AppOptics make sure to set the `APPOPTICS_TOKEN` environment variable. This can also be overridden in the Application config. 
  """

  @doc """
  Send one measurement with tags. The measurements are sent to AppOptics asynchronously.

  * name - Name of the measurement
  * value - Value of the measurement
  * tags - A map of tags to send with the measurement. Cannot be empty.

  ## Examples

      iex> AppOptex.measurement("my.mertic", 10, %{my_tag: "value"})
      :ok

  """
  def measurement(name, value, tags) do
    GenServer.cast(Worker, {:measurements, [%{name: name, value: value}], tags})
  end
end
