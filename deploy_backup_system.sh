#!/bin/bash
# Backup System Deployment Script for Curriculum Library API
# This script deploys the complete backup system to a new Docker server

# Configuration
BACKUP_DIR="/root/database_backups"
CONTAINER_NAME="curriculum_library_api-db"
DB_NAME="curriculum_library_api_production"
DB_USER="curriculum_library_api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root"
    exit 1
fi

# Check if server hostname is provided
if [ $# -eq 0 ]; then
    error "Usage: $0 <server_hostname> [--skip-kamal-setup]"
    echo
    echo "Options:"
    echo "  <server_hostname>     The hostname or IP of the target server"
    echo "  --skip-kamal-setup    Skip Kamal setup (if already configured)"
    echo
    echo "Examples:"
    echo "  $0 cloud.cerveras.com"
    echo "  $0 192.168.1.100 --skip-kamal-setup"
    exit 1
fi

SERVER_HOSTNAME="$1"
SKIP_KAMAL_SETUP=false

# Check for --skip-kamal-setup flag
if [ "$2" = "--skip-kamal-setup" ]; then
    SKIP_KAMAL_SETUP=true
    warning "Skipping Kamal setup (assuming already configured)"
fi

log "Starting backup system deployment to $SERVER_HOSTNAME..."

# Test SSH connection
log "Testing SSH connection to $SERVER_HOSTNAME..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@"$SERVER_HOSTNAME" "echo 'SSH connection successful'" 2>/dev/null; then
    error "Cannot connect to $SERVER_HOSTNAME via SSH"
    error "Please ensure:"
    error "1. SSH key is configured for passwordless access"
    error "2. Server is accessible"
    error "3. You have root access"
    exit 1
fi

log "SSH connection verified"

# Check if Docker is installed on target server
log "Checking Docker installation on target server..."
if ! ssh root@"$SERVER_HOSTNAME" "docker --version" > /dev/null 2>&1; then
    error "Docker is not installed on $SERVER_HOSTNAME"
    error "Please install Docker first:"
    error "  curl -fsSL https://get.docker.com | sh"
    exit 1
fi

log "Docker is installed on target server"

# Check if Kamal is installed on target server
log "Checking Kamal installation on target server..."
if ! ssh root@"$SERVER_HOSTNAME" "kamal --version" > /dev/null 2>&1; then
    if [ "$SKIP_KAMAL_SETUP" = false ]; then
        error "Kamal is not installed on $SERVER_HOSTNAME"
        error "Please install Kamal first:"
        error "  gem install kamal"
        exit 1
    else
        warning "Kamal not found, but continuing with --skip-kamal-setup flag"
    fi
else
    log "Kamal is installed on target server"
fi

# Create backup scripts on target server
log "Creating backup scripts on target server..."

# Create backup_database.sh
cat > /tmp/backup_database.sh << 'EOF'
#!/bin/bash
# Database Backup Script for Curriculum Library API
# This script creates automated backups of the PostgreSQL database

# Configuration
BACKUP_DIR="/root/database_backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/curriculum_library_api_$DATE.sql"
CONTAINER_NAME="curriculum_library_api-db"
DB_NAME="curriculum_library_api_production"
DB_USER="curriculum_library_api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    error "Docker is not running"
    exit 1
fi

# Check if database container exists
if ! docker ps -a --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    error "Database container '$CONTAINER_NAME' not found"
    exit 1
fi

# Check if database container is running
if ! docker ps --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    error "Database container '$CONTAINER_NAME' is not running"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    log "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Check available disk space (require at least 1GB free)
AVAILABLE_SPACE=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
if [ "$AVAILABLE_SPACE" -lt 1048576 ]; then  # 1GB in KB
    error "Insufficient disk space. Available: $(($AVAILABLE_SPACE / 1024))MB, Required: 1GB"
    exit 1
fi

log "Starting database backup..."

# Create database backup
if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"; then
    log "Database backup created successfully: $BACKUP_FILE"
    
    # Get backup file size
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "Backup size: $BACKUP_SIZE"
    
    # Compress the backup
    log "Compressing backup..."
    if gzip "$BACKUP_FILE"; then
        log "Backup compressed: $BACKUP_FILE.gz"
        
        # Get compressed size
        COMPRESSED_SIZE=$(du -h "$BACKUP_FILE.gz" | cut -f1)
        log "Compressed size: $COMPRESSED_SIZE"
        
        # Verify the backup
        log "Verifying backup integrity..."
        if gunzip -t "$BACKUP_FILE.gz"; then
            log "Backup verification successful"
        else
            error "Backup verification failed"
            rm -f "$BACKUP_FILE.gz"
            exit 1
        fi
    else
        error "Failed to compress backup"
        exit 1
    fi
else
    error "Failed to create database backup"
    exit 1
fi

# Clean up old backups (keep last 7 days)
log "Cleaning up old backups..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

# Count remaining backups
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "*.sql.gz" | wc -l)
log "Remaining backups: $BACKUP_COUNT"

