SHELL	?= /usr/bin/env bash

### Tools
NPM 	?= npm

define MAKEFILE_HELP
Makefile Targets:
	make format			- Format the code using Prettier"
	make help			- Show this help message"
	make lint			- Lint the code using ESLint"
	make test			- Run tests using npm test"

Makefile variables:
	SHELL				- shell to use (default: /usr/bin/env bash)"
	NPM					- npm command (default: npm)"
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

.PHONY: test
test:
	$(NPM) test
