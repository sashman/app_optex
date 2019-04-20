# AppOptex

![CircleCI](https://img.shields.io/circleci/project/github/sashman/app_optex.svg)
![Hex.pm](https://img.shields.io/hexpm/v/app_optex.svg)

Client for [AppOptics API](https://docs.appoptics.com/api/)

## Installation

The package can be installed
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

### Send a single measurement

```elixir
  iex> AppOptex.measurement("my.mertic", 10, %{my_tag: "value"})
  :ok
  iex> AppOptex.measurement(%{name: "my.mertic", value: 10}, %{my_tag: "value"})
  :ok
```

### Send multiple measurements

```elixir
  iex> AppOptex.measurements([%{name: "my.mertic", value: 1}, %{name: "my.other_mertic", value: 5}], %{my_tag: "value"})
  :ok
```

### Read metrics

```elixir
  iex> AppOptex.read_measurements("my.mertic", 60, %{duration: 86400})
  %{
    "attributes" => %{"created_by_ua" => "hackney/1.15.1"},
    "links" => [],
    "name" => "my.mertic",
    "resolution" => 60,
    "series" => [
      %{
        "measurements" => [%{"time" => 1554720060, "value" => 10.0}],
        "tags" => %{"my_tag" => "value"}
      }
    ]
  }
```

### Set global tags

These tags will be applied to every sent measurement.

```elixir
  iex> AppOptex.put_global_tags(%{my: "tag"})
  :ok
```

### Read global tags

```elixir
  iex> AppOptex.get_global_tags()
  %{my: "tag"}
```

### Send using a queue

```elixir
  iex> AppOptex.push_to_queue([%{name: "my.metric.1", value: 1}], %{test: true})
  :ok
  iex> AppOptex.push_to_queue([%{name: "my.metric.2", value: 1}], %{test: true})
  :ok
  iex> AppOptex.push_to_queue([%{name: "my.metric.3", value: 1}], %{test: true})
  :ok
  iex> AppOptex.flush_queue()
  :ok
```
