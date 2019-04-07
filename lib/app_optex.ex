defmodule AppOptex do
  alias AppOptex.{Worker, Client}

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

  @doc """
  Send multiple measurements with tags. The measurements are sent to AppOptics asynchronously.

  * measurements - a batch of metrics to send as a list of maps.
  * tags - A map of tags to send with the measurement. Cannot be empty.

  ## Examples

      iex> AppOptex.measurements([%{name: "my.mertic", value: 1}, %{name: "my.other_mertic", value: 5}], %{my_tag: "value"})
      :ok

  """
  def measurements(measurements, tags) do
    GenServer.cast(Worker, {:measurements, measurements, tags})
  end

  def read_measurements(metric_name, resolution, params) do
    appoptics_url = Application.get_env(:app_optex, :appoptics_url)

    token =
      Application.get_env(:app_optex, :appoptics_token)
      |> case do
        {:system, env_var} -> System.get_env(env_var)
        token -> token
      end

    Client.read_measurements(appoptics_url, token, metric_name, resolution, params)
  end
end
