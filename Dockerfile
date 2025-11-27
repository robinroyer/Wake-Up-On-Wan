# Build stage for frontend
FROM node:20-alpine AS frontend-build

WORKDIR /frontend

# Copy frontend package files
COPY Frontend/package*.json ./

# Install dependencies (including dev dependencies needed for build)
RUN npm ci

# Copy frontend source
COPY Frontend/ ./

# Build frontend
RUN npm run build

# Build stage for backend
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS backend-build

WORKDIR /backend

# Copy backend project files
COPY Backend/*.csproj ./

# Restore dependencies
RUN dotnet restore

# Copy backend source
COPY Backend/ ./

# Copy built frontend to wwwroot
COPY --from=frontend-build /frontend/dist ./wwwroot

# Build backend
RUN dotnet publish -c Release -o /app --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine

WORKDIR /app

# Install required packages for networking
RUN apk add --no-cache icu-libs

# Set environment variables
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV ASPNETCORE_ENVIRONMENT=Production

# Copy published app
COPY --from=backend-build /app ./

# Copy default appsettings (can be overridden with volume mount)
COPY Backend/appsettings.json ./

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Run the application
ENTRYPOINT ["dotnet", "WakeMeUp.dll"]