# Show backup directory size
BACKUP_DIR_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
log "Total backup directory size: $BACKUP_DIR_SIZE"

# List recent backups
log "Recent backups:"
find "$BACKUP_DIR" -name "*.sql.gz" -type f -printf "%T@ %p\n" | sort -nr | head -5 | while read timestamp file; do
    filename=$(echo "$file" | sed 's/^[0-9.]* //')
    date=$(date -d "@${timestamp%.*}" '+%Y-%m-%d %H:%M:%S')
    size=$(du -h "$filename" | cut -f1)
    echo "  $date - $filename ($size)"
done

log "Database backup completed successfully!"
EOF

# Create check_database_status.sh
cat > /tmp/check_database_status.sh << 'EOF'
#!/bin/bash
# Database Status Check Script for Curriculum Library API

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Database Persistence Status Check ===${NC}"
echo

# Check if database container is running
echo -e "${BLUE}1. Database Container Status:${NC}"
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "curriculum_library_api-db"; then
    echo -e "${GREEN}✅ Database container is running${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}" | grep "curriculum_library_api-db"
else
    echo -e "${RED}❌ Database container is not running${NC}"
fi
echo

# Check database volume mount
echo -e "${BLUE}2. Database Volume Mount:${NC}"
if docker inspect curriculum_library_api-db | grep -q "/root/curriculum_library_api-db/data"; then
    echo -e "${GREEN}✅ Database volume is properly mounted${NC}"
    echo "   Source: /root/curriculum_library_api-db/data"
    echo "   Destination: /var/lib/postgresql/data"
else
    echo -e "${RED}❌ Database volume mount not found${NC}"
fi
echo

# Check database data directory
echo -e "${BLUE}3. Database Data Directory:${NC}"
if [ -d "/root/curriculum_library_api-db/data" ]; then
    echo -e "${GREEN}✅ Database data directory exists${NC}"
    echo "   Location: /root/curriculum_library_api-db/data"
    echo "   Size: $(du -sh /root/curriculum_library_api-db/data | cut -f1)"
    echo "   Files: $(find /root/curriculum_library_api-db/data -type f | wc -l)"
else
    echo -e "${RED}❌ Database data directory not found${NC}"
fi
echo

# Check database connectivity
echo -e "${BLUE}4. Database Connectivity:${NC}"
if docker exec curriculum_library_api-db pg_isready -U curriculum_library_api > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Database is accepting connections${NC}"
else
    echo -e "${RED}❌ Database is not accepting connections${NC}"
fi
echo

# Check database size
echo -e "${BLUE}5. Database Size:${NC}"
DB_SIZE=$(docker exec curriculum_library_api-db psql -U curriculum_library_api curriculum_library_api_production -t -c "SELECT pg_size_pretty(pg_database_size('curriculum_library_api_production'));" 2>/dev/null | xargs)
if [ -n "$DB_SIZE" ]; then
    echo -e "${GREEN}✅ Database size: $DB_SIZE${NC}"
