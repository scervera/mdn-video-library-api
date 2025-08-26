# Backup Configuration Documentation

This document describes the complete backup configuration for the Curriculum Library API, including automated backups, manual backup procedures, and disaster recovery processes.

## Overview

The backup system ensures that your PostgreSQL database is safely backed up and can be restored in case of data loss, corruption, or disaster recovery scenarios.

## Backup Architecture

### Components
- **Automated Daily Backups**: Scheduled via cron at 2:00 AM daily
- **Manual Backup Script**: Available for on-demand backups
- **Compression**: All backups are compressed using gzip
- **Verification**: Backup integrity is verified after creation
- **Retention Policy**: 7-day retention with automatic cleanup
- **Monitoring**: Status checking and health monitoring

## Automated Backup System

### Configuration

**Backup Script Location**: `/root/backup_database.sh`  
**Cron Schedule**: `0 2 * * *` (Daily at 2:00 AM)  
**Backup Directory**: `/root/database_backups/`  
**Log File**: `/root/backup_database.log`

### Cron Configuration

```bash
# View current cron jobs
crontab -l

# Expected output:
0 2 * * * /root/backup_database.sh >> /root/backup_database.log 2>&1
```

### Backup Script Features

The backup script (`/root/backup_database.sh`) includes:

- **Pre-flight Checks**: Docker status, container availability, disk space
- **Database Dump**: Full PostgreSQL dump using `pg_dump`
- **Compression**: Automatic gzip compression
- **Integrity Verification**: Backup file verification
- **Cleanup**: Automatic removal of backups older than 7 days
- **Logging**: Comprehensive logging with timestamps
- **Error Handling**: Graceful error handling and reporting

## Manual Backup Procedures

### Create Manual Backup

```bash
# SSH to server and run backup
ssh root@cloud.cerveras.com "/root/backup_database.sh"

# Or run with custom output
ssh root@cloud.cerveras.com "/root/backup_database.sh 2>&1 | tee backup_$(date +%Y%m%d_%H%M%S).log"
```

### Download Backup to Local Machine

```bash
# Download latest backup
scp root@cloud.cerveras.com:/root/database_backups/curriculum_library_api_*.sql.gz ./

# Download specific backup
scp root@cloud.cerveras.com:/root/database_backups/curriculum_library_api_20250816_155503.sql.gz ./
```

### Upload Backup to Server

```bash
# Upload backup file to server
scp backup_file.sql.gz root@cloud.cerveras.com:/root/

# Extract and restore
ssh root@cloud.cerveras.com "gunzip /root/backup_file.sql.gz"
```

## Backup File Naming Convention

Backup files follow this naming pattern:
```
curriculum_library_api_YYYYMMDD_HHMMSS.sql.gz
```

**Example**: `curriculum_library_api_20250816_155503.sql.gz`

- **YYYYMMDD**: Date (2025-08-16)
- **HHMMSS**: Time (15:55:03)
- **.sql.gz**: Compressed SQL dump

## Backup Storage and Retention

### Storage Location
- **Server Path**: `/root/database_backups/`
- **File Format**: Compressed SQL dumps (.sql.gz)
- **Permissions**: Readable by root only

### Retention Policy
- **Keep**: Last 7 days of backups
- **Cleanup**: Automatic daily cleanup
- **Manual**: Can be adjusted in backup script

### Storage Monitoring

```bash
# Check backup directory size
ssh root@cloud.cerveras.com "du -sh /root/database_backups/"

# Count backup files
ssh root@cloud.cerveras.com "find /root/database_backups/ -name '*.sql.gz' | wc -l"

# List recent backups
ssh root@cloud.cerveras.com "ls -la /root/database_backups/"
```

## Database Restoration

### Restore from Backup

```bash
# 1. Upload backup file to server
scp backup_file.sql.gz root@cloud.cerveras.com:/root/

# 2. Extract backup file
ssh root@cloud.cerveras.com "gunzip /root/backup_file.sql.gz"

# 3. Stop application (optional, for zero-downtime)
kamal app stop

# 4. Restore database
ssh root@cloud.cerveras.com "docker exec -i curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production < /root/backup_file.sql"

# 5. Restart application
kamal app start
```

### Restore with Verification

```bash
# Create a test restore script
cat > restore_database.sh << 'EOF'
#!/bin/bash
BACKUP_FILE=$1
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file.sql>"
    exit 1
fi

echo "Stopping application..."
kamal app stop

echo "Restoring database from $BACKUP_FILE..."
docker exec -i curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production < $BACKUP_FILE

echo "Verifying restoration..."
USER_COUNT=$(docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -t -c "SELECT COUNT(*) FROM users;" | xargs)
echo "Users in database: $USER_COUNT"

echo "Starting application..."
kamal app start

echo "Restoration complete!"
EOF

chmod +x restore_database.sh
```

## Monitoring and Health Checks

### Status Check Script

Use the status check script to monitor backup health:

```bash
# Run comprehensive status check
ssh root@cloud.cerveras.com "/root/check_database_status.sh"
```

**What it checks:**
- Database container status
- Volume mount configuration
- Data directory existence and size
- Database connectivity
- Database size
- Recent backups
- Disk space
- Automated backup configuration

### Backup Log Monitoring

```bash
# View backup logs
ssh root@cloud.cerveras.com "tail -f /root/backup_database.log"

# Check for backup errors
ssh root@cloud.cerveras.com "grep -i error /root/backup_database.log"

# View recent backup activity
ssh root@cloud.cerveras.com "tail -20 /root/backup_database.log"
```

