.PHONY: run test migrate-up migrate-down sqlc lint build docker-up docker-down

# Load .env if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

DATABASE_URL ?= postgres://expense:expense@localhost:5432/expense?sslmode=disable
MIGRATIONS_PATH ?= internal/db/migrations

run:
	go run ./cmd/server

build:
	go build -o bin/server ./cmd/server

test:
	go test ./... -v -race -count=1

test-unit:
	go test ./internal/... -v -race -count=1 -run 'Unit'

migrate-up:
	migrate -path $(MIGRATIONS_PATH) -database "$(DATABASE_URL)" up

migrate-down:
	migrate -path $(MIGRATIONS_PATH) -database "$(DATABASE_URL)" down

sqlc:
	sqlc generate

lint:
	golangci-lint run ./...

docker-up:
	docker-compose up -d postgres redis

docker-down:
	docker-compose down

start:
	docker-compose down
	docker compose build --no-cache frontend && docker compose up --build

