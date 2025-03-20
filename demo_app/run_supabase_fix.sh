#!/bin/bash

# Script to help run SQL fixes on Supabase

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Kidstagram Supabase Fix Utility${NC}"
echo "This script will help fix your Supabase database issues"
echo "Make sure you have the Supabase CLI installed: https://supabase.io/docs/guides/cli"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
  echo -e "${RED}Error: .env file not found!${NC}"
  exit 1
fi

# Extract Supabase URL and key from .env
SUPABASE_URL=$(grep SUPABASE_URL .env | cut -d '=' -f2 | xargs)
SUPABASE_KEY=$(grep SUPABASE_KEY .env | cut -d '=' -f2 | xargs)

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_KEY" ]; then
  echo -e "${RED}Error: Could not find Supabase credentials in .env file${NC}"
  exit 1
fi

echo -e "Found Supabase URL: ${GREEN}$SUPABASE_URL${NC}"

# Check if PSQL is installed
if ! command -v psql &> /dev/null; then
  echo -e "${RED}Error: PostgreSQL client (psql) is not installed!${NC}"
  echo "Please install PostgreSQL: https://www.postgresql.org/download/"
  exit 1
fi

# Prompt for method
echo ""
echo "How would you like to run the fix?"
echo "1) Using Supabase Dashboard (recommended)"
echo "2) Using local psql (requires database credentials)"
echo "3) Exit"

read -p "Choose an option (1-3): " choice

case $choice in
  1)
    echo ""
    echo -e "${YELLOW}Instructions for running via Supabase Dashboard:${NC}"
    echo "1. Log in to your Supabase dashboard: https://app.supabase.io"
    echo "2. Select your project"
    echo "3. Go to the SQL Editor"
    echo "4. Create a new query"
    echo "5. Copy the contents of supabase_fix.sql into the editor"
    echo "6. Click Run to execute the SQL script"
    echo ""
    
    read -p "Press Enter to open the content of supabase_fix.sql..."
    cat supabase_fix.sql
    ;;
    
  2)
    echo ""
    echo -e "${YELLOW}Running fix using local psql...${NC}"
    echo "You'll need to enter your Supabase database credentials."
    
    read -p "Database Host: " DB_HOST
    read -p "Database Name: " DB_NAME
    read -p "Database Port (default: 5432): " DB_PORT
    DB_PORT=${DB_PORT:-5432}
    read -p "Database User: " DB_USER
    read -s -p "Database Password: " DB_PASSWORD
    echo ""
    
    echo "Connecting to database and running fix script..."
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f supabase_fix.sql
    
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Fix script executed successfully!${NC}"
    else
      echo -e "${RED}Error executing fix script. Check the output above for details.${NC}"
    fi
    ;;
    
  3)
    echo "Exiting..."
    exit 0
    ;;
    
  *)
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
    ;;
esac

echo ""
echo -e "${YELLOW}Additional steps you can try:${NC}"
echo "1. After running the fix script, try signing up again in the app"
echo "2. If issues persist, try running the supabase_auth_fix.sql script using the same method"
echo "3. If you're still having problems, check your Supabase logs for specific errors"
echo ""
echo -e "${GREEN}Good luck!${NC}" 