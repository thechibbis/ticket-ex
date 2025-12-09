defmodule TicketEx.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :tenant_id, :string
      add :raffle_id, :string
      add :customer_id, :string
      add :number, :integer

      timestamps()
    end
  end
end
