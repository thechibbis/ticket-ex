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

  @spec notify_raffle_creation(
          RaffleCreationRequest.t(),
          GRPC.Server.Stream.t()
        ) :: any()
  def notify_raffle_creation(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(fn %RaffleCreationRequest{} = req ->
      case TicketEx.Ticketd.Worker.create_tickets(
             req.raffleId,
             req.ticketCount,
             req.initialNumeric
           ) do
        {:ok, created_amount_list} ->
          created_amount = created_amount_list |> Enum.sum()
          %RaffleCreationResponse{amount: created_amount}

        {:error, reason} ->
          IO.inspect(reason, label: "Error creating tickets")
          %RaffleCreationResponse{amount: 0}
      end
    end)
    |> GRPC.Stream.run()
  end

  @spec retrieve_tickets(
          RaffleTicketRetrievalRequest.t(),
          GRPC.Server.Stream.t()
        ) :: any()
  def retrieve_tickets(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(fn %RaffleTicketRetrievalRequest{} = req ->
      case TicketEx.Ticketd.Worker.retrieve_tickets(req.raffleId, req.amount) do
        {:ok, tickets} ->
          ticket_amount = length(tickets)
          %RaffleTicketRetrievalResponse{ticketAmount: ticket_amount}

        {:error, reason} ->
          IO.inspect(reason, label: "Error retrieving tickets")
          %RaffleTicketRetrievalResponse{ticketAmount: 0}
      end
    end)
    |> GRPC.Stream.run()
  end
end
