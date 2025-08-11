# Kamal Commands Reference

This document contains helpful Kamal commands for managing your Rails 8 application deployment.

## 🚀 Deployment Commands

### Basic Deployment
```bash
# Deploy the application
kamal deploy

# Deploy with specific version
kamal deploy --version <commit-hash>

# Deploy to specific servers
kamal deploy --servers web
```

### Setup and Configuration
```bash
# Initial setup (run once)
kamal setup

# Access the Rails console
kamal app exec --interactive --reuse "bundle exec rails console"

# Access the database console
kamal app exec --interactive --reuse "bundle exec rails dbconsole"

# Access a shell in the container
kamal app exec --interactive --reuse "bash"
```

## 🗄️ Database Commands

### Database Setup and Management
```bash
# Create all databases (main, cache, queue, cable)
kamal app exec "bundle exec rails db:create"

# Run migrations
kamal app exec "bundle exec rails db:migrate"

# Seed the database with demo data
kamal app exec "bundle exec rails db:seed"

# Reset database (drop, create, migrate, seed)
kamal app exec "bundle exec rails db:reset"

# Check database status
kamal app exec "bundle exec rails db:version"

# Rollback migrations
kamal app exec "bundle exec rails db:rollback"
```

### Database Maintenance
```bash
# Backup database
kamal app exec "bundle exec rails db:backup"

# Restore database from backup
kamal app exec "bundle exec rails db:restore"

# Check for pending migrations
kamal app exec "bundle exec rails db:migrate:status"
```

## 📊 Monitoring and Logs

### Application Logs
```bash
# View application logs
kamal app logs

# Follow logs in real-time
kamal app logs --follow

# View logs from specific container
kamal app exec --reuse "tail -f log/production.log"
```

### Health Checks
```bash
# Check application health
curl http://cloud.cerveras.com/up

# Check application status
kamal app status

# View running containers
kamal app exec --reuse "ps aux"
```

## 🔧 Maintenance Commands

### Container Management
```bash
# Restart the application
kamal app restart

# Stop the application
kamal app stop

# Start the application
kamal app start

# Remove old containers and images
kamal app prune
```

### Proxy Management
```bash
# Start the proxy
kamal proxy start

# Stop the proxy
kamal proxy stop

# Restart the proxy
kamal proxy restart
```

## 🔐 Secrets Management

### Managing Secrets
```bash
# View current secrets
kamal secrets list

# Set a secret
kamal secrets set <key> <value>

# Remove a secret
kamal secrets remove <key>

# Edit secrets file
kamal secrets edit
```

## 🛠️ Troubleshooting Commands

### Debugging
```bash
# Check environment variables
kamal app exec --reuse "env | grep RAILS"

# Check database connection
kamal app exec --reuse "bundle exec rails db:version"

# Check Redis connection
kamal app exec --reuse "redis-cli -h curriculum-library-api.cerveras.com ping"

# Check network connectivity
kamal app exec --reuse "ping curriculum-library-api.cerveras.com"
```

### Performance Monitoring
```bash
# Check memory usage
kamal app exec --reuse "free -h"

# Check disk usage
kamal app exec --reuse "df -h"

# Check running processes
kamal app exec --reuse "ps aux"
```

## 📝 Useful Aliases

You can add these to your shell configuration for convenience:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias kamal-deploy="kamal deploy"
alias kamal-logs="kamal app logs --follow"
alias kamal-console="kamal app exec --interactive --reuse 'bundle exec rails console'"
alias kamal-shell="kamal app exec --interactive --reuse bash"
alias kamal-db="kamal app exec --interactive --reuse 'bundle exec rails dbconsole'"
alias kamal-seed="kamal app exec 'bundle exec rails db:seed'"
alias kamal-migrate="kamal app exec 'bundle exec rails db:migrate'"
```

## 🔄 Common Workflows

### Complete Database Reset
```bash
# Reset everything and seed with demo data
kamal app exec "bundle exec rails db:reset"
```

### Deploy with Database Updates
```bash
# Deploy and run migrations
kamal deploy
kamal app exec "bundle exec rails db:migrate"
```

### Debug Application Issues
```bash
# Check logs and restart if needed
kamal app logs
kamal app restart
```

### Update Secrets
```bash
# Update secrets and redeploy
kamal secrets set NEW_SECRET_KEY "new_value"
kamal deploy
```

## 📚 Additional Resources

- [Kamal Documentation](https://kamal-deploy.org/)
- [Rails Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [Docker Commands Reference](https://docs.docker.com/engine/reference/commandline/cli/)

## ⚠️ Important Notes

1. **Always backup your database** before running destructive commands
2. **Test commands in development** before running in production
3. **Use `--interactive --reuse`** for console access to avoid creating new containers
4. **Monitor logs** during deployments to catch issues early
5. **Keep secrets secure** and never commit them to version control
