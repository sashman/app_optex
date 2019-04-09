defmodule AppOptex do
  alias AppOptex.{Worker, Client}

  @moduledoc """
  Client library for sending and reading AppOptics API measurements. To auth AppOptics make sure to set the `APPOPTICS_TOKEN` environment variable. This can also be overridden in the Application config.
  """

  @doc """
  Send one measurement with tags. The measurements are sent to AppOptics asynchronously.

  * `name` - Name of the measurement
  * `value` - Value of the measurement
  * `tags` - A map of tags to send with the measurement. Cannot be empty.

  ## Examples

      iex> AppOptex.measurement("my.mertic", 10, %{my_tag: "value"})
      :ok

  """
  def measurement(name, value, tags) do
    GenServer.cast(Worker, {:measurements, [%{name: name, value: value}], tags})
  end

  @doc """
  Send multiple measurements with tags. The measurements are sent to AppOptics asynchronously.

  * `measurements` - a batch of metrics to send as a list of maps.
  * `tags` - A map of tags to send with the measurement. Cannot be empty.

  ## Examples

      iex> AppOptex.measurements([%{name: "my.mertic", value: 1}, %{name: "my.other_mertic", value: 5}], %{my_tag: "value"})
      :ok

  """
  def measurements(measurements, tags) do
    GenServer.cast(Worker, {:measurements, measurements, tags})
  end

  @doc """
  Recieve multiple measurements with tags. The measurements are read from AppOptics synchronously.

  - `metric name` - the name of the metric you want measurements on.
  - `resolution` - the resolution of the measurements in seconds.
  - `params` - A map of parameters to restrict the result to possible values include:
    - `start_time` - Unix Time of where to start the time search from. This parameter is optional if duration is specified.
    - `end_time` - Unix Time of where to end the search. This parameter is optional and defaults to current wall time.
    - `duration` - How far back to look in time, measured in seconds. This parameter can be used in combination with endtime to set a starttime N seconds back in time. It is an error to set starttime, endtime and duration.

  ## Examples
      iex> AppOptex.client.read_measurements("my.other_mertic", 60, %{duration: 999999})
      %{
        "attributes" => %{"created_by_ua" => "hackney/1.15.1"},
        "links" => [],
        "name" => "my.other_mertic",
        "resolution" => 60,
        "series" => [
          %{
            "measurements" => [%{"time" => 1554720060, "value" => 10.0}],
            "tags" => %{"my_tag" => "value"}
          }
        ]
      }
  """
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

  def put_global_tags(tags) when is_map(tags),
    do: GenServer.cast(Worker, {:put_global_tags, tags})

  def get_global_tags(),
    do: GenServer.call(Worker, {:get_global_tags})
end
