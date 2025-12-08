ExUnit.start()

# Start the application to ensure all services are available during tests
{:ok, _} = Application.ensure_all_started(:ticket_ex)
