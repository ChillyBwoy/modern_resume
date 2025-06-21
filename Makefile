info: header

define header

Makefile for the API.
Usage:
  make help      show this help
  make schema    create the database schema

endef
export header

include .env

.PHONY: help
help:
	@echo "$$header"

.PHONY: schema
schema:
	./pg_dump.sh -U $$DB_USERNAME -h $$DB_HOST -d $$DB_DATABASE -s > priv/repo/schema.sql

.DEFAULT_GOAL := help
