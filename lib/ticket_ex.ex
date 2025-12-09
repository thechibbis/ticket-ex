defmodule TicketEx do
  @moduledoc """
  Documentation for `TicketEx`.
  """
  require Logger

  alias TicketEx.Repo

  @doc """
  Hello world.

  ## Examples

      iex> TicketEx.hello()
      :world

  """
  def full_test do
    {time_us, _} = :timer.tc(fn -> TicketEx.Ticketd.Worker.create_tickets(5_000_000, 0) end)
    Logger.info("time need to create 5_000_000 tickets: #{time_us / 1000} ms")

    {time_us, _} =
      :timer.tc(fn ->
        TicketEx.Ticketd.Worker.retrieve_tickets(
          "raffle_1",
          "tenant_1",
          "customer_1",
          1_000_000
        )

        TicketEx.Ticketd.Worker.retrieve_tickets(
          "raffle_1",
          "tenant_1",
          "customer_1",
          1_000_000
        )

        TicketEx.Ticketd.Worker.retrieve_tickets(
          "raffle_1",
          "tenant_1",
          "customer_1",
          1_000_000
        )

        TicketEx.Ticketd.Worker.retrieve_tickets(
          "raffle_1",
          "tenant_1",
          "customer_1",
          1_000_000
        )

        TicketEx.Ticketd.Worker.retrieve_tickets(
          "raffle_1",
          "tenant_1",
          "customer_1",
          1_000_000
        )
      end)

    Logger.info("time need to retrieve 1_000_000 tickets 5 times: #{time_us / 1000} ms")
  end

  def benchmark_create_tickets do
    inputs = %{
      "100_000 tickets" => 100_000,
      "500_000 tickets" => 500_000,
      "1_000_000 tickets" => 1_000_000,
      "5_000_000 tickets" => 5_000_000,
      "10_000_000 tickets" => 10_000_000
    }

    Benchee.run(
      %{
        "create_tickets_stream" => fn amount ->
          TicketEx.Ticketd.Service.create_redis_tickets(amount, 0)
        end
      },
      inputs: inputs,
      memory_time: 2,
      before_scenario: fn _scenario ->
        TicketEx.Redix.command!(["DEL", "0"])
      end,
      after_scenario: fn _scenario ->
        TicketEx.Redix.command!(["DEL", "0"])
      end
    )
  end

  def benchmark_retrieve_tickets do
    Repo.query!("TRUNCATE tickets", [])

    inputs = %{
      "100_000 tickets" => 100_000,
      "500_000 tickets" => 500_000,
      "1_000_000 tickets" => 1_000_000,
      "5_000_000 tickets" => 5_000_000
    }

    Benchee.run(
      %{
        "retrieve_tickets" => fn amount ->
          TicketEx.Ticketd.Service.retrieve_tickets("0", "0", "0", amount)
        end
      },
      inputs: inputs,
      memory_time: 2
    )
  end
end
