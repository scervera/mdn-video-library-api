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
