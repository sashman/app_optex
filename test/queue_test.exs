defmodule AppOptex.QueueTest do
  use ExUnit.Case
  alias AppOptex.Queue

  describe "batch_queue/1" do
    test "combines the queue measurements and tags" do
      queue = [
        {[%{name: "name1", value: 1}], %{tag: "name"}},
        {[%{name: "name2", value: 2}], %{another_tag: "name"}}
      ]

      {measurements, tags} = Queue.batch_queue(queue)
      assert [%{name: "name1", value: 1}, %{name: "name2", value: 2}] == measurements
      assert %{tag: "name", another_tag: "name"} = tags
    end

    test "merges tags in queue order" do
      queue = [
        {[%{name: "name1", value: 1}], %{tag: "name"}},
        {[%{name: "name2", value: 2}], %{tag: "new name"}}
      ]

      {_, tags} = Queue.batch_queue(queue)
      assert %{tag: "new name"} = tags
    end
  end
end
