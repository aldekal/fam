#!/bin/bash

# FAM Development Environment Startup Script
# This script starts all development services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo
    echo -e "${BLUE}===================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================${NC}"
    echo
}

# Check if .env file exists
check_env() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        print_info "Run './scripts/setup.sh' first to set up the project"
        exit 1
    fi
}

# Check Docker daemon
check_docker() {
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        print_info "Please start Docker and run this script again"
        exit 1
    fi
}

# Start services
start_services() {
    print_header "Starting FAM Development Environment"
    
    print_info "Starting all services..."
    
    # Try docker compose first (newer), then docker-compose (legacy)
    if docker compose version &> /dev/null 2>&1; then
        print_info "Using 'docker compose' (Docker Compose V2)"
        docker compose up -d
    elif command -v docker-compose &> /dev/null && docker-compose --version &> /dev/null 2>&1; then
        print_info "Using 'docker-compose' (Docker Compose V1)"
        docker-compose up -d
    else
        print_error "Neither 'docker compose' nor 'docker-compose' is working properly"
        print_info "This might be due to missing Python distutils module"
        print_info "Try installing: sudo apt-get install python3-distutils"
        print_info "Or use Docker Desktop which includes Docker Compose V2"
        exit 1
    fi
    
    print_success "Services started successfully!"
}

# Show service status
show_status() {
    print_header "Service Status"
    
    if docker compose version &> /dev/null 2>&1; then
        docker compose ps
    elif command -v docker-compose &> /dev/null && docker-compose --version &> /dev/null 2>&1; then
        docker-compose ps
    else
        print_info "Using basic docker ps output:"
        docker ps --filter "name=postgres" --filter "name=pgadmin" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    fi
    
    echo
    print_info "Access URLs:"
    print_info "- PgAdmin: http://localhost:8080"
    print_info "- Database: localhost:5432"
    echo
    print_info "To view logs: docker logs -f [container_name]"
    print_info "To stop services: ./scripts/stop-dev.sh"
}

# Wait for services to be healthy
wait_for_services() {
    print_info "Waiting for services to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker compose version &> /dev/null 2>&1; then
            local healthy=$(docker compose ps --services --filter "status=running" 2>/dev/null | wc -l)
        elif command -v docker-compose &> /dev/null && docker-compose --version &> /dev/null 2>&1; then
            local healthy=$(docker-compose ps --services --filter "status=running" 2>/dev/null | wc -l)
        else
            local healthy=$(docker ps --filter "status=running" | grep -E "(postgres|pgadmin)" | wc -l)
        fi
        
        if [ "$healthy" -gt 0 ]; then
            print_success "Services are ready!"
            return 0
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_warning "Services may still be starting up. Check status manually."
}

# Main function
main() {
    # Get to the project root directory
    cd "$(dirname "$0")/.."
    
    check_env
    check_docker
    start_services
    wait_for_services
    show_status
}

# Handle script arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [options]"
    echo
    echo "Starts the FAM development environment"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --logs         Show logs after starting"
    echo
    exit 0
fi

# Run main function
main "$@"

# Show logs if requested
if [ "$1" = "--logs" ]; then
    echo
    print_info "Showing logs... (Press Ctrl+C to exit)"
    if docker compose version &> /dev/null 2>&1; then
        docker compose logs -f
    elif command -v docker-compose &> /dev/null && docker-compose --version &> /dev/null 2>&1; then
        docker-compose logs -f
    else
        print_info "Using docker logs for individual containers:"
        docker logs -f postgres &
        docker logs -f pgadmin &
        wait
    fi
fi