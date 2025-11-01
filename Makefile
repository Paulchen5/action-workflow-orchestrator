SHELL			?= /usr/bin/env bash
DOCKER_USERNAME	?= ghcr.io/paulchen5#must be prefixed with the docker registry name
DOCKER_IMAGE	?= $(DOCKER_USERNAME)/action-workflow-orchestrator
VERSION 		?= $(shell cat VERSION)

### Tools
DOCKER			?= docker
HADOLINT 		?= hadolint
NPM 			?= npm

define MAKEFILE_HELP
Makefile Targets:
	make docker-build		- Builds the Docker image
	make format			- Formats the code using Prettier
	make help			- Shows this help message
	make lint			- Lints the code using ESLint
	make docker-push		- Pushes the Docker image to the registry
	make test			- Runs tests using npm test
	make version			- Shows the current version

Makefile variables:
	SHELL				- shell to use (default: /usr/bin/env bash)
	DOCKER_USERNAME			- Docker registry username (default: ghcr.io/paulchen5)
	DOCKER_IMAGE			- Docker image name (default: $$(DOCKER_USERNAME)/action-workflow-orchestrator)
	VERSION				- Version tag for the Docker image

	DOCKER				- docker command (default: docker)
	HADOLINT			- hadolint command (default: hadolint)
	NPM				- npm command (default: npm)
endef

export MAKEFILE_HELP

.PHONY: docker-build
docker-build:
	$(DOCKER) build --build-arg version=$(VERSION) --platform linux/amd64 -t $(DOCKER_IMAGE):$(VERSION) .

.PHONY: format
format:
	$(NPM) run format --silent

.PHONY: help
help:
	@echo "$$MAKEFILE_HELP"

.PHONY: lint
lint:
	$(NPM) run lint --silent
	@if command -v hadolint >/dev/null 2>&1; then \
		$(HADOLINT) Dockerfile; \
	else \
		echo "\033[0;33mwarning\033[0m: hadolint is not installed - skipping Dockerfile linting"; \
	fi \

.PHONY: push
docker-push:
	$(DOCKER) push $(DOCKER_IMAGE):$(VERSION)

.PHONY: test
test:
	$(NPM) test

.PHONY: version
version:
	@echo $(VERSION)
