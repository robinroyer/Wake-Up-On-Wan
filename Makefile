.PHONY: help build clean publish dev dev-backend dev-frontend install restore stop-dev package

# Default target
help:
	@echo "Wake Me Up - Makefile Commands"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  make install      - Install all dependencies (backend restore + frontend npm install)"
	@echo "  make build        - Build frontend, copy to backend wwwroot, and build backend"
	@echo "  make clean        - Stop dev servers and clean build artifacts"
	@echo "  make stop-dev     - Stop all running development servers"
	@echo "  make publish      - Create production build (self-contained backend with integrated frontend)"
	@echo "  make package      - Build Docker image for deployment"
	@echo "  make dev          - Build frontend and run integrated app on http://localhost:5243"
	@echo "  make dev-backend  - Run only backend with hot reload"
	@echo "  make dev-frontend - Run only frontend with hot reload (for frontend development)"
	@echo ""

# Install dependencies
install: restore
	@echo "Installing frontend dependencies..."
	cd Frontend && npm install
	@echo "✓ All dependencies installed"

# Restore backend packages
restore:
	@echo "Restoring backend packages..."
	cd Backend && dotnet restore
	@echo "✓ Backend packages restored"

# Build both projects
build:
	@echo "Building frontend..."
	cd Frontend && npm run build
	@echo "✓ Frontend built successfully"
	@echo ""
	@echo "Copying frontend to backend wwwroot..."
	mkdir -p Backend/wwwroot
	cp -r Frontend/dist/* Backend/wwwroot/
	@echo "✓ Frontend copied to Backend/wwwroot/"
	@echo ""
	@echo "Building backend..."
	cd Backend && dotnet build --configuration Release
	@echo "✓ Backend built successfully"
	@echo ""
	@echo "✓ Build complete! Run 'make dev' or 'cd Backend && dotnet run'"

# Clean build artifacts and stop dev servers
clean: stop-dev
	@echo "Cleaning backend..."
	cd Backend && dotnet clean
	rm -rf Backend/bin Backend/obj Backend/wwwroot
	@echo "✓ Backend cleaned"
	@echo ""
	@echo "Cleaning frontend..."
	rm -rf Frontend/dist Frontend/node_modules/.vite
	@echo "✓ Frontend cleaned"
	@echo ""
	@echo "✓ Clean complete!"

# Stop all development servers
stop-dev:
	@echo "Stopping development servers..."
	@# Use killall which is safer than pkill
	@-killall -q WakeMeUp 2>/dev/null || true
	@# Kill node processes by name
	@-killall -q -r "node.*vite" 2>/dev/null || true
	@# Alternative: kill by terminal (if started in same terminal)
	@-ps aux | grep -E "dotnet.*watch.*run|WakeMeUp|vite.*dev" | grep -v grep | awk '{print $$2}' | xargs -r kill -TERM 2>/dev/null || true
	@sleep 1
	@-ps aux | grep -E "dotnet.*watch.*run|WakeMeUp|vite.*dev" | grep -v grep | awk '{print $$2}' | xargs -r kill -KILL 2>/dev/null || true
	@echo "✓ Development servers stopped"
	@echo ""

# Publish self-contained application
publish:
	@echo "Creating production build..."
	@echo ""
	@echo "Building frontend for production..."
	cd Frontend && npm run build
	@echo "✓ Frontend built"
	@echo ""
	@echo "Copying frontend to backend wwwroot..."
	mkdir -p Backend/wwwroot
	cp -r Frontend/dist/* Backend/wwwroot/
	@echo "✓ Frontend copied to Backend/wwwroot/"
	@echo ""
	@echo "Publishing backend as self-contained application (includes frontend)..."
	cd Backend && dotnet publish \
		--configuration Release \
		--output ../publish \
		--self-contained true \
		--runtime linux-x64 \
		/p:PublishSingleFile=true \
		/p:IncludeNativeLibrariesForSelfExtract=true
	@echo "✓ Backend published with integrated frontend"
	@echo ""
	@echo "Copying configuration..."
	cp Backend/appsettings.json publish/
	@echo "✓ Configuration copied"
	@echo ""
	@echo "════════════════════════════════════════════════════"
	@echo "✓ Production build complete!"
	@echo "════════════════════════════════════════════════════"
	@echo ""
	@echo "Published to: ./publish/"
	@echo ""
	@echo "To run the application:"
	@echo "  cd publish && ./WakeMeUp"
	@echo ""
	@echo "The application will serve both frontend and API on the configured port."
	@echo ""

# Build frontend and run integrated application
dev:
	@echo "Building frontend..."
	cd Frontend && npm run build
	@echo "✓ Frontend built"
	@echo ""
	@echo "Copying frontend to backend wwwroot..."
	mkdir -p Backend/wwwroot
	cp -r Frontend/dist/* Backend/wwwroot/
	@echo "✓ Frontend copied to Backend/wwwroot/"
	@echo ""
	@echo "Starting integrated application..."
	@echo "Application will run on: http://localhost:5243"
	@echo "  - Frontend: http://localhost:5243/"
	@echo "  - API: http://localhost:5243/api/servers"
	@echo ""
	@echo "Press Ctrl+C to stop"
	@echo ""
	cd Backend && dotnet run

# Run only backend with hot reload
dev-backend:
	@echo "Starting backend with hot reload..."
	cd Backend && dotnet watch run

# Run only frontend with hot reload
dev-frontend:
	@echo "Starting frontend with hot reload..."
	cd Frontend && npm run dev

# Package application as Docker image
package:
	@echo "Building Docker image..."
	@echo ""
	docker build -t wakemeup:latest .
	@echo ""
	@echo "════════════════════════════════════════════════════"
	@echo "✓ Docker image built successfully!"
	@echo "════════════════════════════════════════════════════"
	@echo ""
	@echo "Image: wakemeup:latest"
	@echo ""
	@echo "To run locally (bridge network - recommended):"
	@echo "  docker run -d -p 8080:8080 --cap-add=NET_RAW --cap-add=NET_ADMIN \\"
	@echo "    -v \$$(pwd)/appsettings.Production.json:/app/appsettings.Production.json:ro \\"
	@echo "    wakemeup:latest"
	@echo ""
	@echo "To run locally (host network - alternative):"
	@echo "  docker run -d --network host \\"
	@echo "    -v \$$(pwd)/appsettings.Production.json:/app/appsettings.Production.json:ro \\"
	@echo "    wakemeup:latest"
	@echo ""
	@echo "To tag and push to registry:"
	@echo "  docker tag wakemeup:latest your-registry/wakemeup:latest"
	@echo "  docker push your-registry/wakemeup:latest"
	@echo ""
