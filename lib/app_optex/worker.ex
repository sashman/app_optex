defmodule AppOptex.Worker do
  use GenServer
  require Logger
  alias AppOptex.Client

  @moduledoc """
    GenServer implementation used for asynchronous communication
  """

  def start_link(init_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  def init(args) do
    appoptics_url = Application.get_env(:app_optex, :appoptics_url)

    {:ok, %{token: args |> List.first(), appoptics_url: appoptics_url}}
  end

  def handle_cast(
        {:measurements, measurements, tags},
        %{
          token: token,
          appoptics_url: appoptics_url
        } = state
      ) do
    Client.send_measurements(appoptics_url, token, measurements, tags)
    |> log_response()

    {:noreply, state}
  end

  defp log_response({:ok, %HTTPoison.Response{body: body, status_code: 202}}),
    do: Logger.debug("AppOptex #{body}")

  defp log_response({_, %HTTPoison.Response{body: body, status_code: status_code}}),
    do: Logger.error("#{body} #{status_code}")

  defp log_response(_), do: Logger.error("Unable to send metrics")
end
