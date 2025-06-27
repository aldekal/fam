#!/bin/bash

# FAM Database Shutdown Script
# This script stops only the PostgreSQL database service

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

# Check Docker daemon
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    exit 1
fi

print_header "Stopping FAM Database"

print_info "Stopping PostgreSQL database..."

# Try docker-compose first, then docker compose
if command -v docker-compose &> /dev/null; then
    docker-compose stop postgres
elif docker compose version &> /dev/null; then
    docker compose stop postgres
else
    print_error "Neither docker-compose nor docker compose is available"
    exit 1
fi

print_success "Database stopped successfully!"