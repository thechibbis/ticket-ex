import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.

if config_env() == :prod do
  # Redis configuration for production
  config :ticket_ex, :redis,
    user: System.get_env("REDIS_USER", "default"),
    pass: System.get_env("REDIS_PASS", "123123"),
    host: System.get_env("REDIS_HOST", "localhost"),
    port: System.get_env("REDIS_PORT", "6379"),
    database: System.get_env("REDIS_DATABASE", "0"),
    pool_size: System.get_env("REDIS_POOL_SIZE", "15")

  config :ticket_ex, TicketEx.Repo,
    username: System.get_env("DB_USERNAME", "postgres"),
    password: System.get_env("DB_PASSWORD", "postgres"),
    database: System.get_env("DB_NAME", "ticket_ex_prod"),
    hostname: System.get_env("DB_HOSTNAME", "localhost"),
    port: System.get_env("DB_PORT", "5432"),
    pool_size: System.get_env("DB_POOL_SIZE", "15")
end
