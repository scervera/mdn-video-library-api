# Backup System Quick Reference

## 🚀 Quick Commands

### Check Backup Status
```bash
ssh root@cloud.cerveras.com "/root/check_database_status.sh"
```

### Create Manual Backup
```bash
ssh root@cloud.cerveras.com "/root/backup_database.sh"
```

### View Recent Backups
```bash
ssh root@cloud.cerveras.com "ls -la /root/database_backups/"
```

### Download Latest Backup
```bash
scp root@cloud.cerveras.com:/root/database_backups/curriculum_library_api_*.sql.gz ./
```

## 📋 Backup Information

- **Schedule**: Daily at 2:00 AM
- **Location**: `/root/database_backups/`
- **Retention**: 7 days
- **Format**: Compressed SQL dumps (.sql.gz)
- **Log File**: `/root/backup_database.log`

## 🔧 Common Operations

### Monitor Backup Logs
```bash
ssh root@cloud.cerveras.com "tail -f /root/backup_database.log"
```

### Check Backup Directory Size
```bash
ssh root@cloud.cerveras.com "du -sh /root/database_backups/"
```

### Count Backup Files
```bash
ssh root@cloud.cerveras.com "find /root/database_backups/ -name '*.sql.gz' | wc -l"
```

### Check Database Size
```bash
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"SELECT pg_size_pretty(pg_database_size('curriculum_library_api_production'));\""
```

## 🚨 Emergency Procedures

### Restore from Backup
```bash
# 1. Upload backup
scp backup_file.sql.gz root@cloud.cerveras.com:/root/

# 2. Extract and restore
ssh root@cloud.cerveras.com "gunzip /root/backup_file.sql.gz"
ssh root@cloud.cerveras.com "docker exec -i curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production < /root/backup_file.sql"
```

### Test Backup Integrity
```bash
ssh root@cloud.cerveras.com "gunzip -t /root/database_backups/latest_backup.sql.gz"
```

## 📊 Monitoring Commands

### Check Cron Job
```bash
ssh root@cloud.cerveras.com "crontab -l"
```

### Check Disk Space
```bash
ssh root@cloud.cerveras.com "df -h"
```

### Check Database Container
```bash
ssh root@cloud.cerveras.com "docker ps | grep curriculum_library_api-db"
```

## 🔍 Troubleshooting

### Backup Failed
```bash
# Check logs
ssh root@cloud.cerveras.com "tail -20 /root/backup_database.log"

# Check disk space
ssh root@cloud.cerveras.com "df -h"

# Test backup manually
ssh root@cloud.cerveras.com "/root/backup_database.sh"
```

### Database Connection Issues
```bash
# Check container status
ssh root@cloud.cerveras.com "docker ps -a | grep curriculum_library_api-db"

# Check database connectivity
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db pg_isready -U curriculum_library_api"
```

## 📁 File Locations

- **Backup Script**: `/root/backup_database.sh`
- **Status Script**: `/root/check_database_status.sh`
- **Backup Directory**: `/root/database_backups/`
- **Backup Log**: `/root/backup_database.log`
- **Database Data**: `/root/curriculum_library_api-db/data/`

## ⚙️ Configuration

### Cron Schedule
```
0 2 * * * /root/backup_database.sh >> /root/backup_database.log 2>&1
```

### Backup Naming
```
curriculum_library_api_YYYYMMDD_HHMMSS.sql.gz
```

### Database Credentials
- **Database**: `curriculum_library_api_production`
- **User**: `curriculum_library_api`
- **Container**: `curriculum_library_api-db`

## 🛡️ Security

### Set Proper Permissions
```bash
ssh root@cloud.cerveras.com "chmod 700 /root/database_backups"
ssh root@cloud.cerveras.com "chmod 600 /root/database_backups/*.sql.gz"
```

### Verify Backup Integrity
```bash
ssh root@cloud.cerveras.com "gunzip -t /root/database_backups/*.sql.gz"
```

## 📈 Performance

### Monitor Backup Performance
```bash
ssh root@cloud.cerveras.com "time /root/backup_database.sh"
```

### Database Maintenance
```bash
ssh root@cloud.cerveras.com "docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -c \"VACUUM ANALYZE;\""
```

---

**Last Updated**: August 16, 2025  
**Status**: ✅ Fully Operational
