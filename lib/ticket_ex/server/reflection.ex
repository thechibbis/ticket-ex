defmodule TicketEx.Server.Reflection do
  use GrpcReflection.Server,
    version: :v1,
    services: [Ticketd.TicketdServer.Service]
end
