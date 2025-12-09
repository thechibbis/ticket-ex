defmodule TicketEx.Tickets do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tickets" do
    field :tenant_id, :string
    field :raffle_id, :string
    field :customer_id, :string
    field :number, :integer

    timestamps()
  end

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:tenant_id, :raffle_id, :customer_id, :number])
    |> validate_required([:tenant_id, :raffle_id, :customer_id, :number])
  end
end
