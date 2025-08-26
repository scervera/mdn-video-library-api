# Kamal Deployment Configuration Guide

This document explains the proper configuration of `config/deploy.yml` for deploying a Rails application with Kamal, including PostgreSQL and Redis accessories.

## Overview

The configuration ensures that:
- The Rails application can connect to PostgreSQL and Redis
- Accessories are properly networked and secured
- Environment variables are correctly set
- SSL/HTTPS is properly configured

## Complete Configuration Example

```yaml
# Kamal deployment configuration for Rails app with PostgreSQL and Redis
service: curriculum_library_api
image: registry.digitalocean.com/cervera/scervera/curriculum_library_api

# SSL is handled by the proxy server
# Kamal will run the app with SSL since the proxy handles termination
proxy:
  host: curriculum-library-api.cerveras.com
  ssl: true

# Credentials for your image host
registry:
  username:
    - KAMAL_REGISTRY_USERNAME
  password:
    - KAMAL_REGISTRY_PASSWORD

# Environment variables for the Rails application
env:
  clear:
    # Database configuration
    # DB_HOST: [service name]-[accessory name]
    DB_HOST: curriculum_library_api-db
    
    # Redis configuration
    REDIS_URL: redis://redis:6379/0
    
    # Rails configuration
    RAILS_ENV: production
    RAILS_SERVE_STATIC_FILES: true
    RAILS_LOG_LEVEL: info
    
    # Additional Rails configuration
    RAILS_MAX_THREADS: 5
    WEB_CONCURRENCY: 1
    
    # CORS configuration - allow frontend domains - change to your specific domains
    ALLOWED_ORIGINS: "http://localhost:3000,http://localhost:3001,http://localhost:4000,https://curriculum.cerveras.com,https://curriculum-library-api.cerveras.com,https://cloud.cerveras.com,https://mdn-video-library-app.vercel.app"
  
  secret:
    - DATABASE_PASSWORD
    - SECRET_KEY_BASE

# Use accessory services (secrets come from .kamal/secrets)
accessories:
  db:
    image: postgres:15
    host: cloud.cerveras.com # host: hostname of the Docker server
    port: "127.0.0.1:5432:5432"
    env:
      clear:
        POSTGRES_DB: curriculum_library_api_production
        POSTGRES_USER: curriculum_library_api
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data
      
  redis:
    image: redis:7.0
    host: cloud.cerveras.com  # host: hostname of the Docker server
    port: "127.0.0.1:6379:6379" # port prevents exposure to the outside world
    directories:
      - data:/data
```

## Key Configuration Sections Explained

### 1. Service and Image Configuration

```yaml
service: curriculum_library_api
image: registry.digitalocean.com/cervera/scervera/curriculum_library_api
```

- **`service`**: The name of your Rails application service
- **`image`**: The Docker registry and image name for your application

### 2. Proxy Configuration

```yaml
proxy:
  host: curriculum-library-api.cerveras.com
  ssl: true
```

- **`host`**: The domain name where your API will be accessible
- **`ssl: true`**: Enables HTTPS/SSL termination at the proxy level

### 3. Registry Configuration

```yaml
registry:
  username:
    - KAMAL_REGISTRY_USERNAME
  password:
    - KAMAL_REGISTRY_PASSWORD
```

- **`username`** and **`password`**: Credentials for your Docker registry
- These should be set as environment variables on your local machine

### 4. Environment Variables

#### Clear Environment Variables

```yaml
env:
  clear:
    DB_HOST: curriculum_library_api-db
    REDIS_URL: redis://redis:6379/0
    RAILS_ENV: production
    # ... other variables
```

**Important Notes:**
- **`DB_HOST`**: Must be set to the full container name of your database accessory
- **`REDIS_URL`**: Uses the service name `redis` for internal communication
- **`ALLOWED_ORIGINS`**: Comma-separated list of domains allowed for CORS

#### Secret Environment Variables

```yaml
env:
  secret:
    - DATABASE_PASSWORD
    - SECRET_KEY_BASE
```

- These variables are read from `.kamal/secrets` file
- Never commit secrets to version control

### 5. Accessories Configuration

#### PostgreSQL Database

```yaml
accessories:
  db:
    image: postgres:15
    host: cloud.cerveras.com
    port: "127.0.0.1:5432:5432"
    env:
      clear:
        POSTGRES_DB: curriculum_library_api_production
        POSTGRES_USER: curriculum_library_api
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data
```

**Key Points:**
- **`host`**: The server where the accessory will run
- **`port: "127.0.0.1:5432:5432"`**: Binds PostgreSQL to localhost only (not exposed to internet)
- **`POSTGRES_PASSWORD`**: Must be in the `secret` section, not `clear`

#### Redis

```yaml
redis:
  image: redis:7.0
  host: cloud.cerveras.com
  port: "127.0.0.1:6379:6379"
  directories:
    - data:/data
```

**Key Points:**
- **`port: "127.0.0.1:6379:6379"`**: Binds Redis to localhost only (not exposed to internet)
- No authentication required for Redis in this configuration

