# AppOptex

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `app_optex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:app_optex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/app_optex](https://hexdocs.pm/app_optex).

## Usage

Uses the `APPOPTICS_TOKEN` environment variable.

```
AppOptex.measurement("my.test.metric", 42)
```
