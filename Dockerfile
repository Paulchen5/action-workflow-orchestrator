FROM node:22-alpine3.21 AS base

ARG version

LABEL org.opencontainers.image.title="GitHub Action Workflow Orchestrator" \
    org.opencontainers.image.description="This actions helps to manage multiple runs of different GitHub Action workflows which should not interfere with other runs." \
    org.opencontainers.image.version=${version} \
    org.opencontainers.image.url="https://github.com/Paulchen5/action-workflow-orchestrator" \
    org.opencontainers.image.licenses="MIT"

ENV NODE_ENV=production

WORKDIR /action
COPY LICENSE README.md package.json ./

FROM base AS dependencies

COPY --from=base /action/package.json ./
COPY package-lock.json ./

RUN npm ci

FROM base AS build

COPY --from=base /action/package.json ./
COPY --from=dependencies /action/node_modules ./node_modules
COPY tsconfig.json ./
COPY src ./src

RUN npm install --global typescript \
    && npm run compile

FROM base AS action

COPY --from=dependencies /action/node_modules ./node_modules
COPY --from=build /action/build ./build

ENTRYPOINT ["node", "build/index.js"]
