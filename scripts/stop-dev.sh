#!/bin/bash

# FAM Development Environment Shutdown Script
# This script stops all development services

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

# Check Docker daemon
check_docker() {
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        exit 1
    fi
}

# Stop services
stop_services() {
    print_header "Stopping FAM Development Environment"
    
    print_info "Stopping all services..."
    
    # Try docker-compose first, then docker compose
    if command -v docker-compose &> /dev/null; then
        docker-compose down
    elif docker compose version &> /dev/null; then
        docker compose down
    else
        print_error "Neither docker-compose nor docker compose is available"
        exit 1
    fi
    
    print_success "Services stopped successfully!"
}

# Clean up containers and networks
cleanup() {
    print_info "Cleaning up containers and networks..."
    
    # Remove stopped containers
    if docker ps -a -q --filter "status=exited" | grep -q .; then
        docker rm $(docker ps -a -q --filter "status=exited") 2>/dev/null || true
        print_info "Removed stopped containers"
    fi
    
    # Remove unused networks
    docker network prune -f &>/dev/null || true
    print_info "Cleaned up unused networks"
}

# Remove volumes (optional)
remove_volumes() {
    print_warning "This will remove all data volumes. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if command -v docker-compose &> /dev/null; then
            docker-compose down -v
        else
            docker compose down -v
        fi
        print_warning "Data volumes removed"
    else
        print_info "Data volumes preserved"
    fi
}

# Show current status
show_status() {
    print_header "Current Status"
    
    local running_containers=$(docker ps --filter "name=fam" --filter "name=postgres" --filter "name=pgadmin" -q | wc -l)
    
    if [ "$running_containers" -eq 0 ]; then
        print_success "All FAM services are stopped"
    else
        print_warning "Some containers are still running:"
        docker ps --filter "name=fam" --filter "name=postgres" --filter "name=pgadmin"
    fi
}

# Main function
main() {
    # Get to the project root directory
    cd "$(dirname "$0")/.."
    
    check_docker
    stop_services
    
    # Handle cleanup options
    if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
        cleanup
    fi
    
    if [ "$1" = "--volumes" ] || [ "$1" = "-v" ]; then
        remove_volumes
    fi
    
    show_status
    
    echo
    print_info "To start services again: ./scripts/start-dev.sh"
}

# Handle script arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [options]"
    echo
    echo "Stops the FAM development environment"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --clean    Clean up stopped containers and networks"
    echo "  -v, --volumes  Remove data volumes (WARNING: This will delete all data!)"
    echo
    exit 0
fi

# Run main function
main "$@"