info: header

define header

Makefile for the API.
Usage:
  make help			show this help
  make schema		create the database schema
  make qa-up		run the app in QA environment
  make qa-down		stop the QA environment

endef
export header

ENV ?= dev
-include .env
-include .env.$(ENV)
export

.PHONY: print-env
print-env:
	@echo "Current env: $(ENV)"

qa-only:
ifneq ($(ENV),qa)
	$(error ENV must be qa)
endif

.PHONY: help
help:
	@echo "$$header"

.PHONY: schema
schema: print-env
	source .env && ./pg_dump.sh -U $$DB_USERNAME -h $$DB_HOST -d $$DB_DATABASE -s > priv/repo/schema.sql

.PHONE: qa-up
qa-up: print-env qa-only
	docker compose --env-file .env.qa -f docker-compose.qa.yml up --build -d
	@sleep 1
	docker compose --env-file .env.qa -f docker-compose.qa.yml exec app_qa /bin/bash /app/bin/migrate
	@sleep 1
	docker compose --env-file .env.qa -f docker-compose.qa.yml exec app_qa /bin/bash bin/modern_resume eval "ModernResume.Release.create_user(\"$(TEST_USER_EMAIL)\", \"$(TEST_USER_PASSWORD)\")"

.PHONE: print-env qa-down
qa-down:
	docker compose --env-file .env.qa -f docker-compose.qa.yml down

.DEFAULT_GOAL := help
