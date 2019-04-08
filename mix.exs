defmodule AppOptex.MixProject do
  use Mix.Project

  def project do
    [
      app: :app_optex,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AppOptex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
