FROM node:22-bookworm-slim

RUN npm install -g @playwright/mcp && \
    npx playwright install --with-deps chromium

ENTRYPOINT ["npx", "@playwright/mcp"]
