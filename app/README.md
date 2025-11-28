Simple Node.js app used for the multi-environment DevOps platform.

How to run locally:

```bash
npm install
npm start
```

Environment variables:
- PORT: port to listen on (default 8080)
- ENVIRONMENT: dev | staging | prod

Health endpoint:
GET / -> returns JSON with message and environment
