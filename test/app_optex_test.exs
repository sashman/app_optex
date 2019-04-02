defmodule AppOptexTest do
  use ExUnit.Case
  doctest AppOptex

  test "greets the world" do
    assert AppOptex.hello() == :world
  end
end
