import Config

# Do not print debug messages in production
config :logger, level: :info

# Runtime configuration
import_config "#{config_env()}.secret.exs"
