# Downbeat

Time tracking that keeps pace with your work. Built to integrate seamlessly with Asana while maintaining flexibility for any workflow.

## Overview

Downbeat is a Rails API-powered time tracker designed for agencies and consultants who need detailed client billing without the overhead. Track time at the client level for quick logging, or drill down to specific Asana projects and tasks when you need granular detail.

## Features

### Flexible Time Tracking

- **Active timer**: Start/stop with live duration tracking
- **Manual entry**: Log time retroactively with custom start/stop times
- **Forgot to stop**: Special handling for those "oops, left the timer running" moments

### Multi-Level Detail

- **Client-only tracking**: Quick "working for UBS" entries
- **Client + Project**: Add Asana project context for better reporting
- **Client + Project + Task**: Full detail with automatic sync back to Asana tasks

### Smart Reporting

- Monthly breakdowns by client
- Project-level drill-downs
- Hourly rate calculations for invoicing
- Clean separation of detailed vs. general time

### Asana Integration

- OAuth authentication
- Workspace and project sync
- Map Asana projects to your clients
- Write time entries back to Asana tasks as comments
- Smart task caching to minimize API calls

### Client Management

- Custom colors for visual organization
- Logo uploads (via AWS S3)
- Hourly rate tracking
- Active/inactive status

## Tech Stack

- **Backend**: Rails 7+ (API mode)
- **Database**: PostgreSQL
- **Authentication**: Devise + JWT
- **Background Jobs**: Sidekiq
- **File Storage**: AWS S3 (ActiveStorage)
- **External APIs**: Asana API via `asana` gem

## Architecture

Built API-first to support multiple frontends:

- React/Next.js web app (planned)
- macOS menu bar app (planned)
- Mobile apps (future)

All clients hit the same RESTful JSON API with JWT authentication.

## Getting Started

### Prerequisites

- Ruby 3.2+
- PostgreSQL 14+
- Redis 6+
- AWS S3 bucket (for logo uploads)
- Asana Developer App credentials

### Installation

1. **Clone the repo**

```bash
   git clone git@github.com:senatorpetelarson/downbeat.git
   cd downbeat
```

1. **Install dependencies**

```bash
   bundle install
```

1. **Set up environment variables**

```bash
   cp .env.example .env.development
```

   Edit `.env.development` with your credentials:

- Generate JWT secret: `rails secret`
- Create Asana app at <https://app.asana.com/0/my-apps>
- Add AWS S3 credentials

1. **Create and migrate database**

```bash
   rails db:create
   rails db:migrate
```

1. **Start Redis**

```bash
   redis-server
```

1. **Start the server**

```bash
   rails s -p 3001
```

1. **Start Sidekiq** (optional, for Asana sync)

```bash
   bundle exec sidekiq
```

API runs at `http://localhost:3001`

## API Documentation

### Authentication

**Sign up:**

```bash
POST /signup
{
  "user": {
    "email": "you@example.com",
    "password": "password"
  }
}
```

**Login:**

```bash
POST /login
{
  "user": {
    "email": "you@example.com",
    "password": "password"
  }
}
# Returns JWT token in Authorization header
```

**All subsequent requests:**

```bash
Authorization: Bearer <jwt_token>
```

### Core Endpoints

**Clients**

- `GET /api/v1/clients` - List all clients
- `POST /api/v1/clients` - Create client
- `PATCH /api/v1/clients/:id` - Update client
- `DELETE /api/v1/clients/:id` - Delete client

**Time Entries**

- `GET /api/v1/time_entries` - List entries
- `GET /api/v1/time_entries/active` - Get running timer
- `POST /api/v1/time_entries` - Start timer or create manual entry
- `PATCH /api/v1/time_entries/:id` - Update entry (stop timer)
- `POST /api/v1/time_entries/:id/forgot_stop` - Fix forgotten stop time

**Asana Integration**

- `GET /api/v1/asana_workspaces` - List synced workspaces
- `POST /api/v1/asana_workspaces` - Sync workspaces from Asana
- `POST /api/v1/asana_workspaces/:id/sync_projects` - Sync projects
- `PATCH /api/v1/asana_projects/:id/map_to_client` - Map project to client
- `GET /api/v1/asana_projects/:project_id/asana_tasks` - List tasks

**Reports**

- `GET /api/v1/reports/monthly?client_id=X&year=2025&month=2` - Monthly report

See full API documentation in [docs/api.md](docs/api.md) (coming soon).

## Deployment

### Heroku

```bash
# Create app
heroku create downbeat-api

# Add addons
heroku addons:create heroku-postgresql:essential-0
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set ASANA_CLIENT_ID=xxx
heroku config:set ASANA_CLIENT_SECRET=xxx
heroku config:set ASANA_REDIRECT_URI=https://api.mybackbeat.co/auth/asana/callback
heroku config:set DEVISE_JWT_SECRET_KEY=$(rails secret)
heroku config:set AWS_ACCESS_KEY_ID=xxx
heroku config:set AWS_SECRET_ACCESS_KEY=xxx
heroku config:set AWS_REGION=us-east-1
heroku config:set AWS_S3_BUCKET=mydownbeat-production
heroku config:set FRONTEND_URL=https://mybackbeat.co

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
```

## Development Roadmap

- [ ] React/Next.js frontend
- [ ] macOS menu bar app
- [ ] iOS/Android mobile apps
- [ ] Invoice generation from monthly reports
- [ ] Multi-user support (teams)
- [ ] Custom projects (beyond Asana)
- [ ] Zapier/webhook integrations

## Contributing

This is a personal project for Ready Fire Digital, but suggestions and bug reports are welcome! Open an issue or submit a PR.

## License

MIT License - see [LICENSE](LICENSE) for details.

## About

Built by [Pete Larson](https://github.com/senatorpetelarson) at [Ready Fire Digital](https://readyfiredigital.com) - a Denver-based media and web agency.

---

**"Keep tempo on your projects."**
