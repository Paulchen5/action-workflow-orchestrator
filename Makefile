SHELL			?= /usr/bin/env bash
DOCKER_USERNAME	?= ghcr.io/paulchen5#must be prefixed with the docker registry name
DOCKER_IMAGE	?= $(DOCKER_USERNAME)/action-workflow-orchestrator
VERSION			?= 0.1.0

### Tools
DOCKER			?= docker
HADOLINT 		?= hadolint
NPM 			?= npm

define MAKEFILE_HELP
Makefile Targets:
	make build			- Build the Docker image
	make format			- Format the code using Prettier
	make help			- Show this help message
	make lint			- Lint the code using ESLint
	make push			- Push the Docker image to the registry
	make test			- Run tests using npm test

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

.PHONY: build
build:
	$(DOCKER) build --build-arg version=$(VERSION) -t $(DOCKER_IMAGE):$(VERSION) .
	$(DOCKER) tag $(DOCKER_IMAGE):$(VERSION) $(DOCKER_IMAGE):latest

.PHONY: format
format:
	$(NPM) run format

.PHONY: help
help:
	@echo "$$MAKEFILE_HELP"

.PHONY: lint
lint:
	$(NPM) run lint
	@if command -v hadolint >/dev/null 2>&1; then
		@$(HADOLINT) Dockerfile
	@else
		@echo "\033[0;33mwarning\033[0m: hadolint is not installed - skipping Dockerfile linting"
	@fi

.PHONY: push
push:
	$(DOCKER) push $(DOCKER_IMAGE):$(VERSION)
	$(DOCKER) push $(DOCKER_IMAGE):latest

.PHONY: test
test:
	$(NPM) test
