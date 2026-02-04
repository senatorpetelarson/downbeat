# Downbeat API Documentation

Version: 1.0  
Base URL: `http://localhost:3001` (development) | `https://api.mybackbeat.co` (production)

All endpoints return JSON and require authentication unless otherwise noted.

## Table of Contents

- [Authentication](#authentication)
- [Clients](#clients)
- [Time Entries](#time-entries)
- [Asana Integration](#asana-integration)
- [Reports](#reports)
- [Error Handling](#error-handling)

---

## Authentication

Downbeat uses JWT (JSON Web Tokens) for authentication via Devise.

### Sign Up

Create a new user account.

**Endpoint:** `POST /signup`

**Request:**

```json
{
  "user": {
    "email": "pete@readyfiredigital.com",
    "password": "securepassword123"
  }
}
```

**Response:** `200 OK`

```json
{
  "user": {
    "id": 1,
    "email": "pete@readyfiredigital.com",
    "created_at": "2025-02-04T10:00:00.000Z"
  }
}
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

---

### Login

Authenticate and receive a JWT token.

**Endpoint:** `POST /login`

**Request:**

```json
{
  "user": {
    "email": "pete@readyfiredigital.com",
    "password": "securepassword123"
  }
}
```

**Response:** `200 OK`

```json
{
  "user": {
    "id": 1,
    "email": "pete@readyfiredigital.com"
  }
}
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Note:** Copy the `Authorization` header value and include it in all subsequent requests.

---

### Logout

Revoke the current JWT token.

**Endpoint:** `DELETE /logout`

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response:** `200 OK`

---

### Using Your Token

Include the JWT token in the `Authorization` header for all protected endpoints:

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     https://api.mybackbeat.co/api/v1/clients
```

---

## Clients

Manage billable clients and their settings.

### List All Clients

**Endpoint:** `GET /api/v1/clients`

**Response:** `200 OK`

```json
[
  {
    "id": 1,
    "name": "UBS Highlands Wealth Management",
    "color": "#1E40AF",
    "hourly_rate": "150.00",
    "active": true,
    "logo_url": "https://mydownbeat-production.s3.amazonaws.com/...",
    "created_at": "2025-01-15T10:00:00.000Z",
    "updated_at": "2025-02-01T14:30:00.000Z"
  },
  {
    "id": 2,
    "name": "Southern Education Foundation",
    "color": "#DC2626",
    "hourly_rate": "125.00",
    "active": true,
    "logo_url": null,
    "created_at": "2025-01-20T11:00:00.000Z",
    "updated_at": "2025-01-20T11:00:00.000Z"
  }
]
```

---

### Get Single Client

**Endpoint:** `GET /api/v1/clients/:id`

**Response:** `200 OK`

```json
{
  "id": 1,
  "name": "UBS Highlands Wealth Management",
  "color": "#1E40AF",
  "hourly_rate": "150.00",
  "active": true,
  "logo_url": "https://mydownbeat-production.s3.amazonaws.com/...",
  "created_at": "2025-01-15T10:00:00.000Z",
  "updated_at": "2025-02-01T14:30:00.000Z"
}
```

---

### Create Client

**Endpoint:** `POST /api/v1/clients`

**Request (JSON):**

```json
{
  "client": {
    "name": "Harvest Ridge Church",
    "color": "#10B981",
    "hourly_rate": "75.00",
    "active": true
  }
}
```

**Request (Form Data with Logo):**

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "client[name]=Harvest Ridge Church" \
  -F "client[color]=#10B981" \
  -F "client[hourly_rate]=75.00" \
  -F "client[active]=true" \
  -F "client[logo]=@/path/to/logo.png" \
  https://api.mybackbeat.co/api/v1/clients
```

**Response:** `201 Created`

```json
{
  "id": 3,
  "name": "Harvest Ridge Church",
  "color": "#10B981",
  "hourly_rate": "75.00",
  "active": true,
  "logo_url": "https://mydownbeat-production.s3.amazonaws.com/...",
  "created_at": "2025-02-04T10:00:00.000Z",
  "updated_at": "2025-02-04T10:00:00.000Z"
}
```

**Field Validations:**

- `name`: Required
- `color`: Must be valid hex color (e.g., `#3B82F6`)
- `hourly_rate`: Optional, decimal
- `active`: Boolean, defaults to `true`
- `logo`: Optional image file (PNG, JPG, GIF)

---

### Update Client

**Endpoint:** `PATCH /api/v1/clients/:id`

**Request:**

```json
{
  "client": {
    "name": "UBS Highlands Team",
    "hourly_rate": "175.00"
  }
}
```

**Response:** `200 OK`

```json
{
  "id": 1,
  "name": "UBS Highlands Team",
  "color": "#1E40AF",
  "hourly_rate": "175.00",
  "active": true,
  "logo_url": "https://mydownbeat-production.s3.amazonaws.com/...",
  "created_at": "2025-01-15T10:00:00.000Z",
  "updated_at": "2025-02-04T10:15:00.000Z"
}
```

---

### Delete Client

**Endpoint:** `DELETE /api/v1/clients/:id`

**Response:** `204 No Content`

**Note:** This will also delete all time entries associated with this client. Use with caution.

---

### Remove Client Logo

**Endpoint:** `DELETE /api/v1/clients/:id/remove_logo`

**Response:** `200 OK`

```json
{
  "id": 1,
  "name": "UBS Highlands Team",
  "color": "#1E40AF",
  "hourly_rate": "175.00",
  "active": true,
  "logo_url": null,
  "created_at": "2025-01-15T10:00:00.000Z",
  "updated_at": "2025-02-04T10:20:00.000Z"
}
```

---

## Time Entries

Track time with active timers or manual entries.

### List Time Entries

**Endpoint:** `GET /api/v1/time_entries`

**Query Parameters:**

- `client_id` (optional): Filter by client
- `start_date` (optional): ISO 8601 date, filter entries after this date
- `end_date` (optional): ISO 8601 date, filter entries before this date

**Examples:**

```
GET /api/v1/time_entries
GET /api/v1/time_entries?client_id=1
GET /api/v1/time_entries?start_date=2025-02-01&end_date=2025-02-29
```

**Response:** `200 OK`

```json
[
  {
    "id": 1,
    "client": {
      "id": 1,
      "name": "UBS Highlands Wealth Management",
      "color": "#1E40AF"
    },
    "asana_project": {
      "id": 5,
      "name": "Website Redesign"
    },
    "asana_task": {
      "id": 12,
      "name": "Homepage Hero Component"
    },
    "started_at": "2025-02-04T09:00:00.000Z",
    "stopped_at": "2025-02-04T11:30:00.000Z",
    "duration_seconds": 9000,
    "duration_hours": 2.5,
    "notes": "Built out responsive hero section with video background",
    "running": false,
    "synced_to_asana": true,
    "created_at": "2025-02-04T09:00:00.000Z",
    "updated_at": "2025-02-04T11:30:00.000Z"
  },
  {
    "id": 2,
    "client": {
      "id": 1,
      "name": "UBS Highlands Wealth Management",
      "color": "#1E40AF"
    },
    "asana_project": null,
    "asana_task": null,
    "started_at": "2025-02-04T13:00:00.000Z",
    "stopped_at": null,
    "duration_seconds": 0,
    "duration_hours": 0.0,
    "notes": "General client work",
    "running": true,
    "synced_to_asana": false,
    "created_at": "2025-02-04T13:00:00.000Z",
    "updated_at": "2025-02-04T13:00:00.000Z"
  }
]
```

---

### Get Active Timer

Check if a timer is currently running.

**Endpoint:** `GET /api/v1/time_entries/active`

**Response (timer running):** `200 OK`

```json
{
  "id": 2,
  "client": {
    "id": 1,
    "name": "UBS Highlands Wealth Management",
    "color": "#1E40AF"
  },
  "asana_project": null,
  "asana_task": null,
  "started_at": "2025-02-04T13:00:00.000Z",
  "stopped_at": null,
  "duration_seconds": 0,
  "duration_hours": 0.0,
  "notes": "General client work",
  "running": true,
  "synced_to_asana": false,
  "created_at": "2025-02-04T13:00:00.000Z",
  "updated_at": "2025-02-04T13:00:00.000Z"
}
```

**Response (no timer running):** `200 OK`

```json
{
  "active": false
}
```

---

### Start Timer

Create a new time entry with no stop time (timer starts running).

**Endpoint:** `POST /api/v1/time_entries`

**Request (Client only - quick tracking):**

```json
{
  "time_entry": {
    "client_id": 1,
    "notes": "General client work"
  }
}
```

**Request (Client + Project):**

```json
{
  "time_entry": {
    "client_id": 1,
    "asana_project_id": 5,
    "notes": "Working on website redesign"
  }
}
```

**Request (Client + Project + Task - full detail):**

```json
{
  "time_entry": {
    "client_id": 1,
    "asana_project_id": 5,
    "asana_task_id": 12,
    "notes": "Homepage hero component development"
  }
}
```

**Response:** `201 Created`

```json
{
  "id": 3,
  "client": {
    "id": 1,
    "name": "UBS Highlands Wealth Management",
    "color": "#1E40AF"
  },
  "asana_project": {
    "id": 5,
    "name": "Website Redesign"
  },
  "asana_task": {
    "id": 12,
    "name": "Homepage Hero Component"
  },
  "started_at": "2025-02-04T14:00:00.000Z",
  "stopped_at": null,
  "duration_seconds": 0,
  "duration_hours": 0.0,
  "notes": "Homepage hero component development",
  "running": true,
  "synced_to_asana": false,
  "created_at": "2025-02-04T14:00:00.000Z",
  "updated_at": "2025-02-04T14:00:00.000Z"
}
```

---

### Manual Time Entry

Create a completed time entry with both start and stop times.

**Endpoint:** `POST /api/v1/time_entries`

**Request:**

```json
{
  "time_entry": {
    "client_id": 2,
    "asana_project_id": 8,
    "started_at": "2025-02-03T10:00:00Z",
    "stopped_at": "2025-02-03T12:30:00Z",
    "notes": "Homepage development - retrospective entry"
  }
}
```

**Response:** `201 Created`

```json
{
  "id": 4,
  "client": {
    "id": 2,
    "name": "Southern Education Foundation",
    "color": "#DC2626"
  },
  "asana_project": {
    "id": 8,
    "name": "SEF Website"
  },
  "asana_task": null,
  "started_at": "2025-02-03T10:00:00.000Z",
  "stopped_at": "2025-02-03T12:30:00.000Z",
  "duration_seconds": 9000,
  "duration_hours": 2.5,
  "notes": "Homepage development - retrospective entry",
  "running": false,
  "synced_to_asana": false,
  "created_at": "2025-02-04T14:15:00.000Z",
  "updated_at": "2025-02-04T14:15:00.000Z"
}
```

---

### Stop Timer

Update a running time entry with a stop time.

**Endpoint:** `PATCH /api/v1/time_entries/:id`

**Request:**

```json
{
  "time_entry": {
    "stopped_at": "2025-02-04T16:00:00Z"
  }
}
```

**Response:** `200 OK`

```json
{
  "id": 3,
  "client": {
    "id": 1,
    "name": "UBS Highlands Wealth Management",
    "color": "#1E40AF"
  },
  "asana_project": {
    "id": 5,
    "name": "Website Redesign"
  },
  "asana_task": {
    "id": 12,
    "name": "Homepage Hero Component"
  },
  "started_at": "2025-02-04T14:00:00.000Z",
  "stopped_at": "2025-02-04T16:00:00.000Z",
  "duration_seconds": 7200,
  "duration_hours": 2.0,
  "notes": "Homepage hero component development",
  "running": false,
  "synced_to_asana": true,
  "created_at": "2025-02-04T14:00:00.000Z",
  "updated_at": "2025-02-04T16:00:00.000Z"
}
```

**Note:** If `asana_task_id` is present, this will trigger a background job to sync the time entry to Asana.

---

### Forgot to Stop Timer

Special endpoint to handle "forgot to stop" scenarios.

**Endpoint:** `POST /api/v1/time_entries/:id/forgot_stop`

**Request:**

```json
{
  "stopped_at": "2025-02-04T15:30:00Z"
}
```

**Request (no body - uses current time):**

```json
{}
```

**Response:** `200 OK`

```json
{
  "id": 3,
  "client": {
    "id": 1,
    "name": "UBS Highlands Wealth Management",
    "color": "#1E40AF"
  },
  "started_at": "2025-02-04T14:00:00.000Z",
  "stopped_at": "2025-02-04T15:30:00.000Z",
  "duration_seconds": 5400,
  "duration_hours": 1.5,
  "running": false,
  ...
}
```

---

### Update Time Entry

Modify any field of an existing time entry.

**Endpoint:** `PATCH /api/v1/time_entries/:id`

**Request:**

```json
{
  "time_entry": {
    "notes": "Updated notes with more detail",
    "started_at": "2025-02-04T14:15:00Z"
  }
}
```

**Response:** `200 OK`

```json
{
  "id": 3,
  "notes": "Updated notes with more detail",
  "started_at": "2025-02-04T14:15:00.000Z",
  ...
}
```

---

### Delete Time Entry

**Endpoint:** `DELETE /api/v1/time_entries/:id`

**Response:** `204 No Content`

---

## Asana Integration

Connect your Asana workspace and sync projects/tasks.

### OAuth Flow

1. **Redirect user to Asana authorization:**

```
   https://app.asana.com/-/oauth_authorize?client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&response_type=code&state=OPTIONAL_STATE
```

1. **User authorizes and gets redirected to:**

```
   GET /auth/asana/callback?code=AUTHORIZATION_CODE
```

1. **Backend exchanges code for token** (automatic)

2. **User is redirected to frontend:**

```
   https://mybackbeat.co/asana/connected (success)
   https://mybackbeat.co/asana/error (failure)
```

After OAuth, the user's Asana access token is stored and used for all subsequent Asana API calls.

---

### List Workspaces

Get all synced Asana workspaces.

**Endpoint:** `GET /api/v1/asana_workspaces`

**Response:** `200 OK`

```json
[
  {
    "id": 1,
    "workspace_gid": "1234567890",
    "name": "Ready Fire Digital",
    "projects_count": 12,
    "created_at": "2025-02-01T10:00:00.000Z"
  }
]
```

---

### Sync Workspaces from Asana

Fetch and save all workspaces from Asana.

**Endpoint:** `POST /api/v1/asana_workspaces`

**Response:** `200 OK`

```json
[
  {
    "id": 1,
    "workspace_gid": "1234567890",
    "name": "Ready Fire Digital",
    "projects_count": 12,
    "created_at": "2025-02-01T10:00:00.000Z"
  }
]
```

**Error Response (token expired):** `401 Unauthorized`

```json
{
  "error": "Asana token invalid or expired"
}
```

---

### Sync Projects from Workspace

Fetch all projects from a specific workspace.

**Endpoint:** `POST /api/v1/asana_workspaces/:id/sync_projects`

**Response:** `200 OK`

```json
{
  "id": 1,
  "workspace_gid": "1234567890",
  "name": "Ready Fire Digital",
  "projects_count": 12,
  "created_at": "2025-02-01T10:00:00.000Z"
}
```

---

### List Asana Projects

Get all synced Asana projects, optionally filtered by workspace.

**Endpoint:** `GET /api/v1/asana_projects`

**Query Parameters:**

- `workspace_id` (optional): Filter by workspace

**Response:** `200 OK`

```json
[
  {
    "id": 5,
    "project_gid": "9876543210",
    "name": "UBS Website Redesign",
    "workspace_id": 1,
    "client": {
      "id": 1,
      "name": "UBS Highlands Wealth Management",
      "color": "#1E40AF"
    },
    "created_at": "2025-02-01T10:30:00.000Z"
  },
  {
    "id": 6,
    "project_gid": "9876543211",
    "name": "Internal Marketing",
    "workspace_id": 1,
    "client": null,
    "created_at": "2025-02-01T10:30:00.000Z"
  }
]
```

---

### Map Project to Client

Associate an Asana project with a Downbeat client.

**Endpoint:** `PATCH /api/v1/asana_projects/:id/map_to_client`

**Request (map to client):**

```json
{
  "client_id": 1
}
```

**Request (unmap from client):**

```json
{
  "client_id": null
}
```

**Response:** `200 OK`

```json
{
  "id": 5,
  "project_gid": "9876543210",
  "name": "UBS Website Redesign",
  "workspace_id": 1,
  "client": {
    "id": 1,
    "name": "UBS Highlands Wealth Management",
    "color": "#1E40AF"
  },
  "created_at": "2025-02-01T10:30:00.000Z"
}
```

---

### List Tasks for Project

Get all tasks for an Asana project. Automatically syncs from Asana if cache is stale.

**Endpoint:** `GET /api/v1/asana_projects/:asana_project_id/asana_tasks`

**Response:** `200 OK`

```json
[
  {
    "id": 12,
    "task_gid": "11111111111",
    "name": "Homepage Hero Component",
    "project_id": 5,
    "cached_at": "2025-02-04T10:00:00.000Z"
  },
  {
    "id": 13,
    "task_gid": "11111111112",
    "name": "Contact Form Integration",
    "project_id": 5,
    "cached_at": "2025-02-04T10:00:00.000Z"
  }
]
```

**Note:** Tasks are cached for 1 hour. The endpoint will auto-refresh if stale.

---

## Reports

Generate time tracking reports for billing and analysis.

### Monthly Report

Get time breakdown by client for a specific month.

**Endpoint:** `GET /api/v1/reports/monthly`

**Query Parameters:**

- `client_id` (optional): Get detailed report for specific client
- `year` (optional): Default is current year
- `month` (optional): Default is current month (1-12)

---

### All Clients Summary

**Request:**

```
GET /api/v1/reports/monthly?year=2025&month=2
```

**Response:** `200 OK`

```json
{
  "month": "February 2025",
  "total_hours": 127.5,
  "by_client": [
    {
      "client": {
        "id": 1,
        "name": "UBS Highlands Wealth Management",
        "color": "#1E40AF"
      },
      "total_hours": 87.5,
      "total_amount": "13125.00"
    },
    {
      "client": {
        "id": 2,
        "name": "Southern Education Foundation",
        "color": "#DC2626"
      },
      "total_hours": 32.0,
      "total_amount": "4000.00"
    },
    {
      "client": {
        "id": 3,
        "name": "Harvest Ridge Church",
        "color": "#10B981"
      },
      "total_hours": 8.0,
      "total_amount": "600.00"
    }
  ]
}
```

---

### Single Client Detailed Report

**Request:**

```
GET /api/v1/reports/monthly?client_id=1&year=2025&month=2
```

**Response:** `200 OK`

```json
{
  "client": {
    "id": 1,
    "name": "UBS Highlands Wealth Management",
    "color": "#1E40AF"
  },
  "month": "February 2025",
  "total_hours": 87.5,
  "hourly_rate": "150.00",
  "total_amount": "13125.00",
  "by_project": [
    {
      "project": {
        "id": 5,
        "name": "Website Redesign"
      },
      "total_hours": 72.5,
      "entries": [
        {
          "id": 1,
          "started_at": "2025-02-04T09:00:00.000Z",
          "duration_hours": 2.5,
          "task": "Homepage Hero Component",
          "notes": "Built out responsive hero section"
        },
        {
          "id": 2,
          "started_at": "2025-02-05T10:00:00.000Z",
          "duration_hours": 4.0,
          "task": "Contact Form Integration",
          "notes": "Integrated with Salesforce"
        }
      ]
    },
    {
      "project": {
        "name": "Unspecified"
      },
      "total_hours": 15.0,
      "entries": [
        {
          "id": 3,
          "started_at": "2025-02-06T14:00:00.000Z",
          "duration_hours": 3.0,
          "task": null,
          "notes": "General client work"
        }
      ]
    }
  ]
}
```

---

## Error Handling

All endpoints return appropriate HTTP status codes and error messages in JSON format.

### Success Codes

- `200 OK` - Request succeeded
- `201 Created` - Resource created successfully
- `204 No Content` - Request succeeded (no response body)

### Client Error Codes

- `400 Bad Request` - Invalid request format or parameters
- `401 Unauthorized` - Missing or invalid authentication token
- `404 Not Found` - Resource doesn't exist
- `422 Unprocessable Entity` - Validation errors

### Error Response Format

```json
{
  "errors": [
    "Name can't be blank",
    "Color must be a valid hex code"
  ]
}
```

Or for single errors:

```json
{
  "error": "Asana token invalid or expired"
}
```

### Common Validation Errors

**Client:**

- Name is required
- Color must be hex format (#RRGGBB)
- Hourly rate must be a positive number

**Time Entry:**

- Client is required
- Started at is required
- Stopped at must be after started at
- Cannot have multiple active timers simultaneously

**Asana:**

- Asana token expired (re-authenticate via OAuth)
- Project not found in workspace
- Task not found in project

---

## Rate Limiting

Currently no rate limiting is enforced, but consider these best practices:

- Don't poll `/api/v1/time_entries/active` more than once per second
- Task lists are cached for 1 hour - avoid excessive refreshes
- Asana API has its own rate limits (check Asana docs)

---

## Pagination

Currently not implemented. All list endpoints return all records. Future versions will include:

```
GET /api/v1/time_entries?page=1&per_page=50
```

---

## Webhooks (Future)

Planned webhook support for:

- Time entry created
- Time entry stopped
- Monthly report generated
- Asana sync completed

---

## Support

For questions or issues:

- GitHub Issues: <https://github.com/senatorpetelarson/downbeat/issues>
- Email: <pete@readyfiredigital.com>

---

**Last Updated:** February 4, 2025  
**API Version:** 1.0
