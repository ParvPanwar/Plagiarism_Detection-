#!/bin/bash

# Development environment setup script
# Run this to set up a complete development environment locally

set -e

echo "🛠 Setting up Plagiarism Detection System Development Environment"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed${NC}"
    echo "Visit https://nodejs.org/ to install"
    exit 1
fi

NODE_VERSION=$(node -v)
echo -e "${GREEN}✓ Node.js ${NODE_VERSION} installed${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}npm is not installed${NC}"
    exit 1
fi

NPM_VERSION=$(npm -v)
echo -e "${GREEN}✓ npm ${NPM_VERSION} installed${NC}"

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
(cd backend && npm install)

# Create .env file
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp backend/.env.example backend/.env
    echo -e "${YELLOW}Update backend/.env with your local settings${NC}"
fi

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p backend/uploads backend/logs

# Check for MongoDB
echo -e "${YELLOW}Checking MongoDB...${NC}"
if command -v mongod &> /dev/null; then
    # Start MongoDB if on macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! pgrep -q mongod; then
            echo -e "${YELLOW}Starting MongoDB...${NC}"
            brew services start mongodb-community@6.0 2>/dev/null || true
            sleep 2
        fi
        echo -e "${GREEN}✓ MongoDB is running${NC}"
    fi
else
    echo -e "${YELLOW}MongoDB not found. Using Docker instead:${NC}"
    echo "  docker run -d -p 27017:27017 --name mongodb mongo:6.0"
fi

# Check for Redis
echo -e "${YELLOW}Checking Redis...${NC}"
if command -v redis-server &> /dev/null; then
    # Start Redis if on macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! pgrep -q redis-server; then
            echo -e "${YELLOW}Starting Redis...${NC}"
            brew services start redis 2>/dev/null || true
            sleep 1
        fi
        echo -e "${GREEN}✓ Redis is running${NC}"
    fi
else
    echo -e "${YELLOW}Redis not found. Using Docker instead:${NC}"
    echo "  docker run -d -p 6379:6379 --name redis redis:7-alpine"
fi

echo ""
echo -e "${GREEN}✅ Setup completed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Update backend/.env with your settings"
echo "  2. Ensure MongoDB is running on localhost:27017"
echo "  3. Ensure Redis is running on localhost:6379"
echo "  4. Run: cd backend && npm run dev"
echo ""
echo "Available commands:"
echo "  cd backend && npm start     - Start production server"
echo "  cd backend && npm run dev   - Start development server with nodemon"
echo "  cd backend && npm test      - Run tests"
echo "  cd backend && npm run seed  - Populate database with sample data"
