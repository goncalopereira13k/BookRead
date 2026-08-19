# BookRead API

Backend REST API for BookRead, built with Express, Sequelize and PostgreSQL.

## Requirements

- Node.js 18+
- A running PostgreSQL instance

## Setup

Install dependencies:

```bash
npm install
```

Create a `.env` file in this folder with:

```
JWT_SECRET=<a long random string>
DB_PASSWORD=<your postgres password>
```

By default the app connects to a local Postgres instance (`localhost:5432`, user `postgres`, database `postgres`) — adjust `src/configs/db.config.js` if your setup differs.

Run the server:

```bash
npm start
```

The API listens on port `3000` by default (override with the `PORT` env var).

## Tests

```bash
npm test
```

Tests run against an in-memory SQLite database, so no Postgres instance or `.env` file is required to run them.

## Project structure

```
src/
├── configs/       # DB and env configuration
├── controllers/   # Route handlers
├── helpers/       # Input validation helpers
├── middlewares/   # Auth middleware
├── models/        # Sequelize models
├── routes/        # Express route definitions
└── services/      # Auth/token services
```

## Main routes

- `auth` — login, admin login, register
- `user` — user profile and password management
- `book`, `books` — book CRUD and reading-status lists (wanted/reading/read/archived)
- `readinglogs` — reading session logs
- `goal` — daily/yearly reading goals
- `settings` — user notification settings
- `stats` — reading streak and stats
- `logs` — activity logs
