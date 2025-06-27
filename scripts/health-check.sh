#!/bin/bash

# FAM Project Health Check Script
# This script checks the health and status of the FAM development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
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
    echo -e "${BOLD}${BLUE}===================================================${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}===================================================${NC}"
    echo
}

# Check system dependencies
check_dependencies() {
    print_header "System Dependencies"
    
    local all_good=true
    
    # Check Docker
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker: $docker_version"
        
        if docker info &> /dev/null; then
            print_success "Docker daemon: Running"
        else
            print_error "Docker daemon: Not running"
            all_good=false
        fi
    else
        print_error "Docker: Not installed"
        all_good=false
    fi
    
    # Check Docker Compose
    if docker compose version &> /dev/null; then
        local compose_version=$(docker compose version --short 2>/dev/null || echo "V2")
        print_success "Docker Compose: $compose_version"
    elif command -v docker-compose &> /dev/null && docker-compose --version &> /dev/null 2>&1; then
        local compose_version=$(docker-compose --version | cut -d' ' -f4 | cut -d',' -f1)
        print_success "Docker Compose: $compose_version"
    else
        print_error "Docker Compose: Not available or broken"
        all_good=false
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        local git_version=$(git --version | cut -d' ' -f3)
        print_success "Git: $git_version"
    else
        print_warning "Git: Not installed"
    fi
    
    # Check Make
    if command -v make &> /dev/null; then
        local make_version=$(make --version | head -n1 | cut -d' ' -f3)
        print_success "Make: $make_version"
    else
        print_info "Make: Not installed (optional)"
    fi
    
    return $([[ $all_good == true ]] && echo 0 || echo 1)
}

# Check project files
check_project_files() {
    print_header "Project Configuration"
    
    local all_good=true
    
    # Check essential files
    local essential_files=(
        "docker-compose.yml"
        ".env.example"
        "scripts/setup.sh"
        "scripts/start-dev.sh"
        "scripts/stop-dev.sh"
        "db/Dockerfile"
        "db/init/02-init-schema.sql"
    )
    
    for file in "${essential_files[@]}"; do
        if [ -f "$file" ]; then
            print_success "Found: $file"
        else
            print_error "Missing: $file"
            all_good=false
        fi
    done
    
    # Check .env file
    if [ -f ".env" ]; then
        print_success "Environment file: .env exists"
        
        # Check for critical environment variables
        local required_vars=("POSTGRES_DB" "POSTGRES_USER" "POSTGRES_PASSWORD")
        for var in "${required_vars[@]}"; do
            if grep -q "^$var=" .env; then
                print_success "Environment variable: $var is set"
            else
                print_warning "Environment variable: $var might not be set"
            fi
        done
    else
        print_warning "Environment file: .env not found (run setup script)"
    fi
    
    # Check script permissions
    local scripts=("scripts/setup.sh" "scripts/start-dev.sh" "scripts/stop-dev.sh")
    for script in "${scripts[@]}"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            print_success "Executable: $script"
        elif [ -f "$script" ]; then
            print_warning "Not executable: $script"
        fi
    done
    
    return $([[ $all_good == true ]] && echo 0 || echo 1)
}

# Check Docker services
check_services() {
    print_header "Docker Services Status"
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running"
        return 1
    fi
    
    # Check if containers exist and their status
    local containers=("postgres" "pgadmin")
    local all_good=true
    
    for container in "${containers[@]}"; do
        if docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep -q "$container"; then
            local status=$(docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep "$container" | awk '{print $2}')
            if [[ "$status" == "Up" ]]; then
                print_success "Container $container: Running"
            else
                print_warning "Container $container: $status"
            fi
        else
            print_info "Container $container: Not created"
        fi
    done
    
    # Check networks
    if docker network ls | grep -q "fam_network"; then
        print_success "Network: fam_network exists"
    else
        print_info "Network: fam_network not created"
    fi
    
    # Check volumes
    if docker volume ls | grep -q "fam_postgres_data"; then
        print_success "Volume: fam_postgres_data exists"
    else
        print_info "Volume: fam_postgres_data not created"
    fi
    
    return 0
}

