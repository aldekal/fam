#!/bin/bash

# FAM Database Reset Script
# This script resets the database by stopping, removing, and recreating it

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

# Get to the project root directory
cd "$(dirname "$0")/../.."

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    print_info "Run './scripts/setup.sh' first to set up the project"
    exit 1
fi

# Check Docker daemon
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    exit 1
fi

print_header "Resetting FAM Database"

print_warning "This will completely reset the database and ALL DATA WILL BE LOST!"
print_warning "Are you sure you want to continue? (y/N)"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_info "Database reset cancelled"
    exit 0
fi

print_info "Stopping database container..."
if command -v docker-compose &> /dev/null; then
    docker-compose stop postgres || true
    docker-compose rm -f postgres || true
elif docker compose version &> /dev/null; then
    docker compose stop postgres || true
    docker compose rm -f postgres || true
fi

print_info "Removing database volume..."
docker volume rm fam_postgres_data 2>/dev/null || true

print_info "Rebuilding database container..."
if command -v docker-compose &> /dev/null; then
    docker-compose build --no-cache postgres
    docker-compose up -d postgres
elif docker compose version &> /dev/null; then
    docker compose build --no-cache postgres
    docker compose up -d postgres
fi

print_info "Waiting for database to be ready..."
local retries=30
while [ $retries -gt 0 ]; do
    if command -v docker-compose &> /dev/null; then
        if docker-compose exec -T postgres pg_isready -U fam_user -d fam_db &> /dev/null; then
            break
        fi
    elif docker compose exec -T postgres pg_isready -U fam_user -d fam_db &> /dev/null; then
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

print_success "Database has been reset successfully!"
print_info "Database is ready for use"