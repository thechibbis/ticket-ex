defmodule TicketEx.Ticketd.Worker do
  require Logger
  use GenServer

  alias TicketEx.Ticketd.Service,
    as: TicketdService

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{}, name: name, timeout: :infinity)
  end

  def start_child(name) do
    DynamicSupervisor.start_child(TicketEx.Ticketd.Supervisor, {__MODULE__, name})
  end

  def create_tickets(amount, initial_numeric) do
    worker_name = :"ticket_worker_#{:erlang.unique_integer()}"

    case start_child(worker_name) do
      {:ok, pid} ->
        try do
          GenServer.call(
            worker_name,
            {:create_tickets, amount, initial_numeric},
            :infinity
          )
        after
          DynamicSupervisor.terminate_child(TicketEx.Ticketd.Supervisor, pid)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def retrieve_tickets(raffle_id, tenant_id, customer_id, amount) do
    worker_name = :"ticket_worker_#{:erlang.unique_integer()}"

    case start_child(worker_name) do
      {:ok, pid} ->
        try do
          GenServer.call(
            worker_name,
            {:retrieve_tickets, raffle_id, tenant_id, customer_id, amount},
            :infinity
          )
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
  def handle_call({:create_tickets, amount, initial_numeric}, _from, state) do
    TicketdService.create_redis_tickets(amount, initial_numeric)

    {:reply, {:ok, [0, amount]}, state}
  end

  @impl true
  def handle_call({:retrieve_tickets, raffle_id, tenant_id, customer_id, amount}, _from, state) do
    result = TicketdService.retrieve_tickets(raffle_id, tenant_id, customer_id, amount)

    {:reply, result, state}
  end
end