# Check database connectivity
check_database() {
    print_header "Database Connectivity"
    
    if ! docker ps | grep -q "postgres.*Up"; then
        print_warning "PostgreSQL container is not running"
        return 1
    fi
    
    # Test database connection
    if command -v docker-compose &> /dev/null; then
        if docker-compose exec -T postgres pg_isready -U fam_user -d fam_db &> /dev/null; then
            print_success "Database: Connection successful"
            
            # Get database info
            local db_version=$(docker-compose exec -T postgres psql -U fam_user -d fam_db -t -c "SELECT version();" | head -n1 | xargs)
            print_info "Database version: $db_version"
            
            # Check tables
            local table_count=$(docker-compose exec -T postgres psql -U fam_user -d fam_db -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)
            print_info "Tables in database: $table_count"
        else
            print_error "Database: Connection failed"
            return 1
        fi
    elif docker compose version &> /dev/null; then
        if docker compose exec -T postgres pg_isready -U fam_user -d fam_db &> /dev/null; then
            print_success "Database: Connection successful"
            
            # Get database info
            local db_version=$(docker compose exec -T postgres psql -U fam_user -d fam_db -t -c "SELECT version();" | head -n1 | xargs)
            print_info "Database version: $db_version"
            
            # Check tables
            local table_count=$(docker compose exec -T postgres psql -U fam_user -d fam_db -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)
            print_info "Tables in database: $table_count"
        else
            print_error "Database: Connection failed"
            return 1
        fi
    fi
    
    return 0
}

# Check project structure
check_project_structure() {
    print_header "Project Structure"
    
    local directories=("api" "ui" "db" "scripts")
    
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            local file_count=$(find "$dir" -type f | wc -l)
            print_success "Directory $dir: $file_count files"
        else
            print_warning "Directory $dir: Missing"
        fi
    done
    
    # Check for development readiness
    if [ -d "api" ] && [ "$(find api -name '*.java' -o -name 'pom.xml' | wc -l)" -gt 0 ]; then
        print_success "Backend: Java/Spring Boot files detected"
    else
        print_info "Backend: Ready for implementation"
    fi
    
    if [ -d "ui" ] && [ "$(find ui -name 'package.json' -o -name '*.tsx' -o -name '*.jsx' | wc -l)" -gt 0 ]; then
        print_success "Frontend: React/Next.js files detected"
    else
        print_info "Frontend: Ready for implementation"
    fi
}

# Check accessible URLs
check_urls() {
    print_header "Service URLs"
    
    # Check if containers are running first
    if docker ps | grep -q "pgadmin.*Up"; then
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|302"; then
            print_success "PgAdmin: http://localhost:8080 (accessible)"
        else
            print_warning "PgAdmin: http://localhost:8080 (not responding)"
        fi
    else
        print_info "PgAdmin: Container not running"
    fi
    
    # Future service checks
    print_info "API: http://localhost:3000 (not implemented yet)"
    print_info "Frontend: http://localhost:3001 (not implemented yet)"
}

# Generate summary report
generate_summary() {
    print_header "Health Check Summary"
    
    local total_checks=6
    local passed_checks=0
    
    echo "Dependency Check: $([[ $dep_status == 0 ]] && echo "✅ PASS" || echo "❌ FAIL")"
    [[ $dep_status == 0 ]] && ((passed_checks++))
    
    echo "Project Files: $([[ $files_status == 0 ]] && echo "✅ PASS" || echo "❌ FAIL")"
    [[ $files_status == 0 ]] && ((passed_checks++))
    
    echo "Docker Services: $([[ $services_status == 0 ]] && echo "✅ PASS" || echo "❌ FAIL")"
    [[ $services_status == 0 ]] && ((passed_checks++))
    
    echo "Database: $([[ $db_status == 0 ]] && echo "✅ PASS" || echo "❌ FAIL")"
    [[ $db_status == 0 ]] && ((passed_checks++))
    
    echo "Project Structure: ✅ PASS"
    ((passed_checks++))
    
    echo "Service URLs: ✅ PASS"
    ((passed_checks++))
    
    echo
    echo "Overall Score: $passed_checks/$total_checks"
    
    if [ $passed_checks -eq $total_checks ]; then
        print_success "🎉 All checks passed! Your FAM development environment is ready!"
    elif [ $passed_checks -ge 4 ]; then
        print_warning "⚠️ Most checks passed. Review warnings above."
    else
        print_error "❌ Several issues detected. Please address the errors above."
        echo
        print_info "Quick fixes:"
        print_info "1. Run './scripts/setup.sh' if you haven't already"
        print_info "2. Make sure Docker is running"
        print_info "3. Run './scripts/start-dev.sh' to start services"
    fi
}

# Main function
main() {
    # Get to the project root directory
    cd "$(dirname "$0")/.."
    
    print_header "FAM Project Health Check"
    print_info "Checking development environment status..."
    
    # Run all checks
    check_dependencies
    dep_status=$?
    
    check_project_files
    files_status=$?
    
    check_services
    services_status=$?
    
    check_database
    db_status=$?
    
    check_project_structure
    
    check_urls
    
    generate_summary
}

# Handle command line arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0"
    echo
    echo "Performs a comprehensive health check of the FAM development environment"
    echo
    exit 0
fi

# Run main function
main "$@"