## Security Considerations

### 1. Port Binding Strategy

The configuration uses `127.0.0.1` binding for accessories:

```yaml
port: "127.0.0.1:5432:5432"  # PostgreSQL
port: "127.0.0.1:6379:6379"  # Redis
```

This ensures that:
- PostgreSQL and Redis are only accessible from the host machine
- The Rails container can access them via the Docker network
- External access is blocked for security

### 2. Environment Variable Security

- **Clear variables**: Safe to expose (configuration, URLs, etc.)
- **Secret variables**: Sensitive data (passwords, keys, etc.)

### 3. CORS Configuration

```yaml
ALLOWED_ORIGINS: "http://localhost:3000,http://localhost:3001,http://localhost:4000,https://curriculum.cerveras.com,https://curriculum-library-api.cerveras.com,https://cloud.cerveras.com,https://mdn-video-library-app.vercel.app"
```

Include all domains that need to access your API, including:
- Development environments
- Production frontend domains
- Any third-party integrations

## Database Configuration

### config/database.yml

Your `config/database.yml` should use the `DB_HOST` environment variable:

```yaml
production:
  primary: &primary_production
    <<: *default
    database: curriculum_library_api_production
    username: curriculum_library_api
    password: <%= ENV["DATABASE_PASSWORD"] %>
    host: <%= ENV["DB_HOST"] || "localhost" %>
    port: <%= ENV["DB_PORT"] || 5432 %>
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  cache:
    <<: *primary_production
    database: curriculum_library_api_production_cache
    migrations_paths: db/cache_migrate
  queue:
    <<: *primary_production
    database: curriculum_library_api_production_queue
    migrations_paths: db/queue_migrate
  cable:
    <<: *primary_production
    database: curriculum_library_api_production_cable
    migrations_paths: db/cable_migrate
```

## Secrets Management

### .kamal/secrets

Create a `.kamal/secrets` file with your sensitive data:

```bash
# Database password
DATABASE_PASSWORD=your_secure_database_password_here

# Rails secret key base
SECRET_KEY_BASE=your_rails_secret_key_base_here

# PostgreSQL password (mapped from DATABASE_PASSWORD)
POSTGRES_PASSWORD=$DATABASE_PASSWORD
```

**Important:**
- Never commit this file to version control
- Add `.kamal/secrets` to your `.gitignore`
- Use strong, unique passwords

## Deployment Commands

### Initial Setup

```bash
# Set up Kamal (first time only)
kamal setup

# Boot accessories
kamal accessory boot

# Deploy the application
kamal deploy
```

### Database Operations

```bash
# Create databases
kamal app exec "bundle exec rails db:create"

# Run migrations
kamal app exec "bundle exec rails db:migrate"

# Seed the database
kamal app exec "bundle exec rails db:seed"
```

### Maintenance Commands

```bash
# View logs
kamal logs

# Restart the application
kamal app restart

# Access Rails console
kamal app exec "bundle exec rails console"

# Check application health
curl https://your-domain.com/up
```

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify `DB_HOST` is set correctly
   - Check that accessories are running: `kamal accessory boot`
   - Ensure database exists: `kamal app exec "bundle exec rails db:create"`

2. **CORS Errors**
   - Verify `ALLOWED_ORIGINS` includes your frontend domain
   - Check that the proxy is configured correctly

3. **SSL/HTTPS Issues**
   - Ensure `proxy.ssl: true` is set
   - Verify your domain has valid SSL certificates

4. **Port Binding Issues**
   - Ensure port bindings use `127.0.0.1` for security
   - Check that ports aren't already in use on the host

### Debugging Commands

```bash
# Check container status
ssh root@your-server "docker ps -a"

# View container logs
kamal logs --lines 20

# Check network connectivity
kamal app exec "ping -c 3 curriculum_library_api-db"

# Test database connection
kamal app exec "bundle exec rails runner 'puts ActiveRecord::Base.connection.execute(\"SELECT 1\").first'"
```

## Best Practices

1. **Security**
   - Always use `127.0.0.1` binding for database ports
   - Keep secrets in `.kamal/secrets`, never in `deploy.yml`
   - Use strong passwords and rotate them regularly

2. **Configuration**
   - Use environment variables for configuration
   - Keep `deploy.yml` in version control
   - Document any custom configurations

3. **Monitoring**
   - Set up health checks for your application
   - Monitor logs regularly
   - Set up alerts for application failures

4. **Backup**
   - Regularly backup your PostgreSQL data
   - Test your backup and restore procedures
   - Keep multiple backup copies

## Conclusion

This configuration provides a secure, scalable deployment setup for Rails applications with Kamal. The key is understanding how the different components interact:

- **Rails App** ↔ **PostgreSQL** (via Docker network)
- **Rails App** ↔ **Redis** (via Docker network)
- **External Clients** ↔ **Rails App** (via Kamal proxy)

By following this configuration, you'll have a production-ready Rails API that's secure, performant, and maintainable.
