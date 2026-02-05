# Inception

*This project has been created as part of the 42 curriculum by sdaban.*

## Description

Inception is a system administration project that focuses on containerization using Docker. The goal is to set up a small infrastructure composed of different services following specific rules. Each service runs in a dedicated Docker container, and the entire infrastructure is orchestrated using Docker Compose.

The project involves creating a multi-container Docker application with:
- An NGINX web server with TLSv1.2 or TLSv1.3
- WordPress with php-fpm
- MariaDB database
- Docker volumes for data persistence
- A custom Docker network for container communication

All containers are built from either Alpine Linux or Debian (penultimate stable version) and use custom Dockerfiles without pulling ready-made images from DockerHub (except for Alpine/Debian base images).

## Instructions

### Prerequisites
- Docker Engine (20.10 or later)
- Docker Compose (1.29 or later)
- Make
- A domain name configured to point to `login.42.fr` (where login is your 42 login)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Create a `.env` file in the `srcs` directory with the required environment variables:
```bash
cp srcs/.env.example srcs/.env
# Edit the .env file with your configuration
```

3. Configure your `/etc/hosts` file to point your domain to localhost:
```bash
echo "127.0.0.1 sdaban.42.fr" | sudo tee -a /etc/hosts
```

### Compilation and Execution

Build and start all services:
```bash
make
```

Stop all services:
```bash
make down
```

Clean all containers, volumes, and images:
```bash
make fclean
```

Rebuild everything from scratch:
```bash
make re
```

### Accessing Services

- **WordPress website**: https://sdaban.42.fr
- **WordPress admin panel**: https://sdaban.42.fr/wp-admin

## Project Architecture

### Docker Usage

This project uses Docker to containerize each service in an isolated environment. The infrastructure consists of:

1. **NGINX Container**: Acts as a reverse proxy and handles TLS termination
2. **WordPress Container**: Runs PHP-FPM to serve the WordPress application
3. **MariaDB Container**: Provides the database backend for WordPress

All containers are connected through a custom Docker network and use Docker volumes for persistent data storage.

### Design Choices

#### Virtual Machines vs Docker

**Virtual Machines:**
- Full OS virtualization with its own kernel
- Higher resource overhead (RAM, CPU, storage)
- Stronger isolation but slower startup times
- Better for running different OS types

**Docker (chosen approach):**
- OS-level virtualization sharing the host kernel
- Lightweight with minimal overhead
- Faster startup and deployment
- Better resource utilization
- Easier to version control and reproduce environments
- Ideal for microservices architecture

**Why Docker for this project:** Docker provides sufficient isolation for our services while maintaining efficiency. It allows us to define infrastructure as code (Dockerfiles and docker-compose.yml) and ensures consistent environments across different machines.

#### Secrets vs Environment Variables

**Environment Variables:**
- Stored in plaintext in `.env` files
- Easier to manage in development
- Risk of accidental exposure in version control
- Suitable for non-sensitive configuration

**Docker Secrets:**
- Encrypted during transit and at rest
- Mounted as files in `/run/secrets/`
- Never stored in environment variables
- Better security for production environments

**Project approach:** While Docker Secrets offer better security, this project uses environment variables for simplicity in a development/educational context. In production, sensitive data (DB passwords, API keys) should migrate to Docker Secrets.

#### Docker Network vs Host Network

**Host Network:**
- Container shares host's network stack
- No network isolation
- Better performance (no NAT overhead)
- Port conflicts with host services

**Docker Network (chosen approach):**
- Creates isolated virtual network
- Containers communicate via service names
- Built-in DNS resolution
- Port mapping provides security layer

**Why Docker Network:** Provides proper isolation and allows containers to communicate securely using service names. NGINX can connect to WordPress via `wordpress:9000` rather than hardcoded IPs, making the setup more maintainable.

#### Docker Volumes vs Bind Mounts

**Bind Mounts:**
- Direct mapping to host filesystem paths
- Host-dependent (specific file paths)
- Useful for development and code hot-reloading
- Less portable across different systems

**Docker Volumes (chosen approach):**
- Managed by Docker in `/var/lib/docker/volumes/`
- Platform-independent storage
- Better performance on non-Linux systems
- Easier backup and migration
- Persist data even when containers are removed

**Project implementation:** Docker volumes are used for:
- WordPress files (`wordpress_data`)
- MariaDB database (`mariadb_data`)

This ensures data persistence and portability while keeping the infrastructure clean and Docker-managed.

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/support/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

### Tutorials and Articles
- [Docker Networking Overview](https://docs.docker.com/network/)
- [Docker Volumes Guide](https://docs.docker.com/storage/volumes/)
- [TLS/SSL Configuration Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)

### AI Usage

AI assistance was used in the following aspects of this project:

**Tasks:**
- Debugging Docker Compose configuration syntax errors
- Understanding TLS certificate generation with OpenSSL
- Optimizing Dockerfile multi-stage builds
- Troubleshooting network connectivity between containers
- Clarifying the differences between volumes and bind mounts

**Parts of the project:**
- Initial boilerplate for Dockerfiles (customized for project requirements)
- README.md structure and documentation formatting
- Makefile optimization suggestions

**Note:** All code was reviewed, understood, and adapted to meet project specifications. AI was used as a learning tool and documentation assistant, not as a replacement for understanding the underlying concepts.

## Additional Information

For detailed instructions:
- **User Documentation**: See [USER_DOC.md](USER_DOC.md)
- **Developer Documentation**: See [DEV_DOC.md](DEV_DOC.md)

## License

This project is part of the 42 school curriculum and is intended for educational purposes.