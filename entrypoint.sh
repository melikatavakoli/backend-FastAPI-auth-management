#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}     FastAPI Authentication System - Starting up...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

wait_for_db() {
    echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
    MAX_RETRIES=30
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if python -c "
import psycopg2
import os
try:
    conn = psycopg2.connect(os.environ['DATABASE_URL'])
    conn.close()
    exit(0)
except:
    exit(1)
" 2>/dev/null; then
            echo -e "${GREEN}✅ PostgreSQL is ready!${NC}"
            return 0
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo -e "${YELLOW}⏳ Waiting for PostgreSQL... ($RETRY_COUNT/$MAX_RETRIES)${NC}"
        sleep 2
    done
    
    echo -e "${RED}❌ PostgreSQL is not ready after $MAX_RETRIES attempts${NC}"
    return 1
}

run_migrations() {
    echo -e "${BLUE}📦 Running database migrations...${NC}"
    
    python << EOF
from database import engine, Base
import models
import sys

try:
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("✅ Tables created successfully!")
    
    # نمایش لیست جدول‌های ایجاد شده
    from sqlalchemy import inspect
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    if tables:
        print(f"📊 Tables created: {', '.join(tables)}")
    
except Exception as e:
    print(f"❌ Migration failed: {e}")
    sys.exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Migrations completed successfully!${NC}"
        return 0
    else
        echo -e "${RED}❌ Migrations failed!${NC}"
        return 1
    fi
}

start_app() {
    echo -e "${BLUE}🌟 Starting FastAPI application...${NC}"
    echo -e "${GREEN}📍 API Documentation: http://localhost:8000/docs${NC}"
    echo -e "${GREEN}🔍 ReDoc: http://localhost:8000/redoc${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    exec uvicorn main:app --host 0.0.0.0 --port 8000 --reload
}

main() {
    wait_for_db || exit 1
    run_migrations || exit 1
    start_app
}

main
