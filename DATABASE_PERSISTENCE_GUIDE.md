# Database Persistence Guide for Kamal Deployments

This guide explains how database persistence is configured and maintained across deployments in your Rails application.

## Current Persistence Setup

Your application is already configured with proper database persistence across deployments. Here's what's currently set up:

### 1. PostgreSQL Database Persistence

**Configuration in `config/deploy.yml`:**
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
      - data:/var/lib/postgresql/data  # This ensures persistence
```

**What this means:**
- Database data is stored in `/root/curriculum_library_api-db/data/` on the host machine
- This directory persists even when containers are recreated
- Data survives deployments, container restarts, and server reboots

### 2. Redis Persistence

**Configuration in `config/deploy.yml`:**
```yaml
redis:
  image: redis:7.0
  host: cloud.cerveras.com
  port: "127.0.0.1:6379:6379"
  directories:
    - data:/data  # This ensures persistence
```

**What this means:**
- Redis data is stored in `/root/curriculum_library_api-redis/data/` on the host machine
- Session data and cache persist across deployments

### 3. Application Storage Persistence

**Configuration in `config/deploy.yml`:**
```yaml
volumes:
  - "curriculum_library_api_storage:/rails/storage"
```

**What this means:**
- Active Storage files (uploads, etc.) persist across deployments
- Stored in a Docker named volume

## Verifying Persistence

### Check Database Container Status
```bash
# Check if database container is running
ssh root@cloud.cerveras.com "docker ps -a --filter name=curriculum_library_api-db"

# Check database volume mount
ssh root@cloud.cerveras.com "docker inspect curriculum_library_api-db | grep -A 10 -B 5 'Mounts'"

# Check database data directory
ssh root@cloud.cerveras.com "ls -la /root/curriculum_library_api-db/data/"
```

### Check Redis Container Status
```bash
# Check if Redis container is running
ssh root@cloud.cerveras.com "docker ps -a --filter name=curriculum_library_api-redis"

# Check Redis volume mount
ssh root@cloud.cerveras.com "docker inspect curriculum_library_api-redis | grep -A 10 -B 5 'Mounts'"

# Check Redis data directory
ssh root@cloud.cerveras.com "ls -la /root/curriculum_library_api-redis/data/"
```

## Database Backup Strategy

### 1. Automated Backups (Recommended)

Create a backup script on your server:

```bash
#!/bin/bash
# /root/backup_database.sh

BACKUP_DIR="/root/database_backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/curriculum_library_api_$DATE.sql"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create database backup
docker exec curriculum_library_api-db pg_dump -U curriculum_library_api curriculum_library_api_production > $BACKUP_FILE

# Compress the backup
gzip $BACKUP_FILE

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE.gz"
```

### 2. Set Up Automated Backups

Add to crontab:
```bash
# Edit crontab
crontab -e

# Add this line for daily backups at 2 AM
0 2 * * * /root/backup_database.sh
```

### 3. Manual Backup Commands

```bash
# Create a manual backup
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db pg_dump -U curriculum_library_api curriculum_library_api_production > /root/manual_backup_$(date +%Y%m%d_%H%M%S).sql"

# Download backup to local machine
scp root@cloud.cerveras.com:/root/manual_backup_*.sql ./
```

## Database Restoration

### Restore from Backup
```bash
# Upload backup file to server
scp backup_file.sql root@cloud.cerveras.com:/root/

# Restore database
ssh root@cloud.cerveras.com "docker exec -i curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production < /root/backup_file.sql"
```

## Monitoring Database Health

### Check Database Size
```bash
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"SELECT pg_size_pretty(pg_database_size('curriculum_library_api_production'));\""
```

### Check Database Connections
```bash
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"SELECT count(*) FROM pg_stat_activity;\""
```

### Check Database Performance
```bash
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"SELECT schemaname, tablename, attname, n_distinct, correlation FROM pg_stats WHERE schemaname = 'public' ORDER BY n_distinct DESC LIMIT 10;\""
```

## Troubleshooting Persistence Issues

### 1. Database Container Won't Start
```bash
# Check container logs
ssh root@cloud.cerveras.com "docker logs curriculum_library_api-db"

# Check data directory permissions
ssh root@cloud.cerveras.com "ls -la /root/curriculum_library_api-db/data/"

# Fix permissions if needed
ssh root@cloud.cerveras.com "chown -R 999:999 /root/curriculum_library_api-db/data/"
```

### 2. Data Loss After Deployment
```bash
# Check if data directory still exists
ssh root@cloud.cerveras.com "ls -la /root/curriculum_library_api-db/"

# Check container mounts
ssh root@cloud.cerveras.com "docker inspect curriculum_library_api-db | grep -A 5 -B 5 'Mounts'"
```

### 3. Redis Data Loss
```bash
# Check Redis persistence
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-redis redis-cli info persistence"

# Check Redis data directory
ssh root@cloud.cerveras.com "ls -la /root/curriculum_library_api-redis/data/"
```

## Best Practices

### 1. Regular Backups
- Set up automated daily backups
- Test backup restoration procedures
- Store backups in multiple locations

### 2. Monitor Disk Space
```bash
# Check disk usage
ssh root@cloud.cerveras.com "df -h"

# Check database directory size
ssh root@cloud.cerveras.com "du -sh /root/curriculum_library_api-db/data/"
```

### 3. Database Maintenance
```bash
# Run database maintenance (vacuum, analyze)
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"VACUUM ANALYZE;\""
```

### 4. Security
- Database is only accessible from localhost (127.0.0.1)
- Strong passwords are used (stored in `.kamal/secrets`)
- Regular security updates for PostgreSQL

## Migration and Schema Changes

### Running Migrations
```bash
# Run migrations on production
kamal app exec "bundle exec rails db:migrate"

# Check migration status
kamal app exec "bundle exec rails db:migrate:status"
```

### Rollback Migrations
```bash
# Rollback last migration
kamal app exec "bundle exec rails db:rollback"

# Rollback to specific version
kamal app exec "bundle exec rails db:migrate:down VERSION=20231201000000"
```

## Emergency Procedures

### 1. Database Corruption
```bash
# Stop the application
kamal app stop

# Restore from backup
ssh root@cloud.cerveras.com "docker exec -i curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production < /root/latest_backup.sql"

# Restart the application
kamal app start
```

### 2. Server Failure
```bash
# On new server, restore data directories
# Copy /root/curriculum_library_api-db/data/ to new server
# Copy /root/curriculum_library_api-redis/data/ to new server

# Boot accessories
kamal accessory boot db
kamal accessory boot redis

# Deploy application
kamal deploy
```

## Current Status

✅ **Database persistence is properly configured**
✅ **Data directories exist and contain data**
✅ **Containers are running and stable**
✅ **Volume mounts are correctly configured**

Your database will persist across all deployments, container restarts, and server reboots. The data is safely stored in host directories that are independent of the container lifecycle.
