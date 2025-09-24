# HabitTracker API Server

A Swift-based REST API server for habit tracking, built with the Vapor web framework.

## Technology Stack

- **Framework**: Vapor 4 (Swift server-side framework)
- **ORM**: Fluent
- **Authentication**: JWT
- **Databases**:
  - PostgreSQL (production)
  - SQLite (development)
- **Swift Version**: 6.0+
- **Platform**: macOS 13+

## Features

- Secure JWT authentication
- Protected API routes
- User registration and management
- Habit and category CRUD operations
- RESTful API design

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - User logout

### Categories
- `GET /api/categories` - Get all categories
- `POST /api/categories` - Create new category
- `PUT /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category

### Habits
- `GET /api/habits` - Get all habits
- `POST /api/habits` - Create new habit
- `PUT /api/habits/:id` - Update habit
- `DELETE /api/habits/:id` - Delete habit

### Habit Entries
- `POST /api/entries` - Mark habit completion
- `DELETE /api/entries/:id` - Remove habit completion
- `GET /api/entries/calendar/:month` - Get monthly calendar data

## Getting Started

### Prerequisites

- Swift 6.0+ installed on your system
- Xcode (for macOS development)
- Docker (optional, for containerized deployment)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd HabitTracker-API-Server
```

2. Resolve dependencies:
```bash
swift package resolve
```

3. Set up environment variables (create `.env` file):
```bash
DATABASE_URL=your_database_url_here
JWT_SECRET=your_jwt_secret_here
```

### Running the Server

#### Development Mode
```bash
swift run HabitTrackerAppServer serve --hostname 0.0.0.0 --port 8080
```

#### Using Docker
```bash
# Build the image
docker compose build

# Start the server
docker compose up app

# Stop all services
docker compose down
```

### Testing

Run the test suite:
```bash
swift test
```

## Project Structure

```
HabitTracker-API-Server/
├── Package.swift                 # Swift Package Manager configuration
├── Sources/
│   └── HabitTrackerAppServer/
│       ├── entrypoint.swift      # Application entry point
│       ├── configure.swift       # Application configuration
│       ├── routes.swift          # Route definitions
│       └── Controllers/          # API controllers (to be implemented)
├── Tests/
│   └── HabitTrackerAppServerTests/
│       └── HabitTrackerAppServerTests.swift
├── Public/                       # Static files directory
├── Dockerfile                    # Docker configuration
├── docker-compose.yml           # Docker Compose configuration
└── README.md                    # This file
```

## Environment Configuration

Create a `.env` file in the root directory with the following variables:

```bash
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/habittracker_db

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here

# Server Configuration (optional)
LOG_LEVEL=debug
```

## Deployment

### Heroku Deployment

This application is configured for deployment on Heroku with PostgreSQL:

1. Create a new Heroku app
2. Add Heroku Postgres addon
3. Set environment variables in Heroku dashboard
4. Deploy using Git or GitHub integration

### Docker Deployment

The included Dockerfile provides a production-ready container:

```bash
docker build -t habit-tracker-api .
docker run -p 8080:8080 habit-tracker-api
```

## Development Status

This project serves as a learning experience for backend development with Vapor. The current implementation includes basic server setup and routing infrastructure.

## Contributing

This is a learning project. Feel free to explore the code and suggest improvements.

## License

This project is available for educational purposes.