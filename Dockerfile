FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN dart pub get

# Copy the rest of the application
COPY . .

# Build the application
RUN dart compile exe bin/luckeverydaybot.dart -o bin/luckeverydaybot

# Create a smaller image for runtime
FROM ubuntu:22.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the compiled executable
COPY --from=build /app/bin/luckeverydaybot /app/bin/luckeverydaybot

# Create a directory for configurations
RUN mkdir -p /app/config

# Copy .env file to the project root if present at build time
COPY --from=build /app/.env* /app/

# Create a non-root user to run the application
RUN useradd -m bot && \
    chown -R bot:bot /app

# Set permissions for the .env file if it exists
RUN chmod 644 /app/.env 2>/dev/null || true

USER bot

# Expose the port for webhook
EXPOSE 8081

# LABEL for GitHub Container Registry
LABEL org.opencontainers.image.source=https://github.com/eiirn/luckeverydaybot

# Set the entry point
CMD ["/app/bin/luckeverydaybot"]