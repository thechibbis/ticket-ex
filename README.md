# TicketEx

**TODO: Add description**

## Infa

- Create Ticket -> new ticketd supervisor + genserver (worker)

- ecto for postgres communication
- [grpc-elixir](https://github.com/elixir-grpc/grpc) for grpc communication

## How to run

```bash
mix deps.get
```

```
iex -S mix
```

it will start listening to `localhost:50051`
obs: reflections enabled

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ticket_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ticket_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ticket_ex>.

