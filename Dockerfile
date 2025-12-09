# Stage 1: Build the release
FROM elixir:1.19.4-otp-28-alpine AS builder

# Set the working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git openssh

# Copy application files
COPY mix.exs mix.lock ./
COPY config config/
COPY lib lib/
COPY priv priv/

# Install dependencies and compile
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile

# Create the release
RUN MIX_ENV=prod mix release

# Stage 2: Create the minimal runtime image
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs

# Create a non-root user for security
RUN addgroup -S app && adduser -S app -G app
USER app
WORKDIR /app

# Copy the release from the builder stage
COPY --from=builder /app/_build/prod/rel/ticket_ex ./

# Expose the application port (adjust if needed)
EXPOSE 50051

# Define the entry point for running the application
CMD ["bin/ticket_ex", "start"]