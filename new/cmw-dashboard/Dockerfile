# Use Red Hat UBI for the base runtime image
FROM registry.access.redhat.com/ubi8/dotnet-60-runtime AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Use Red Hat UBI for the build SDK image
FROM registry.access.redhat.com/ubi8/dotnet-60 AS build
USER root
WORKDIR /src
COPY ["cmw-dashboard.csproj", "."]
RUN dotnet restore "./cmw-dashboard.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./cmw-dashboard.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "./cmw-dashboard.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Use the base runtime image to create the final image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "cmw-dashboard.dll"]
