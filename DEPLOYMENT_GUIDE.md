# Rails 8 + Kamal Deployment Guide

This guide covers deploying your Rails 8 application using Kamal for both fresh installations and updates.

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ Kamal installed locally (`gem install kamal`)
- ✅ Docker installed and running
- ✅ Access to your server via SSH
- ✅ DigitalOcean registry access token
- ✅ Environment variables configured (see `.kamal/secrets`)

## 🚀 Fresh Installation (First Time Setup)

### Step 1: Initial Kamal Setup

```bash
# Run initial Kamal setup (only needed once)
kamal setup
```

This command:
- Creates the `.kamal` directory structure
- Sets up SSH connections to your servers
- Initializes the Kamal proxy
- Creates necessary Docker networks

### Step 2: Configure Secrets

Ensure your `.kamal/secrets` file contains all required secrets:

```bash
# Example .kamal/secrets file
RAILS_MASTER_KEY=your_rails_master_key_here
KAMAL_REGISTRY_PASSWORD=your_digitalocean_token_here
DATABASE_PASSWORD=your_database_password_here
POSTGRES_PASSWORD=your_database_password_here
```

### Step 3: Deploy the Application

```bash
# Deploy the application for the first time
kamal deploy
```

This will:
- Build the Docker image
- Push to your registry
- Pull and start the container on your server
- Set up the Kamal proxy

### Step 4: Database Setup

After the first deployment, set up your database:

```bash
# Create all databases (main, cache, queue, cable)
kamal app exec "bundle exec rails db:create"

# Run migrations to create tables
kamal app exec "bundle exec rails db:migrate"

# Seed with demo data (optional)
kamal app exec "bundle exec rails db:seed"
```

### Step 5: Verify Deployment

```bash
# Check application health
curl http://cloud.cerveras.com/up

# Should return: <!DOCTYPE html><html><body style="background-color: green"></body></html>

# Check application logs
kamal app logs

# Test API endpoint
curl http://cloud.cerveras.com/api/curricula
# Should return: {"error":"No token provided"}
```

## 🔄 Updating Existing Deployment

### Step 1: Commit Your Changes

```bash
# Make your changes locally
git add .
git commit -m "Your commit message"
git push origin master
```

### Step 2: Deploy Updates

```bash
# Deploy the updated application
kamal deploy
```

This will:
- Build a new Docker image with your changes
- Push to registry
- Pull and start the new container
- Update the proxy configuration
- Gracefully stop the old container

### Step 3: Run Database Migrations (if needed)

If you have new migrations:

```bash
# Run pending migrations
kamal app exec "bundle exec rails db:migrate"

# Check migration status
kamal app exec "bundle exec rails db:migrate:status"
```

### Step 4: Verify the Update

```bash
# Check application health
curl http://cloud.cerveras.com/up

# Check application logs
kamal app logs

# Test your updated functionality
```

## 🗄️ Database Management

### Creating Databases

```bash
# Create all databases
kamal app exec "bundle exec rails db:create"
```

### Running Migrations

```bash
# Run all pending migrations
kamal app exec "bundle exec rails db:migrate"

# Check migration status
kamal app exec "bundle exec rails db:migrate:status"

# Rollback last migration
kamal app exec "bundle exec rails db:rollback"
```

### Seeding Data

```bash
# Seed with demo data
kamal app exec "bundle exec rails db:seed"

# Reset database (drop, create, migrate, seed)
kamal app exec "bundle exec rails db:reset"
```

### Database Console Access

```bash
# Access database console
kamal app exec --interactive --reuse "bundle exec rails dbconsole"
```

## 🔧 Maintenance Operations

### Application Management

```bash
# Restart the application
kamal app restart

# Stop the application
kamal app stop

# Start the application
kamal app start

# View application status
kamal app status
```

### Log Management

```bash
# View application logs
kamal app logs

# Follow logs in real-time
kamal app logs --follow

# View logs from specific container
kamal app exec --reuse "tail -f log/production.log"
```

### Container Management

```bash
# Access Rails console
kamal app exec --interactive --reuse "bundle exec rails console"

# Access shell in container
kamal app exec --interactive --reuse "bash"

# Remove old containers and images
kamal app prune
```

