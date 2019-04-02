defmodule AppOptex.AppOptexWorker do
  use GenServer

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
      )
      when is_list(measurements) and is_map(tags) do
    payload = %{
      tags: tags,
      measurements: measurements
    }

    HTTPoison.post(appoptics_url, Poison.encode!(payload), [{"Content-Type", "application/json"}],
      hackney: [basic_auth: {token, ""}]
    )

    {:noreply, state}
  end
end
