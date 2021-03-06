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

      iex> AppOptex.measurement("my.metric", 10, %{my_tag: "value"})
      :ok

  """
  def measurement(name, value, tags) do
    GenServer.cast(Worker, {:measurements, [%{name: name, value: value}], tags})
  end

  @moduledoc """
  Client library for sending and reading AppOptics API measurements. To auth AppOptics make sure to set the `APPOPTICS_TOKEN` environment variable. This can also be overridden in the Application config.
  """

  @doc """
  Send one measurement with tags. The measurements are sent to AppOptics asynchronously.

  * `measurement` - Map of the measurement data
  * `tags` - A map of tags to send with the measurement. Cannot be empty.

  ## Examples

      iex> AppOptex.measurement(%{name: "my.metric", value: 10}, %{my_tag: "value"})
      :ok

  """
  def measurement(measurement = %{name: _, value: _}, tags) when is_map(measurement) do
    GenServer.cast(Worker, {:measurements, [measurement], tags})
  end

  @doc """
  Send multiple measurements with tags. The measurements are sent to AppOptics asynchronously.

  * `measurements` - a batch of metrics to send as a list of maps.
  * `tags` - A map of tags to send with the measurement. Cannot be empty.

  ## Examples

      iex> AppOptex.measurements([%{name: "my.metric", value: 1}, %{name: "my.other_metric", value: 5}], %{my_tag: "value"})
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
      iex> AppOptex.client.read_measurements("my.other_metric", 60, %{duration: 999999})
      %{
        "attributes" => %{"created_by_ua" => "hackney/1.15.1"},
        "links" => [],
        "name" => "my.other_metric",
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

  @doc """
  Set the global tags that will be applied to all measurements. These can be overriden by tags provided in measurement/3 and measurements/2.

  * `tags` - maps of tags to set.

  ## Examples

      iex> AppOptex.put_global_tags(%{my_tag: "value"})
      :ok

  """
  def put_global_tags(tags) when is_map(tags),
    do: GenServer.cast(Worker, {:put_global_tags, tags})

  @doc """
  Get the global tags that will be applied to all measurements.

  ## Examples

      iex> AppOptex.get_global_tags()
      %{my_tag: "value"}

  """
  def get_global_tags(),
    do: GenServer.call(Worker, {:get_global_tags})

  @doc """
  Asynchronously add to queue of measurements to be sent to AppOptics later.

  ## Examples

      iex> AppOptex.push_to_queue([%{name: "my.metric", value: 1}], %{test: true})
      :ok

  """
  def push_to_queue(measurements, tags),
    do: GenServer.cast(Worker, {:push_to_queue, measurements, tags})

  @doc """
  Return the current contents of the measurements queue. The queue format is a list of tuples, each tuple contains a measurements list and a tags map.

  ## Examples

      iex> AppOptex.read_queue
      [{[%{name: "my.metric", value: 1}], %{test: true}}]

  """
  def read_queue(),
    do: GenServer.call(Worker, {:read_queue})

  @doc """
  Asynchronously send the contents of the queue to AppOptics and clear it.

  ## Examples

      iex> AppOptex.flush_queue()
      :ok

  """
  def flush_queue(),
    do: GenServer.cast(Worker, {:flush_queue})
end
