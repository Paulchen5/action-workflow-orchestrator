SHELL		?= /usr/bin/env bash

### Tools
NPM 		?= npm
HADOLINT 	?= hadolint

define MAKEFILE_HELP
Makefile Targets:
	make format			- Format the code using Prettier"
	make help			- Show this help message"
	make lint			- Lint the code using ESLint"
	make test			- Run tests using npm test"

Makefile variables:
	SHELL				- shell to use (default: /usr/bin/env bash)"
	NPM					- npm command (default: npm)"
	HADOLINT			- hadolint command (default: hadolint)"
endef

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

.PHONY: test
test:
	$(NPM) test