else
    echo -e "${RED}❌ Could not determine database size${NC}"
fi
echo

# Check recent backups
echo -e "${BLUE}6. Recent Backups:${NC}"
if [ -d "/root/database_backups" ]; then
    BACKUP_COUNT=$(find /root/database_backups -name "*.sql.gz" | wc -l)
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Found $BACKUP_COUNT backup(s)${NC}"
        echo "   Recent backups:"
        find /root/database_backups -name "*.sql.gz" -type f -printf "%T@ %p\n" | sort -nr | head -3 | while read timestamp file; do
            filename=$(echo "$file" | sed 's/^[0-9.]* //')
            date=$(date -d "@${timestamp%.*}" '+%Y-%m-%d %H:%M:%S')
            size=$(du -h "$filename" | cut -f1)
            echo "     $date - $filename ($size)"
        done
    else
        echo -e "${YELLOW}⚠️  No backups found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Backup directory not found${NC}"
fi
echo

# Check disk space
echo -e "${BLUE}7. Disk Space:${NC}"
DISK_USAGE=$(df -h /root | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo -e "${GREEN}✅ Disk usage: ${DISK_USAGE}%${NC}"
else
    echo -e "${YELLOW}⚠️  Disk usage: ${DISK_USAGE}% (consider cleanup)${NC}"
fi
df -h /root | awk 'NR==2 {print "   Available: " $4 " of " $2}'
echo

# Check crontab for automated backups
echo -e "${BLUE}8. Automated Backups:${NC}"
if crontab -l 2>/dev/null | grep -q "backup_database.sh"; then
    echo -e "${GREEN}✅ Automated backups are configured${NC}"
    crontab -l | grep "backup_database.sh"
else
    echo -e "${YELLOW}⚠️  Automated backups not configured${NC}"
fi
echo

echo -e "${BLUE}=== Status Check Complete ===${NC}"
EOF

# Create restore_database.sh
cat > /tmp/restore_database.sh << 'EOF'
#!/bin/bash
# Database Restoration Script for Curriculum Library API
# This script restores the database from a backup file

# Configuration
CONTAINER_NAME="curriculum_library_api-db"
DB_NAME="curriculum_library_api_production"
DB_USER="curriculum_library_api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Check if backup file is provided
if [ $# -eq 0 ]; then
    error "Usage: $0 <backup_file.sql.gz> [--no-stop]"
    echo
    echo "Options:"
    echo "  <backup_file.sql.gz>  Path to the backup file to restore from"
    echo "  --no-stop             Skip stopping the application (use with caution)"
    echo
    echo "Examples:"
    echo "  $0 /root/database_backups/curriculum_library_api_20250816_155503.sql.gz"
    echo "  $0 backup_file.sql.gz --no-stop"
    exit 1
fi

BACKUP_FILE="$1"
SKIP_STOP=false

# Check for --no-stop flag
if [ "$2" = "--no-stop" ]; then
    SKIP_STOP=true
    warning "Application will not be stopped during restoration (use with caution)"
fi

# Validate backup file
if [ ! -f "$BACKUP_FILE" ]; then
    error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Check if file is compressed
if [[ "$BACKUP_FILE" == *.gz ]]; then
    log "Backup file is compressed, will extract during restoration"
    COMPRESSED=true
else
    log "Backup file appears to be uncompressed"
    COMPRESSED=false
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    error "Docker is not running"
    exit 1
fi

# Check if database container exists
if ! docker ps -a --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    error "Database container '$CONTAINER_NAME' not found"
    exit 1
fi

# Check if database container is running
if ! docker ps --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    error "Database container '$CONTAINER_NAME' is not running"
    exit 1
fi

# Check database connectivity
if ! docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" > /dev/null 2>&1; then
    error "Database is not accepting connections"
    exit 1
fi

log "Starting database restoration process..."

# Get current database size for comparison
log "Getting current database size..."
CURRENT_SIZE=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME" -t -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME'));" 2>/dev/null | xargs)
log "Current database size: $CURRENT_SIZE"

# Get current user count for verification
log "Getting current user count..."
CURRENT_USERS=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME" -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | xargs)
log "Current users in database: $CURRENT_USERS"

# Stop application if not skipped
if [ "$SKIP_STOP" = false ]; then
    log "Stopping application..."
    if kamal app stop; then
        log "Application stopped successfully"
    else
        warning "Failed to stop application, continuing anyway"
    fi
else
    log "Skipping application stop (--no-stop flag used)"
fi

# Create backup of current database before restoration
log "Creating backup of current database before restoration..."
PRE_RESTORE_BACKUP="/root/pre_restore_backup_$(date +%Y%m%d_%H%M%S).sql"
if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$PRE_RESTORE_BACKUP"; then
    log "Pre-restoration backup created: $PRE_RESTORE_BACKUP"
else
    warning "Failed to create pre-restoration backup"
fi

# Restore database
log "Restoring database from: $BACKUP_FILE"

if [ "$COMPRESSED" = true ]; then
    # Restore from compressed backup
    if gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME"; then
        log "Database restoration completed successfully"
    else
        error "Database restoration failed"
        if [ "$SKIP_STOP" = false ]; then
            log "Restarting application..."
            kamal app start
        fi
        exit 1
    fi
else
    # Restore from uncompressed backup
    if docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME" < "$BACKUP_FILE"; then
        log "Database restoration completed successfully"
    else
        error "Database restoration failed"
        if [ "$SKIP_STOP" = false ]; then
            log "Restarting application..."
            kamal app start
        fi
        exit 1
    fi
fi

# Verify restoration
log "Verifying restoration..."

# Check new database size
NEW_SIZE=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME" -t -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME'));" 2>/dev/null | xargs)
log "New database size: $NEW_SIZE"

