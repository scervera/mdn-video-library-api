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
