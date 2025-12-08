import Config

# Redis configuration for testing
config :ticket_ex, :redis,
  user: "default",
  pass: "123123",
  host: "localhost",
  port: 6379,
  database: 0,
  pool_size: 15
