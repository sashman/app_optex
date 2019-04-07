defmodule AppOptex.Client do
  require Logger

  @doc """

  Send an HTTP request to [AppOptics create API](https://docs.appoptics.com/api/?shell#create-a-measurement) with a list of measurements and tags. Returns the response from AppOptics API.

  * appoptics_url - AppOptics API endpoint.
  * token - AppOptics auth token.
  * measurements - List of measurements to send. Each measurements is a map with a `name` and a `value` key.
  * tags - A map of tags to send for the current measurement.

  ## Examples

      iex> AppOptex.Client.send_measurements("https://api.appoptics.com/v1/measurements", "MY_TOKEN", [%{name: "my.mertric.name", value: 1}], %{"name" => "value"})
      {:ok, %HTTPoison.Response{}}

  """
  def send_measurements(appoptics_url, token, measurements, tags)
      when is_list(measurements) and is_map(tags) do
    payload = %{
      tags: tags,
      measurements: measurements
    }

    HTTPoison.post(appoptics_url, Poison.encode!(payload), [{"Content-Type", "application/json"}],
      hackney: [basic_auth: {token, ""}]
    )
  end

  @doc """

  Read from [AppOptics retrieve measurement API](https://docs.appoptics.com/api/?shell#retrieve-a-measurement) given a query. Returns the AppOptex API response.

  * appoptics_url - AppOptics API endpoint.
  * token - AppOptics auth token.
  * metric_name - Name of the metric to search.
  * resolution - Defines the resolution to return the data to in seconds.
  * query - map of query params. **Must** include either `duration` or `start_time`. Params include:
    * start_time - Unix Time of where to start the time search from. This parameter is optional if duration is specified.
    * end_time - Unix Time of where to end the search. This parameter is optional and defaults to current wall time.
    * duration - How far back to look in time, measured in seconds. This parameter can be used in combination with endtime to set a starttime N seconds back in time. It is an error to set starttime, endtime and duration.

  ## Examples

      iex> AppOptex.Client.read_measurements("https://api.appoptics.com/v1/measurements", "MY_TOKEN", "my.other_mertic", 60, %{duration: 999999})
      %{
            "attributes" => %{"created_by_ua" => "hackney/1.15.1"},
            "links" => [],
            "name" => "my.other_mertic",
            "resolution" => 60,
            "series" => [
                %{
                "measurements" => [%{"time" => 1554667320, "value" => 5.0}],
                "tags" => %{"my_tag" => "value"}
                }
            ]
        }

  """

  def read_measurements(appoptics_url, token, mertic_name, resolution, %{start_time: _} = params),
    do: _read_measurements(appoptics_url, token, mertic_name, resolution, params)

  def read_measurements(appoptics_url, token, mertic_name, resolution, %{duration: _} = params),
    do: _read_measurements(appoptics_url, token, mertic_name, resolution, params)

  def read_measurements(
        appoptics_url,
        token,
        mertic_name,
        resolution,
        %{duration: _, start_time: _} = params
      ),
      do: _read_measurements(appoptics_url, token, mertic_name, resolution, params)

  def read_measurements(_appoptics_url, _token, _mertic_name, _resolution, _),
    do: raise("Must provide either :duration or :start_time")

  def _read_measurements(appoptics_url, token, mertic_name, resolution, params)
      when is_map(params) do
    query =
      params
      |> Map.put(:resolution, resolution)
      |> Stream.map(fn {k, v} -> "#{k}=#{v}" end)
      |> Enum.join("&")

    HTTPoison.get!(
      "#{appoptics_url}/#{mertic_name}?#{query}",
      [{"Content-Type", "application/json"}],
      hackney: [basic_auth: {token, ""}]
    ).body
    |> Poison.decode!()
  end
end
