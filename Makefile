info: header

define header

Makefile for the API.
Usage:
  make help			show this help
  make schema		create the database schema
  make dev-up		run the app in development environment
  make dev-down		stop the development environment
  make qa-up		run the app in QA environment
  make qa-down		stop the QA environment

endef
export header

.PHONY: help
help:
	@echo "$$header"

.PHONY: schema
schema:
	source .env && ./pg_dump.sh -U $$DB_USERNAME -h $$DB_HOST -d $$DB_DATABASE -s > priv/repo/schema.sql


.PHONE: dev-up
dev-up:
	docker compose -f docker-compose.dev.yml up --build -d

.PHONE: dev-down
dev-down:
	docker compose -f docker-compose.dev.yml down

.PHONE: qa-up
qa-up:
	docker compose --env-file .env.qa -f docker-compose.qa.yml up --build -d
	@sleep 3
	docker compose --env-file .env.qa -f docker-compose.qa.yml exec app /bin/bash /app/bin/migrate

.PHONE: qa-down
qa-down:
	docker compose -f docker-compose.qa.yml down

.DEFAULT_GOAL := help
