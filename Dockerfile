# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/aspnet:3.1.21-buster-slim AS base

# --- Solve the problem that Culture is not supported ---
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT false

# install required dependencies: libgdiplus, tzdata, ffmpeg
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgdiplus \
        tzdata \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Static environment variables for the New Relic agent
ENV CORECLR_ENABLE_PROFILING=1 \
    CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A} \
    CORECLR_NEWRELIC_HOME=/app/newrelic \
    CORECLR_PROFILER_PATH=/app/newrelic/libNewRelicProfiler.so \
    NEW_RELIC_DISTRIBUTED_TRACING_ENABLED=true

WORKDIR /app
EXPOSE 80
EXPOSE 443

# --- BUILD IMAGE ---
FROM mcr.microsoft.com/dotnet/sdk:3.1.415-buster AS build

# copy everything
COPY . /src
WORKDIR /src

# restore all project dependencies
RUN dotnet restore

# build and publish
WORKDIR /src/Sample.WebApi
RUN dotnet publish --no-restore -c release -o /app

# --- RUNTIME IMAGE ---
FROM base AS final
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT [ "dotnet", "Sample.WebApi.dll" ]

