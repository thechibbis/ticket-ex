defmodule TicketEx.Redix do
  @moduledoc """
  Redis connection pool using Redix.
  """

  use Supervisor
  @pool_size 15

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    # Get Redis configuration from application config
    redis_config = Application.get_env(:ticket_ex, :redis, [])
    redis_user = Keyword.get(redis_config, :user, "default")
    redis_pass = Keyword.get(redis_config, :pass, nil)
    redis_host = Keyword.get(redis_config, :host, "localhost")
    redis_port = Keyword.get(redis_config, :port, 6379)
    redis_database = Keyword.get(redis_config, :database, 0)
    pool_size = Keyword.get(redis_config, :pool_size, @pool_size)

    # Specs for the Redix connections.
    children =
      for index <- 0..(pool_size - 1) do
        Supervisor.child_spec(
          {Redix,
           name: :"redix_#{index}",
           username: redis_user,
           password: redis_pass,
           host: redis_host,
           port: redis_port,
           database: redis_database},
          id: {Redix, index}
        )
      end

    # Use a simple one_for_one strategy for the pool
    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Executes a command on a random Redis connection from the pool.
  """
  def command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  @doc """
  Executes a pipeline of commands on a random Redis connection from the pool.
  """
  def pipeline(commands) do
    Redix.pipeline(:"redix_#{random_index()}", commands)
  end

  # Returns a random index from the pool
  defp random_index do
    Enum.random(0..(@pool_size - 1))
  end
end
