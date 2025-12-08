defmodule TicketEx.Server.Grpc do
  use GRPC.Server, service: Ticketd.TicketdServer.Service

  alias Ticketd.PingRequest
  alias Ticketd.PongResult
  alias Ticketd.RaffleCreationRequest
  alias Ticketd.RaffleCreationResponse
  alias Ticketd.RaffleTicketRetrievalRequest
  alias Ticketd.RaffleTicketRetrievalResponse

  def ping(%PingRequest{serial: serial}, _stream) do
    IO.inspect(serial, label: "Ping Request Received")
    timestamp = System.system_time(:millisecond)
    response = %PongResult{serial: serial, timestamp: timestamp}
    IO.inspect(response, label: "Pong Response Sent")
    response
  end

  def notify_raffle_creation(
        %RaffleCreationRequest{
          raffleId: raffle_id,
          ticketCount: ticket_count,
          initialNumeric: initial_numeric
        },
        _stream
      ) do
    IO.inspect(
      %{raffle_id: raffle_id, ticket_count: ticket_count, initial_numeric: initial_numeric},
      label: "Raffle Creation Request Received"
    )

    case TicketEx.Ticketd.Worker.create_tickets(raffle_id, ticket_count, initial_numeric) do
      {:ok, created_amount} ->
        IO.inspect("created #{created_amount} tickets for raffle: #{raffle_id}")
        response = %RaffleCreationResponse{amount: created_amount}
        IO.inspect(response, label: "Raffle Creation Response Sent")
        response

      {:error, reason} ->
        IO.inspect(reason, label: "Error creating tickets")
        %RaffleCreationResponse{amount: 0}
    end
  end

  def retrieve_tickets(
        %RaffleTicketRetrievalRequest{raffleId: raffle_id, amount: amount},
        _stream
      ) do
    IO.inspect(%{raffle_id: raffle_id, amount: amount},
      label: "Raffle Ticket Retrieval Request Received"
    )

    case TicketEx.Ticketd.Worker.retrieve_tickets(raffle_id, amount) do
      {:ok, ticket_amount} ->
        response = %RaffleTicketRetrievalResponse{ticketAmount: ticket_amount}
        IO.inspect(response, label: "Raffle Ticket Retrieval Response Sent")
        response

      {:error, reason} ->
        IO.inspect(reason, label: "Error retrieving tickets")
        %RaffleTicketRetrievalResponse{ticketAmount: 0}
    end
  end
end
