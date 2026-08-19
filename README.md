# BookRead

University final project — a reading/book management platform made up of three parts:

- **[`api/`](./api)** — backend (Node.js / Express)
- **[`web-backoffice/`](./web-backoffice)** — frontend web app (Next.js)
- **[`mobile/`](./mobile)** — mobile app (Flutter)

Each subfolder has its own `README.md` with setup and run instructions specific to that part.

## Getting started

Clone the repo, then set up each part independently:

```bash
git clone <this-repo-url>
cd BookRead

# Backend
cd api && npm install && npm start

# Frontend
cd web-backoffice && npm install && npm run dev

# Mobile
cd mobile && flutter pub get && flutter run
```

## Project structure

```
BookRead/
├── api/              # Backend REST API
├── web-backoffice/   # Admin/backoffice web app (Next.js)
└── mobile/           # Flutter mobile app
```

## License

MIT — see [LICENSE](./LICENSE).
