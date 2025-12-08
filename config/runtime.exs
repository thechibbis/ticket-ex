import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.

if config_env() == :prod do
  # Redis configuration for production
  config :ticket_ex, :redis,
    host: System.get_env("REDIS_HOST", "localhost"),
    port: String.to_integer(System.get_env("REDIS_PORT", "6379")),
    database: String.to_integer(System.get_env("REDIS_DATABASE", "0")),
    pool_size: String.to_integer(System.get_env("REDIS_POOL_SIZE", "15"))
end
