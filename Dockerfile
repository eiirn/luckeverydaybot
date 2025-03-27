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

# Create a non-root user to run the application
RUN useradd -m bot
USER bot

# Expose the port for webhook
EXPOSE 8081

# Set the entry point
CMD ["/app/bin/luckeverydaybot"]