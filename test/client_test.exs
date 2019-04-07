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
end
