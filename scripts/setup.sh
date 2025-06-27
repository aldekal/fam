#!/bin/bash

# FAM Project Setup Script
# This script sets up the development environment for the FAM application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if required tools are installed
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install the missing dependencies and run this script again."
        print_info "Installation guides:"
        print_info "  Docker: https://docs.docker.com/get-docker/"
        print_info "  Docker Compose: https://docs.docker.com/compose/install/"
        print_info "  Git: https://git-scm.com/downloads"
        exit 1
    fi
    
    print_success "All required dependencies are installed"
}

# Setup environment file
setup_environment() {
    print_header "Setting Up Environment"
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_success "Created .env file from .env.example"
            print_warning "Please review and update the values in .env file before proceeding"
            print_info "Important: Change default passwords in .env file!"
        else
            print_error ".env.example file not found!"
            exit 1
        fi
    else
        print_info ".env file already exists"
    fi
}

# Check Docker daemon
check_docker() {
    print_header "Checking Docker"
    
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        print_info "Please start Docker and run this script again"
        exit 1
    fi
    
    print_success "Docker is running"
}

# Pull and build Docker images
setup_docker() {
    print_header "Setting Up Docker Environment"
    
    print_info "Building Docker images..."
    if docker-compose build --no-cache; then
        print_success "Docker images built successfully"
    elif docker compose build --no-cache; then
        print_success "Docker images built successfully"
    else
        print_error "Failed to build Docker images"
        exit 1
    fi
    
    print_info "Pulling required Docker images..."
    if docker-compose pull; then
        print_success "Docker images pulled successfully"
    elif docker compose pull; then
        print_success "Docker images pulled successfully"
    else
        print_warning "Some images might not be available to pull (this is normal for local builds)"
    fi
}

# Setup database
setup_database() {
    print_header "Setting Up Database"
    
    print_info "Starting PostgreSQL database..."
    if docker-compose up -d postgres; then
        print_success "PostgreSQL container started"
    elif docker compose up -d postgres; then
        print_success "PostgreSQL container started"
    else
        print_error "Failed to start PostgreSQL"
        exit 1
    fi
    
    print_info "Waiting for database to be ready..."
    local retries=30
    while [ $retries -gt 0 ]; do
        if docker-compose exec -T postgres pg_isready -U fam_user -d fam_db &> /dev/null; then
            print_success "Database is ready"
            break
        elif docker compose exec -T postgres pg_isready -U fam_user -d fam_db &> /dev/null; then
            print_success "Database is ready"
            break
        fi
        
        retries=$((retries - 1))
        if [ $retries -eq 0 ]; then
            print_error "Database failed to start within expected time"
            exit 1
        fi
        
        echo -n "."
        sleep 2
    done
    echo
}

# Create project directories
setup_directories() {
    print_header "Setting Up Project Structure"
    
    local dirs=("api" "ui" "logs" "data")
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_info "Created directory: $dir"
        fi
    done
    
    print_success "Project structure is ready"
}

# Make scripts executable
setup_scripts() {
    print_header "Setting Up Scripts"
    
    local scripts=("scripts/setup.sh" "scripts/start-dev.sh" "scripts/stop-dev.sh" "db/scripts/reset-db.sh" "db/scripts/start-db.sh" "db/scripts/stop-db.sh")
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            print_info "Made executable: $script"
        fi
    done
    
    print_success "Scripts are ready"
}

# Main setup function
main() {
    print_header "FAM Project Setup"
    print_info "Starting setup process..."
    
    # Get to the project root directory
    cd "$(dirname "$0")/.."
    
    check_dependencies
    setup_environment
    check_docker
    setup_directories
    setup_scripts
    setup_docker
    setup_database
    
    print_header "Setup Complete!"
    print_success "FAM development environment is ready!"
    echo
    print_info "Next steps:"
    print_info "1. Review and update values in .env file"
    print_info "2. Run './scripts/start-dev.sh' to start all services"
    print_info "3. Access PgAdmin at http://localhost:8080"
    print_info "4. Start developing your API and UI components"
    echo
    print_warning "Don't forget to change default passwords in .env file!"
}

# Run main function
main "$@"