# Check new user count
NEW_USERS=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME" -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | xargs)
log "New users in database: $NEW_USERS"

# Check if restoration changed the database
if [ "$CURRENT_SIZE" != "$NEW_SIZE" ] || [ "$CURRENT_USERS" != "$NEW_USERS" ]; then
    log "Database has been updated:"
    echo "  Size: $CURRENT_SIZE → $NEW_SIZE"
    echo "  Users: $CURRENT_USERS → $NEW_USERS"
else
    warning "Database appears unchanged after restoration"
fi

# Test database connectivity
if docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" > /dev/null 2>&1; then
    log "Database connectivity verified"
else
    error "Database connectivity check failed"
fi

# Start application if it was stopped
if [ "$SKIP_STOP" = false ]; then
    log "Starting application..."
    if kamal app start; then
        log "Application started successfully"
    else
        error "Failed to start application"
        exit 1
    fi
fi

# Clean up pre-restoration backup if restoration was successful
if [ -f "$PRE_RESTORE_BACKUP" ]; then
    log "Cleaning up pre-restoration backup..."
    rm "$PRE_RESTORE_BACKUP"
fi

log "Database restoration process completed successfully!"
echo
echo "Summary:"
echo "  Backup file: $BACKUP_FILE"
echo "  Database size: $NEW_SIZE"
echo "  Users: $NEW_USERS"
echo "  Application status: $(if [ "$SKIP_STOP" = false ]; then echo "Restarted"; else echo "Running"; fi)"
echo
echo "If you encounter any issues, you can restore from the pre-restoration backup:"
echo "  $0 $PRE_RESTORE_BACKUP"
EOF

