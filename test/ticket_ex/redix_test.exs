defmodule TicketEx.RedixTest do
  use ExUnit.Case, async: false

  setup do
    # Ensure Redis is available for tests
    on_exit(fn ->
      # Clean up any test data
      TicketEx.Redix.command(["FLUSHDB"])
    end)
  end

  test "can execute a simple command" do
    assert {:ok, "PONG"} = TicketEx.Redix.command(["PING"])
  end

  test "can set and get a value" do
    assert {:ok, "OK"} = TicketEx.Redix.command(["SET", "test_key", "test_value"])
    assert {:ok, "test_value"} = TicketEx.Redix.command(["GET", "test_key"])
  end

  test "can execute a pipeline of commands" do
    commands = [
      ["SET", "pipeline_key1", "value1"],
      ["SET", "pipeline_key2", "value2"],
      ["GET", "pipeline_key1"],
      ["GET", "pipeline_key2"]
    ]

    assert {:ok, ["OK", "OK", "value1", "value2"]} = TicketEx.Redix.pipeline(commands)
  end
end
