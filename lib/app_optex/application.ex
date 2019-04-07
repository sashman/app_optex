defmodule AppOptex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {AppOptex.Worker, read_token()}
      # Starts a worker by calling: AppOptex.Worker.start_link(arg)
      # {AppOptex.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AppOptex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp read_token do
    Application.get_env(:app_optex, :appoptics_token)
    |> case do
      {:system, env_var} -> System.get_env(env_var)
      token -> token
    end
  end
end
