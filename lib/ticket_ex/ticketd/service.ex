defmodule TicketEx.Ticketd.Service do
  @moduledoc """
  Service module for TicketEx Ticketd operations.
  """

  require Logger

  def create_redis_tickets(amount, initial_numeric) do
    chunk_size = 2_500

    initial_numeric..(initial_numeric + amount - 1)
    |> Stream.chunk_every(chunk_size)
    |> Stream.map(fn chunk ->
      tickets = Enum.map(chunk, &Integer.to_string/1)

      ["SADD", "0" | tickets]
    end)
    |> Stream.chunk_every(20)
    |> Task.async_stream(
      &TicketEx.Redix.pipeline!(&1),
      ordered: false,
      max_concurrency: 6,
      timeout: :infinity
    )
    |> Stream.run()

    Logger.info("Created #{amount} tickets starting from #{initial_numeric}")
  end

  def retrieve_tickets(raffle_id, tenant_id, customer_id, amount) do
    retrieve_redis_tickets(amount)
    |> case do
      {:ok, tickets} ->
        insert_tickets_to_db(tickets, raffle_id, tenant_id, customer_id)
        {:ok, tickets}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def retrieve_redis_tickets(amount) do
    IO.inspect(amount)
    command = ["SPOP", "0", Integer.to_string(amount)]

    TicketEx.Redix.command(command)
  end

  @spec insert_tickets_to_db([String.t()], String.t(), String.t(), String.t()) ::
          :ok | {:error, any()}
  def insert_tickets_to_db(tickets, raffle_id, tenant_id, customer_id) do
    batch_size = 10_000

    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    tickets
    |> Stream.chunk_every(batch_size)
    |> Stream.map(fn chunk ->
      entries =
        Enum.map(chunk, fn ticket_number ->
          %{
            tenant_id: tenant_id,
            raffle_id: raffle_id,
            customer_id: customer_id,
            number: String.to_integer(ticket_number),
            inserted_at: now,
            updated_at: now
          }
        end)

      entries
    end)
    |> Task.async_stream(
      fn entries ->
        TicketEx.Repo.insert_all(TicketEx.Tickets, entries)
      end,
      max_concurrency: 6,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.run()

    :ok
  end
end
