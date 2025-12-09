defmodule TicketEx.Repo do
  use Ecto.Repo,
    otp_app: :ticket_ex,
    adapter: Ecto.Adapters.Postgres,
    log: false
end