### Database Size Monitoring

```bash
# Check current database size
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"SELECT pg_size_pretty(pg_database_size('curriculum_library_api_production'));\""

# Monitor size growth over time
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;\""
```

## Disaster Recovery Procedures

### Complete Server Failure

If the entire server fails, follow these steps:

1. **Provision New Server**
   - Set up new server with same specifications
   - Install Docker and Kamal
   - Configure SSH access

2. **Restore Data Directories**
   ```bash
   # Copy database data directory to new server
   scp -r /root/curriculum_library_api-db/ new-server:/root/
   scp -r /root/curriculum_library_api-redis/ new-server:/root/
   ```

3. **Restore from Backup (Alternative)**
   ```bash
   # Upload latest backup to new server
   scp backup_file.sql.gz new-server:/root/
   
   # Boot accessories and restore
   kamal accessory boot db
   kamal accessory boot redis
   gunzip /root/backup_file.sql.gz
   docker exec -i curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production < /root/backup_file.sql
   ```

4. **Deploy Application**
   ```bash
   kamal deploy
   ```

### Database Corruption

If database corruption is detected:

1. **Stop Application**
   ```bash
   kamal app stop
   ```

2. **Identify Latest Good Backup**
   ```bash
   ls -la /root/database_backups/
   ```

3. **Restore from Backup**
   ```bash
   gunzip /root/database_backups/curriculum_library_api_YYYYMMDD_HHMMSS.sql.gz
   docker exec -i curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production < /root/database_backups/curriculum_library_api_YYYYMMDD_HHMMSS.sql
   ```

4. **Verify Restoration**
   ```bash
   docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c "SELECT COUNT(*) FROM users;"
   ```

5. **Restart Application**
   ```bash
   kamal app start
   ```

## Backup Testing and Validation

### Test Backup Integrity

```bash
# Test backup file integrity
ssh root@cloud.cerveras.com "gunzip -t /root/database_backups/latest_backup.sql.gz"

# Test backup restoration to temporary database
ssh root@cloud.cerveras.com "docker exec -i curriculum_library_api-db createdb -U curriculum_library_api test_restore"
ssh root@cloud.cerveras.com "gunzip -c /root/database_backups/latest_backup.sql.gz | docker exec -i curriculum_library_api-db psql -U curriculum_library_api test_restore"
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api test_restore -c 'SELECT COUNT(*) FROM users;'"
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db dropdb -U curriculum_library_api test_restore"
```

### Backup Performance Testing

```bash
# Test backup creation time
time ssh root@cloud.cerveras.com "/root/backup_database.sh"

# Test backup size
ssh root@cloud.cerveras.com "ls -lh /root/database_backups/latest_backup.sql.gz"
```

## Security Considerations

### Backup File Security
- Backup files are stored with root-only permissions
- Files are compressed to reduce storage requirements
- Backup directory is not publicly accessible

### Access Control
```bash
# Set proper permissions on backup directory
ssh root@cloud.cerveras.com "chmod 700 /root/database_backups"
ssh root@cloud.cerveras.com "chmod 600 /root/database_backups/*.sql.gz"
```

### Encryption (Optional Enhancement)
For additional security, consider encrypting backups:

```bash
# Encrypt backup with GPG
gpg --encrypt --recipient your-email@example.com backup_file.sql.gz

# Decrypt backup
gpg --decrypt backup_file.sql.gz.gpg > backup_file.sql.gz
```

## Troubleshooting

### Common Issues

1. **Backup Fails - Insufficient Disk Space**
   ```bash
   # Check disk space
   df -h
   
   # Clean up old backups
   find /root/database_backups/ -name "*.sql.gz" -mtime +7 -delete
   ```

2. **Backup Fails - Database Connection**
   ```bash
   # Check database container status
   docker ps | grep curriculum_library_api-db
   
   # Check database connectivity
   docker exec curriculum_library_api-db pg_isready -U curriculum_library_api
   ```

3. **Cron Job Not Running**
   ```bash
   # Check cron service
   systemctl status cron
   
   # Check cron logs
   tail -f /var/log/cron
   
   # Test cron job manually
   /root/backup_database.sh
   ```

### Backup Script Debugging

```bash
# Run backup script with verbose output
ssh root@cloud.cerveras.com "bash -x /root/backup_database.sh"

# Check backup script syntax
ssh root@cloud.cerveras.com "bash -n /root/backup_database.sh"
```

## Maintenance Tasks

### Regular Maintenance Schedule

**Daily**
- Monitor backup logs for errors
- Verify backup file creation

**Weekly**
- Test backup restoration procedure
- Review backup file sizes and growth
- Check disk space usage

**Monthly**
- Review and update backup retention policy
- Test disaster recovery procedures
- Update backup scripts if needed

### Performance Optimization

```bash
# Optimize PostgreSQL for backup performance
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"VACUUM ANALYZE;\""

# Monitor backup performance
ssh root@cloud.cerveras.com "time /root/backup_database.sh"
```

## Current Backup Status

✅ **Automated Backups**: Configured and running  
✅ **Backup Script**: Installed and tested  
✅ **Monitoring**: Status check script available  
✅ **Retention Policy**: 7-day retention active  
✅ **Logging**: Comprehensive logging enabled  
✅ **Verification**: Backup integrity checking active  

Your backup system is fully operational and provides comprehensive protection for your database data.
