#!/bin/bash

# Production Deployment Script
# Run this script to deploy the application to production

set -e

echo "🚀 Starting Plagiarism Detection System Deployment"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker and Docker Compose are installed${NC}"

# Check for .env file
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}Creating backend/.env from backend/.env.example...${NC}"
    cp backend/.env.example backend/.env
    echo -e "${RED}⚠ Please edit backend/.env with your production settings${NC}"
    exit 1
fi

# Build images
echo -e "${YELLOW}Building Docker images...${NC}"
docker-compose build

# Start services
echo -e "${YELLOW}Starting services...${NC}"
docker-compose up -d

# Wait for services to start
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 10

# Check health
echo -e "${YELLOW}Checking service health...${NC}"

if docker-compose exec -T backend curl -f http://localhost:5000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend is healthy${NC}"
else
    echo -e "${RED}✗ Backend health check failed${NC}"
    docker-compose logs backend
    exit 1
fi

# Initialize database
echo -e "${YELLOW}Initializing database...${NC}"
docker-compose exec -T backend npm run seed

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "Services running:"
docker-compose ps
echo ""
echo "Access your application:"
echo "  - Backend API: https://yourdomain.com/api"
echo "  - Frontend: https://yourdomain.com"
echo ""
echo "View logs:"
echo "  - docker-compose logs -f backend"
echo "  - docker-compose logs -f mongodb"
echo "  - docker-compose logs -f redis"
