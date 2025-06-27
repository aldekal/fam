# FAM - The Family Mangment and Visualtion Application

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Available-blue.svg)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17.5-blue.svg)](https://www.postgresql.org/)
[![Development Status](https://img.shields.io/badge/Status-In%20Development-orange.svg)](#development-status)

A modern, full-stack family management application designed to help families stay organized and connected. Built with a robust technology stack including PostgreSQL, Java Spring Boot, and React Next.js.

## ✨ Features (Planned)

- 📅 **Family Calendar** - Shared family events and scheduling.
- 📋 **Family Graph** - Visualisation of the Family as Graph.
- 📊 **Analytics Dashboard** - Family insights.

## 📁 Project Structure

```
fam/
├── 📄 README.md                 # Project documentation
├── 🐳 docker-compose.yml        # Container orchestration
├── 📜 LICENSE                   # MIT License
├── 🛠️ scripts/                  # Utility scripts
├── 🗄️ db/                       # PostgreSQL database
│   ├── Dockerfile               # Database container config
│   ...
├── ☕  api/                      # Java Spring Boot backend (TODO)
└── ⚛️ ui/                       # React Next.js frontend (TODO)
```

## 🚀 Quick Start

### Prerequisites

Ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)
- [Git](https://git-scm.com/downloads)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/fam.git
   cd fam
   ```

2. **Setup the project:**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

3. **Configure environment:**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit the .env file with your settings
   nano .env  # or use your preferred editor
   ```

4. **Start development environment:**
   ```bash
   ./scripts/start-dev.sh
   ```

5. **Verify installation:**
   - Database: `http://localhost:8080` (PgAdmin)
   - API: `http://localhost:8081` (Coming soon)
   - Frontend: `http://localhost:3000` (Coming soon)

6. **Stop development environment:**
   ```bash
   ./scripts/stop-dev.sh
   ```

## 🛠️ Technology Stack

| Component | Technology | Version | Status |
|-----------|------------|---------|--------|
| **Database** | PostgreSQL | 17.5 | ✅ Ready |
| **DB Management** | PgAdmin | 4 | ✅ Ready |
| **Backend** | Java + Spring Boot | 21 | 🚧 Planned |
| **Frontend** | React + Next.js | Latest | 🚧 Planned |
| **Containerization** | Docker & Docker Compose | Latest | ✅ Ready |
| **Build Tool** | Maven/Gradle | Latest | 🚧 Planned |
| **Authentication** | Spring Security | Latest | 🚧 Planned |

## 🗄️ Database

The PostgreSQL database is fully configured and ready to use. See [`db/README.md`](./db/README.md) for detailed database documentation.

### Connection Details

| Parameter | Value | Description |
|-----------|-------|-------------|
| **Host** | `localhost` | Database host |
| **Port** | `5432` | PostgreSQL port |
| **Database** | `fam_db` | Database name |
| **Username** | `fam_user` | Database user |
| **Password** | *See .env file* | Database password |

### PgAdmin Web Interface

Access the database management interface at:

- **URL**: `http://localhost:8080`
- **Email**: `admin@fam.local`
- **Password**: `admin123`

> ⚠️ **Security Note**: Change the default PgAdmin credentials in production environments!

## 💻 Development

### Development Status

Currently, only the database layer is implemented. The backend and frontend components are planned for future development.

- ✅ **Database Setup**: PostgreSQL with PgAdmin
- 🚧 **Backend API**: Java Spring Boot (In Planning)
- 🚧 **Frontend**: React Next.js (In Planning)
- 🚧 **Authentication**: Spring Security (In Planning)

### Environment Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your configuration:
   ```bash
   # Database Configuration
   POSTGRES_DB=fam_db
   POSTGRES_USER=fam_user
   POSTGRES_PASSWORD=your_secure_password
   
   # PgAdmin Configuration
   PGADMIN_DEFAULT_EMAIL=admin@fam.local
   PGADMIN_DEFAULT_PASSWORD=your_admin_password
   ```

3. **Security Best Practices**:
   - Use strong, unique passwords
   - Never commit the `.env` file to version control
   - Regularly rotate passwords in production

### Available Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `setup.sh` | Initial project setup | `./scripts/setup.sh` |
| `start-dev.sh` | Start development environment | `./scripts/start-dev.sh [--logs]` |
| `stop-dev.sh` | Stop development environment | `./scripts/stop-dev.sh [--clean] [--volumes]` |
| `health-check.sh` | Check environment health | `./scripts/health-check.sh` |

#### Database Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `start-db.sh` | Start only database | `./db/scripts/start-db.sh` |
| `stop-db.sh` | Stop only database | `./db/scripts/stop-db.sh` |
| `reset-db.sh` | Reset database (⚠️ deletes data) | `./db/scripts/reset-db.sh` |

### Make Commands (Optional)

If you have `make` installed, you can use these convenient shortcuts:

```bash
# Project setup and management
make setup          # Initial project setup
make start           # Start development environment  
make stop            # Stop development environment
make restart         # Restart environment
make status          # Show service status
make logs            # View service logs
make health-check    # Run health check

# Database management
make db-start        # Start only database
make db-stop         # Stop only database
make db-reset        # Reset database (with confirmation)
make shell-db        # Open database shell
make backup-db       # Create database backup

# Docker management
make build           # Build Docker images
make clean           # Clean up containers/networks
make docker-clean    # Clean Docker system
```

### Useful Commands

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs

# Restart specific service
docker-compose restart postgres

# Clean up (removes containers and volumes)
docker-compose down -v

# Rebuild containers
docker-compose up --build
```

## 🔧 Troubleshooting

### Common Issues

#### Port Already in Use
If you get port binding errors:
```bash
# Check what's using the port
sudo lsof -i :5432  # for PostgreSQL
sudo lsof -i :8080  # for PgAdmin

# Stop the conflicting service or change ports in docker-compose.yml
```

#### Permission Denied on Scripts
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

#### Database Connection Issues
1. Ensure Docker containers are running:
   ```bash
   docker-compose ps
   ```
2. Check container logs:
   ```bash
   docker-compose logs postgres
   docker-compose logs pgadmin
   ```
3. Verify environment variables in `.env` file

#### PgAdmin Login Issues
- Default credentials are in the `.env` file
- Clear browser cache if experiencing login loops
- Check PgAdmin logs: `docker-compose logs pgadmin`

### Getting Help

- 📖 Check the [Wiki](https://github.com/yourusername/fam/wiki) for detailed guides
- 🐛 Report bugs in [Issues](https://github.com/yourusername/fam/issues)
- 💬 Join discussions in [Discussions](https://github.com/yourusername/fam/discussions)

## 📋 Development Roadmap

### 🎯 Phase 1: Backend Development (Java Spring Boot)
- [ ] **Project Setup**
  - [ ] Create Spring Boot project structure
  - [ ] Configure Maven/Gradle build system
  - [ ] Set up development environment
- [ ] **Database Integration**
  - [ ] Configure JPA/Hibernate for PostgreSQL
  - [ ] Create entity models
  - [ ] Implement database migrations
- [ ] **Core API Development**
  - [ ] Implement REST API endpoints
  - [ ] Add input validation
  - [ ] Implement error handling
- [ ] **Security & Authentication**
  - [ ] Add Spring Security configuration
  - [ ] Implement JWT authentication
  - [ ] Set up role-based authorization
- [ ] **Testing & Documentation**
  - [ ] Set up testing framework (JUnit)
  - [ ] Add API documentation (Swagger/OpenAPI)
  - [ ] Configure logging (Logback)
  - [ ] Add health checks and metrics

### 🎨 Phase 2: Frontend Development (React Next.js)
- [ ] **Project Setup**
  - [ ] Create Next.js project structure
  - [ ] Set up TypeScript configuration
  - [ ] Configure ESLint and Prettier
- [ ] **UI Foundation**
  - [ ] Set up design system/component library
  - [ ] Implement responsive layouts
  - [ ] Create reusable UI components
- [ ] **Authentication & Routing**
  - [ ] Implement authentication flow
  - [ ] Set up protected routes
  - [ ] Configure Next.js routing
- [ ] **State Management & API Integration**
  - [ ] Set up state management (Redux/Zustand)
  - [ ] Implement API client
  - [ ] Add data fetching patterns
- [ ] **Testing & Optimization**
  - [ ] Add testing framework (Jest/React Testing Library)
  - [ ] Configure build optimization
  - [ ] Implement SEO optimization

### 🚀 Phase 3: DevOps & Production
- [ ] **CI/CD Pipeline**
  - [ ] Set up GitHub Actions
  - [ ] Configure automated testing
  - [ ] Implement deployment pipeline
- [ ] **Production Infrastructure**
  - [ ] Create production Docker configurations
  - [ ] Set up reverse proxy (Nginx)
  - [ ] Configure SSL certificates
- [ ] **Monitoring & Maintenance**
  - [ ] Configure monitoring and logging
  - [ ] Set up backup strategies
  - [ ] Add security scanning
  - [ ] Performance optimization

### 📚 Phase 4: Documentation & Community
- [ ] **Documentation**
  - [ ] Complete API documentation
  - [ ] Create user guides
  - [ ] Write developer documentation
- [ ] **Code Quality & Standards**
  - [ ] Set up code quality tools (SonarQube)
  - [ ] Create development guidelines
  - [ ] Implement pre-commit hooks
- [ ] **Community & Contributions**
  - [ ] Add contribution guidelines
  - [ ] Create issue templates
  - [ ] Set up discussions and wiki

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute

- 🐛 **Report Bugs**: Submit detailed bug reports with steps to reproduce
- 💡 **Suggest Features**: Propose new features or improvements
- 📖 **Improve Documentation**: Help make our docs clearer and more comprehensive
- 💻 **Submit Code**: Fix bugs or implement new features

### Development Process

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow our coding standards
4. **Test your changes**: Ensure all tests pass
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**: Describe your changes and link any related issues

### Code Standards

- Follow existing code style and conventions
- Write meaningful commit messages
- Add tests for new functionality
- Update documentation as needed
- Ensure your code passes all CI checks

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **PostgreSQL Team** - For the robust database system
- **Spring Boot Community** - For the excellent framework
- **React & Next.js Teams** - For the powerful frontend technologies
- **Docker** - For containerization platform
- **Contributors** - Everyone who helps improve this project

## 📬 Contact & Support

- **Project Repository**: [https://github.com/yourusername/fam](https://github.com/yourusername/fam)
- **Documentation**: [Wiki](https://github.com/yourusername/fam/wiki)
- **Bug Reports**: [Issues](https://github.com/yourusername/fam/issues)
- **Feature Requests**: [Discussions](https://github.com/yourusername/fam/discussions)

---

<div align="center">
  <p>Made with ❤️ for families everywhere</p>
  <p>
    <a href="#-fam---family-application-monorepo">⬆️ Back to Top</a>
  </p>
</div>