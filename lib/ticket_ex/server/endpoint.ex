defmodule TicketEx.Server.Endpoint do
  use GRPC.Endpoint

  run(TicketEx.Server.Reflection)
  run(TicketEx.Server.Grpc)
end
