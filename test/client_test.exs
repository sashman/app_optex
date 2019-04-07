defmodule AppOptex.ClientTest do
  use ExUnit.Case
  alias AppOptex.Client
  import Mock

  test "send_measurements/4 makes a call with correct payload" do
    appoptics_url = "url"
    token = "token"
    measurements = [%{name: "name", value: 1}]
    tags = %{name: "value"}

    encoded_payload =
      Poison.encode!(%{
        tags: tags,
        measurements: measurements
      })

    with_mock HTTPoison,
      post: fn ^appoptics_url,
               ^encoded_payload,
               [{"Content-Type", "application/json"}],
               hackney: [basic_auth: {^token, ""}] ->
        {:ok, %HTTPoison.Response{}}
      end do
      result = Client.send_measurements(appoptics_url, token, measurements, tags)

      assert result == {:ok, %HTTPoison.Response{}}
    end
  end

  test "read_measurements/5 makes a call with correct payload" do
    appoptics_url = "url"
    token = "token"
    metric_name = "my.metric"
    resolution = 60

    params = %{
      start_time: 1_554_676_958,
      end_time: 1_554_676_999
    }

    response = %{body: Poison.encode!(%{response: "from AppOptics"})}

    with_mock HTTPoison,
      get!: fn "url/my.metric" <> _,
               [{"Content-Type", "application/json"}],
               hackney: [basic_auth: {^token, ""}] ->
        response
      end do
      result = Client.read_measurements(appoptics_url, token, metric_name, resolution, params)

      assert result == response.body |> Poison.decode!()
    end
  end
end
