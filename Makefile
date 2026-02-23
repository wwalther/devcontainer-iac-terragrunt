.PHONY: all
all: build

.PHONY: build
build:
	docker build . --file Dockerfile --tag devcontainer-iac-terragrunt:local $(shell cat Dockerfile.args | xargs -I {} echo --build-arg {})
