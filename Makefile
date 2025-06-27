# FAM Project Makefile
# Provides convenient commands for development workflow

.PHONY: help setup start stop restart clean logs status db-start db-stop db-reset health-check

# Default target
help: ## Show this help message
	@echo "FAM Project - Available Commands:"
	@echo
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo
	@echo "Examples:"
	@echo "  make setup        # Initial project setup"
	@echo "  make start        # Start development environment"
	@echo "  make health-check # Check environment health"
	@echo "  make logs         # View logs"

setup: ## Run initial project setup
	@./scripts/setup.sh

start: ## Start development environment
	@./scripts/start-dev.sh

stop: ## Stop development environment
	@./scripts/stop-dev.sh

restart: stop start ## Restart development environment

clean: ## Stop and clean up containers/networks
	@./scripts/stop-dev.sh --clean

logs: ## Show logs for all services
	@if docker compose version >/dev/null 2>&1; then \
		docker compose logs -f; \
	elif command -v docker-compose >/dev/null 2>&1 && docker-compose --version >/dev/null 2>&1; then \
		docker-compose logs -f; \
	else \
		echo "Showing individual container logs:"; \
		docker logs -f postgres & docker logs -f pgadmin & wait; \
	fi

status: ## Show status of all services
	@if docker compose version >/dev/null 2>&1; then \
		docker compose ps; \
	elif command -v docker-compose >/dev/null 2>&1 && docker-compose --version >/dev/null 2>&1; then \
		docker-compose ps; \
	else \
		docker ps --filter "name=postgres" --filter "name=pgadmin" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; \
	fi

db-start: ## Start only the database
	@./db/scripts/start-db.sh

db-stop: ## Stop only the database
	@./db/scripts/stop-db.sh

db-reset: ## Reset database (WARNING: Deletes all data!)
	@./db/scripts/reset-db.sh

health-check: ## Check development environment health
	@./scripts/health-check.sh

# Development shortcuts
dev: start ## Alias for start

down: stop ## Alias for stop

ps: status ## Alias for status

# Build targets
build: ## Build all Docker images
	@if docker compose version >/dev/null 2>&1; then \
		docker compose build; \
	elif command -v docker-compose >/dev/null 2>&1 && docker-compose --version >/dev/null 2>&1; then \
		docker-compose build; \
	else \
		echo "Neither docker compose nor docker-compose is available"; \
		exit 1; \
	fi

build-no-cache: ## Build all Docker images without cache
	@if docker compose version >/dev/null 2>&1; then \
		docker compose build --no-cache; \
	elif command -v docker-compose >/dev/null 2>&1 && docker-compose --version >/dev/null 2>&1; then \
		docker-compose build --no-cache; \
	else \
		echo "Neither docker compose nor docker-compose is available"; \
		exit 1; \
	fi

# Utility targets
shell-db: ## Open shell in database container
	@if docker compose version >/dev/null 2>&1; then \
		docker compose exec postgres psql -U fam_user -d fam_db; \
	elif command -v docker-compose >/dev/null 2>&1 && docker-compose --version >/dev/null 2>&1; then \
		docker-compose exec postgres psql -U fam_user -d fam_db; \
	else \
		docker exec -it postgres psql -U fam_user -d fam_db; \
	fi

backup-db: ## Create database backup
	@mkdir -p backups
	@if docker compose version >/dev/null 2>&1; then \
		docker compose exec -T postgres pg_dump -U fam_user fam_db > backups/fam_db_backup_$$(date +%Y%m%d_%H%M%S).sql; \
	elif command -v docker-compose >/dev/null 2>&1 && docker-compose --version >/dev/null 2>&1; then \
		docker-compose exec -T postgres pg_dump -U fam_user fam_db > backups/fam_db_backup_$$(date +%Y%m%d_%H%M%S).sql; \
	else \
		docker exec -i postgres pg_dump -U fam_user fam_db > backups/fam_db_backup_$$(date +%Y%m%d_%H%M%S).sql; \
	fi
	@echo "Database backup created in backups/ directory"

# Linting and formatting (for future use)
lint: ## Run linting (placeholder for future API/UI linting)
	@echo "Linting placeholder - add specific linting commands here when API/UI are implemented"

test: ## Run tests (placeholder for future tests)
	@echo "Testing placeholder - add test commands here when API/UI are implemented"

# Docker management
docker-clean: ## Clean up Docker system
	@docker system prune -f
	@docker volume prune -f

docker-reset: ## Reset entire Docker environment (WARNING: Removes all containers/volumes)
	@echo "This will remove ALL Docker containers, images, and volumes on your system!"
	@echo "Are you sure? Type 'yes' to continue: "
	@read confirm && [ "$$confirm" = "yes" ] && docker system prune -a --volumes -f || echo "Cancelled"
