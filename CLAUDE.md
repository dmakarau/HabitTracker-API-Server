# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HabitTracker API Server is a Swift-based REST API server built with Vapor 4 framework for habit tracking functionality. This is a learning project focused on backend development with Vapor.

## Technology Stack

- **Language**: Swift 6.0+
- **Framework**: Vapor 4.115.0+
- **Platform**: macOS 13+
- **Database**: PostgreSQL (production), SQLite (development)
- **Authentication**: JWT
- **Testing**: Swift Testing framework
- **Deployment**: Docker, Heroku support

## Development Commands

### Building and Running
```bash
# Resolve dependencies
swift package resolve

# Run the server in development mode
swift run HabitTrackerAppServer serve --hostname 0.0.0.0 --port 8080

# Run tests
swift test

# Docker commands
docker compose build
docker compose up app
docker compose down
```

## Architecture

The project follows a standard Vapor application structure:

### Core Files
- `entrypoint.swift` - Application entry point using async/await pattern
- `configure.swift` - Application configuration and middleware setup
- `routes.swift` - Route definitions (currently contains basic hello world routes)

### Current State
- Basic Vapor server setup is complete
- Simple routes implemented for testing
- Test infrastructure in place using Swift Testing framework
- Docker configuration ready for containerized deployment

### Planned Architecture (per README)
- JWT authentication system
- RESTful API endpoints for:
  - User registration/login/logout
  - Categories CRUD
  - Habits CRUD
  - Habit entries and calendar data
- Protected routes with JWT middleware

## Environment Configuration

The application expects a `.env` file with:
- `DATABASE_URL` - Database connection string
- `JWT_SECRET` - JWT signing secret
- `LOG_LEVEL` - Logging level (optional, defaults to debug)

## Development Notes

- Project uses Swift 6.0 with ExistentialAny upcoming feature enabled
- Uses VaporTesting for HTTP endpoint testing
- Currently in early development stage - basic server infrastructure is set up but main API features are not yet implemented
- Code follows standard Vapor conventions and patterns