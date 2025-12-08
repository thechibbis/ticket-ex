defmodule TicketEx.Ticketd.Worker do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{}, name: name, timeout: :infinity)
  end

  def start_child(name) do
    DynamicSupervisor.start_child(TicketEx.Ticketd.Supervisor, {__MODULE__, name})
  end

  def create_tickets(chunk_name, amount, initial_numeric) do
    worker_name = :"ticket_worker_#{:erlang.unique_integer()}"

    case start_child(worker_name) do
      {:ok, pid} ->
        try do
          GenServer.call(
            worker_name,
            {:create_tickets, chunk_name, amount, initial_numeric},
            :infinity
          )
        after
          DynamicSupervisor.terminate_child(TicketEx.Ticketd.Supervisor, pid)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def retrieve_tickets(chunk_name, amount) do
    worker_name = :"ticket_worker_#{:erlang.unique_integer()}"

    case start_child(worker_name) do
      {:ok, pid} ->
        try do
          GenServer.call(worker_name, {:retrieve_tickets, chunk_name, amount})
        after
          DynamicSupervisor.terminate_child(TicketEx.Ticketd.Supervisor, pid)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  # callbacks
  def child_spec(name) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name]},
      restart: :temporary,
      timeout: :infinity,
      type: :worker
    }
  end

  @impl true
  def init(_state) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:create_tickets, chunk_name, amount, initial_numeric}, _from, state) do
    # chunk_size = Bitwise.bsl(1, 15)
    chunk_size = 10000

    {time_us, commands} =
      :timer.tc(fn ->
        initial_numeric..(initial_numeric + amount - 1)
        |> Enum.chunk_every(chunk_size)
        |> Enum.map(fn chunk ->
          tickets =
            Enum.map(chunk, &Integer.to_string/1)

          ["SADD", chunk_name | tickets]
        end)
      end)

    IO.inspect(time_us / 1000,
      label: "Time needed to mount the commands (SADD chunk = #{chunk_size})"
    )

    {time_us, _} = :timer.tc(fn -> TicketEx.Redix.chunked_pipeline(commands) end)

    IO.inspect(time_us / 1000,
      label: "Time needed to execute the commands (pipeline chunk = 1_000_000)"
    )

    {:reply, {:ok, [0, amount]}, state}
  end

  @impl true
  def handle_call({:retrieve_tickets, chunk_name, amount}, _from, state) do
    IO.puts("Retrieving #{amount} tickets in chunk #{chunk_name}")

    command = ["SPOP", chunk_name, Integer.to_string(amount)]

    case TicketEx.Redix.command(command) do
      {:ok, tickets} ->
        IO.puts("Successfully retrieved #{length(tickets)} tickets from Redis")
        {:reply, {:ok, tickets}, state}

      {:error, reason} ->
        IO.puts("Error retrieving tickets from Redis: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end
end
