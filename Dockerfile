FROM node:22-trixie-slim AS base

ARG version

LABEL org.opencontainers.image.title="GitHub Action Workflow Orchestrator" \
    org.opencontainers.image.description="This actions helps to manage multiple runs of different GitHub Action workflows which should not interfere with other runs." \
    org.opencontainers.image.version=${version} \
    org.opencontainers.image.url="https://github.com/Paulchen5/action-workflow-orchestrator" \
    org.opencontainers.image.licenses="MIT"

WORKDIR /action
COPY LICENSE README.md package.json ./

FROM base AS dependencies

COPY --from=base /action/package.json ./
COPY package-lock.json ./

RUN npm clean-install --omit=dev

FROM base AS build

COPY --from=base /action/package.json ./
COPY --from=dependencies /action/node_modules ./node_modules
COPY tsconfig.json ./
COPY src ./src

RUN npm install \
    && npm run compile

FROM base AS action

ENV NODE_ENV=production

COPY --from=dependencies /action/node_modules ./node_modules
COPY --from=build /action/build ./build

ENTRYPOINT ["node", "build/index.js"]
