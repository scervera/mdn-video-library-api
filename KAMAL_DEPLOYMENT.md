# Kamal Deployment Guide for MDN Video Library API

This guide covers deploying the MDN Video Library API using Kamal, a modern deployment tool for Rails applications.

## Prerequisites

- Docker installed on your local machine
- Docker Hub account (or other container registry)
- SSH access to your production server(s)
- PostgreSQL and Redis installed on your production server(s)

## Configuration Files

### 1. `config/deploy.yml`
The main Kamal configuration file that defines:
- Application service name and image
- Server hosts and roles
- Environment variables and secrets
- Accessory services (PostgreSQL, Redis)
- SSL configuration

### 2. `.kamal/secrets`
Contains references to secrets (not the actual values):
- `KAMAL_REGISTRY_PASSWORD`: Docker registry password
- `RAILS_MASTER_KEY`: Rails master key for credentials
- `DATABASE_PASSWORD`: PostgreSQL database password

## Setup Steps

### 1. Update Configuration

Before deploying, update these values in `config/deploy.yml`:

```yaml
# Update with your actual Docker Hub username
image: your-username/mdn_video_library_api

# Update with your actual server IPs
servers:
  web:
    - YOUR_SERVER_IP

# Update with your actual domain
proxy:
  host: your-domain.com

# Update with your actual Docker Hub username
registry:
  username: your-username
```

### 2. Set Environment Variables

Set these environment variables on your local machine:

```bash
export KAMAL_REGISTRY_PASSWORD="your-docker-hub-token"
export DATABASE_PASSWORD="your-database-password"
```

### 3. Build and Deploy

```bash
# Build the Docker image
bundle exec kamal build

# Deploy to production
bundle exec kamal deploy

# Or deploy with a specific version
bundle exec kamal deploy --version=latest
```

## Accessory Services

### PostgreSQL
- Runs on port 5432
- Database: `mdn_video_library_api_production`
- User: `mdn_video_library_api`
- Password: Set via `DATABASE_PASSWORD` environment variable

### Redis
- Runs on port 6379
- Used for caching and session storage

## Useful Commands

```bash
# Check configuration
bundle exec kamal config

# View logs
bundle exec kamal logs

# Access Rails console
bundle exec kamal console

# Access shell
bundle exec kamal shell

# Check app status
bundle exec kamal app status

# Restart application
bundle exec kamal app restart

# Rollback to previous version
bundle exec kamal rollback
```

## Environment Variables

The following environment variables are automatically set by Kamal:

- `RAILS_ENV=production`
- `RAILS_MASTER_KEY`: From your Rails credentials
- `DATABASE_URL`: Constructed from database configuration
- `REDIS_URL`: Redis connection string
- `SOLID_QUEUE_IN_PUMA=true`: Run job processing in Puma

## SSL Configuration

Kamal automatically handles SSL certificates via Let's Encrypt. Make sure your domain points to your server before deploying.

## Monitoring

### Health Checks
- Application health: `https://your-domain.com/up`
- Kamal proxy health: `https://your-domain.com/kamal`

### Logs
- Application logs: `bundle exec kamal logs`
- Proxy logs: `bundle exec kamal logs --proxy`

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Docker is running
   - Verify Dockerfile syntax
   - Check for missing dependencies

2. **Deployment Failures**
   - Verify SSH access to servers
   - Check server has Docker installed
   - Verify environment variables are set

3. **Database Connection Issues**
   - Check PostgreSQL is running
   - Verify database credentials
   - Check network connectivity

4. **SSL Issues**
   - Ensure domain DNS is configured
   - Check Let's Encrypt rate limits
   - Verify proxy configuration

### Debug Commands

```bash
# Check server connectivity
bundle exec kamal app exec "echo 'Connection successful'"

# Check database connection
bundle exec kamal dbc

# View detailed deployment logs
bundle exec kamal deploy --verbose
```

## Production Considerations

### Security
- Never commit secrets to version control
- Use strong database passwords
- Regularly update dependencies
- Monitor access logs

### Performance
- Adjust `WEB_CONCURRENCY` based on server resources
- Monitor memory and CPU usage
- Use appropriate PostgreSQL connection pooling

### Backup
- Regular database backups
- Volume data backups
- Configuration backups

## Updating the Application

```bash
# Pull latest changes
git pull origin main

# Build new image
bundle exec kamal build

# Deploy
bundle exec kamal deploy

# Verify deployment
bundle exec kamal app status
```

## Support

For Kamal-specific issues, refer to the [official Kamal documentation](https://kamal-deploy.org/).

For application-specific issues, check the Rails logs and application configuration.
