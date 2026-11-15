FROM node:24-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json tsconfig.json ./
COPY src ./src
RUN npm ci --ignore-scripts --no-audit --no-fund && npm run build && npm prune --omit=dev
FROM node:24-bookworm-slim
RUN npm install -g supergateway@4.1.0 --no-audit --no-fund && npm cache clean --force
WORKDIR /app
COPY --from=build --chown=1029:100 /app/package.json ./package.json
COPY --from=build --chown=1029:100 /app/node_modules ./node_modules
COPY --from=build --chown=1029:100 /app/dist ./dist
USER 1029:100
ENV NODE_NO_WARNINGS=1
EXPOSE 8000
CMD ["supergateway","--stdio","node /app/dist/index.js","--outputTransport","streamableHttp","--port","8000","--streamableHttpPath","/mcp","--healthEndpoint","/healthz","--logLevel","info"]
