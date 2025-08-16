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
