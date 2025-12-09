import Config

config :ticket_ex, TicketEx.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool_size: 20,
  queue_target: 2000,
  queue_interval: 5000
