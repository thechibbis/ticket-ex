defmodule TicketEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TicketEx.Redix,
      TicketEx.Ticketd.Supervisor,
      GrpcReflection,
      {
        GRPC.Server.Supervisor,
        [
          endpoint: TicketEx.Server.Endpoint,
          port: 50051,
          start_server: true
          # adapter_opts: [# any adapter-specific options like tls configuration....]
        ]
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicketEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