## 🔐 Secrets Management

### Managing Secrets

```bash
# View current secrets
kamal secrets list

# Set a new secret
kamal secrets set NEW_SECRET_KEY "new_value"

# Remove a secret
kamal secrets remove OLD_SECRET_KEY

# Edit secrets file
kamal secrets edit
```

### Updating Secrets

```bash
# Update a secret
kamal secrets set DATABASE_PASSWORD "new_password"

# Redeploy to apply secret changes
kamal deploy
```

## 🛠️ Troubleshooting

### Common Issues

#### Application Won't Start

```bash
# Check application logs
kamal app logs

# Check if database exists
kamal app exec "bundle exec rails db:version"

# Check environment variables
kamal app exec --reuse "env | grep RAILS"
```

#### Database Connection Issues

```bash
# Test database connection
kamal app exec "bundle exec rails db:version"

# Check database configuration
kamal app exec --reuse "cat config/database.yml"

# Test PostgreSQL connection
kamal app exec --reuse "psql $DATABASE_URL -c 'SELECT 1;'"
```

#### Proxy Issues

```bash
# Restart proxy
kamal proxy restart

# Check proxy status
docker ps | grep kamal-proxy

# Check proxy logs
docker logs kamal-proxy
```

### Debugging Commands

```bash
# Check container status
kamal app exec --reuse "ps aux"

# Check memory usage
kamal app exec --reuse "free -h"

# Check disk usage
kamal app exec --reuse "df -h"

# Check network connectivity
kamal app exec --reuse "ping curriculum-library-api.cerveras.com"
```

## 📊 Monitoring

### Health Checks

```bash
# Application health
curl http://cloud.cerveras.com/up

# API health
curl http://cloud.cerveras.com/api/curricula
```

### Performance Monitoring

```bash
# Check memory usage
kamal app exec --reuse "free -h"

# Check CPU usage
kamal app exec --reuse "top -n 1"

# Check disk usage
kamal app exec --reuse "df -h"
```

## 🔄 Rollback Procedures

### Rolling Back Deployment

```bash
# Deploy specific version
kamal deploy --version <previous-commit-hash>

# Or rollback to previous version
kamal rollback
```

### Rolling Back Database

```bash
# Rollback last migration
kamal app exec "bundle exec rails db:rollback"

# Rollback multiple migrations
kamal app exec "bundle exec rails db:rollback STEP=3"
```

## 📝 Deployment Checklist

### Fresh Installation Checklist

- [ ] Kamal setup completed
- [ ] Secrets configured in `.kamal/secrets`
- [ ] Application deployed successfully
- [ ] Databases created
- [ ] Migrations run
- [ ] Seed data loaded (if needed)
- [ ] Health check passes
- [ ] API endpoints responding
- [ ] Logs show no errors

### Update Checklist

- [ ] Changes committed and pushed
- [ ] Application deployed successfully
- [ ] Migrations run (if needed)
- [ ] Health check passes
- [ ] New functionality tested
- [ ] Logs show no errors
- [ ] Old containers cleaned up

## 🚨 Emergency Procedures

### Application Down

```bash
# Check what's wrong
kamal app logs

# Restart application
kamal app restart

# If still down, redeploy
kamal deploy
```

### Database Issues

```bash
# Check database status
kamal app exec "bundle exec rails db:version"

# Restart database accessory
kamal accessory restart db

# Check database logs
docker logs curriculum-library-api-db
```

### Complete Reset

```bash
# Stop everything
kamal app stop
kamal proxy stop

# Start fresh
kamal proxy start
kamal deploy
kamal app exec "bundle exec rails db:create"
kamal app exec "bundle exec rails db:migrate"
kamal app exec "bundle exec rails db:seed"
```

## 📚 Additional Resources

- [Kamal Documentation](https://kamal-deploy.org/)
- [Rails Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## ⚠️ Important Notes

1. **Always backup your database** before major operations
2. **Test in development** before deploying to production
3. **Monitor logs** during and after deployments
4. **Keep secrets secure** and never commit them to version control
5. **Use `--interactive --reuse`** for console access to avoid creating new containers
6. **Check health endpoints** after every deployment
7. **Document any custom procedures** for your specific setup
