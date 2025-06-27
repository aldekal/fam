# Database Setup

This directory contains the PostgreSQL database configuration and setup files for the FAM project.

## Structure

```
db/
├── README.md           # This file
├── Dockerfile          # PostgreSQL 17.5 container configuration
├── init/              # Database initialization scripts
│   ├── 01-create-db.sql
│   └── 02-init-schema.sql
├── scripts/           # Utility scripts
│   ├── start-db.sh
│   ├── stop-db.sh
│   └── reset-db.sh
└── .env.example       # Environment variables template
```

## Quick Start

1. Copy environment template:
   ```bash
   cp .env.example .env
   ```

2. Start the database:
   ```bash
   ./scripts/start-db.sh
   ```

3. Stop the database:
   ```bash
   ./scripts/stop-db.sh
   ```

## Database Configuration

- **Database**: PostgreSQL 17.5
- **Port**: 5432
- **Database Name**: fam_db
- **Username**: fam_user
- **Password**: Configured via environment variables

## PgAdmin

- **URL**: http://localhost:8080
- **Email**: admin@fam.local (configurable)
- **Password**: admin123 (configurable)

**Note**: The database and PgAdmin are configured in the main `docker-compose.yml` file in the project root.

## Environment Variables

Create a `.env` file based on `.env.example` with the following variables:

- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password
- `POSTGRES_PORT`: Database port (default: 5432)

## Connection

The database will be available at:
- Host: `localhost`
- Port: `5432`
- Database: `fam_db`
- Username: `fam_user`

## TODO

- [ ] Add database migrations system
- [ ] Set up database backup scripts
- [ ] Add performance monitoring
- [ ] Configure SSL/TLS
- [ ] Add connection pooling configuration
- [ ] Set up database logging
- [ ] Add health check endpoints
