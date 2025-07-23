info: header

define header

Makefile for the API.
Usage:
  make help			show this help
  make schema		create the database schema
  make build-image	build the Docker image
  make run-image	run the Docker image


endef
export header

include .env

.PHONY: help
help:
	@echo "$$header"

.PHONY: schema
schema:
	./pg_dump.sh -U $$DB_USERNAME -h $$DB_HOST -d $$DB_DATABASE -s > priv/repo/schema.sql

.PHONY: build-image
build-image:
	source .env.prod && \
	docker build \
		--build-arg DATABASE_URL=$$DATABASE_URL \
		--build-arg SECRET_KEY_BASE=$$SECRET_KEY_BASE \
		--build-arg AUTH_GITHUB_CLIENT_ID=$$AUTH_GITHUB_CLIENT_ID \
		--build-arg AUTH_GITHUB_CLIENT_SECRET=$$AUTH_GITHUB_CLIENT_SECRET \
		--build-arg AUTH_GOOGLE_CLIENT_ID=$$AUTH_GOOGLE_CLIENT_ID \
		--build-arg AUTH_GOOGLE_CLIENT_SECRET=$$AUTH_GOOGLE_CLIENT_SECRET \
		-t ghcr.io/chillybwoy/modern_resume:latest .

.PHONY: run-image
run-image:
	docker run \
		--rm \
		-it \
		--name modern_resume \
		modern_resume

.DEFAULT_GOAL := help
