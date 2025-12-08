defmodule TicketEx.Ticketd.WorkerTest do
  use ExUnit.Case, async: false

  alias TicketEx.Ticketd.Worker

  describe "create_tickets/1" do
    test "handles large number of tickets" do
      amount = 1_000_000

      result = Worker.create_tickets(amount)

      assert {:ok} = result
    end
  end

  describe "retrieve_tickets/2" do
    test "retrieves specified number of tickets from chunk" do
      chunk_name = "chunk_10"
      amount = 800_000

      result = Worker.retrieve_tickets(chunk_name, amount)

      assert {:ok, tickets} = result
      assert length(tickets) == amount
    end
  end
end
