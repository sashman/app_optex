defmodule AppOptex.Client do
  @doc """

  Send an HTTP request to AppOptics API with a list of measurements and tags. Returns the response from AppOptics API.

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
end