# Upload scripts to target server
log "Uploading backup scripts to target server..."
scp /tmp/backup_database.sh root@"$SERVER_HOSTNAME":/root/
scp /tmp/check_database_status.sh root@"$SERVER_HOSTNAME":/root/
scp /tmp/restore_database.sh root@"$SERVER_HOSTNAME":/root/

# Make scripts executable on target server
log "Making scripts executable on target server..."
ssh root@"$SERVER_HOSTNAME" "chmod +x /root/backup_database.sh /root/check_database_status.sh /root/restore_database.sh"

# Create backup directory on target server
log "Creating backup directory on target server..."
ssh root@"$SERVER_HOSTNAME" "mkdir -p $BACKUP_DIR"

# Set proper permissions on backup directory
log "Setting proper permissions on backup directory..."
ssh root@"$SERVER_HOSTNAME" "chmod 700 $BACKUP_DIR"

# Set up cron job for automated backups
log "Setting up automated backup cron job..."
ssh root@"$SERVER_HOSTNAME" "crontab -l 2>/dev/null | grep -v 'backup_database.sh' | { cat; echo '0 2 * * * /root/backup_database.sh >> /root/backup_database.log 2>&1'; } | crontab -"

# Test backup script on target server
log "Testing backup script on target server..."
if ssh root@"$SERVER_HOSTNAME" "/root/backup_database.sh" > /dev/null 2>&1; then
    log "Backup script test successful"
else
    warning "Backup script test failed (this is normal if database container is not running yet)"
fi

# Create documentation files on target server
log "Creating documentation on target server..."

# Create quick reference
cat > /tmp/backup_quick_reference.txt << 'EOF'
BACKUP SYSTEM QUICK REFERENCE
============================

Quick Commands:
- Check status: /root/check_database_status.sh
- Create backup: /root/backup_database.sh
- Restore backup: /root/restore_database.sh <backup_file>
- View backups: ls -la /root/database_backups/
- Monitor logs: tail -f /root/backup_database.log

Configuration:
- Backup schedule: Daily at 2:00 AM
- Backup location: /root/database_backups/
- Retention: 7 days
- Log file: /root/backup_database.log

Emergency:
- Restore: /root/restore_database.sh /path/to/backup.sql.gz
- Check status: /root/check_database_status.sh
- View logs: tail -20 /root/backup_database.log
EOF

scp /tmp/backup_quick_reference.txt root@"$SERVER_HOSTNAME":/root/

# Clean up temporary files
rm -f /tmp/backup_database.sh /tmp/check_database_status.sh /tmp/restore_database.sh /tmp/backup_quick_reference.txt

# Verify installation
log "Verifying backup system installation..."
ssh root@"$SERVER_HOSTNAME" "ls -la /root/backup_*.sh"
ssh root@"$SERVER_HOSTNAME" "ls -la $BACKUP_DIR"
ssh root@"$SERVER_HOSTNAME" "crontab -l | grep backup_database"

log "Backup system deployment completed successfully!"
echo
echo "Summary of deployed components:"
echo "  ✅ Backup script: /root/backup_database.sh"
echo "  ✅ Status script: /root/check_database_status.sh"
echo "  ✅ Restore script: /root/restore_database.sh"
echo "  ✅ Backup directory: $BACKUP_DIR"
echo "  ✅ Automated cron job: Daily at 2:00 AM"
echo "  ✅ Quick reference: /root/backup_quick_reference.txt"
echo
echo "Next steps:"
echo "  1. Deploy your Rails application with Kamal"
echo "  2. Test the backup system: ssh root@$SERVER_HOSTNAME '/root/check_database_status.sh'"
echo "  3. Create a test backup: ssh root@$SERVER_HOSTNAME '/root/backup_database.sh'"
echo
echo "Documentation:"
echo "  - Quick reference: /root/backup_quick_reference.txt"
echo "  - Status check: /root/check_database_status.sh"
echo "  - Backup logs: /root/backup_database.log"
