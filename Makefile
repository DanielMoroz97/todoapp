include .env
export

export PROJECT_ROOT=$(shel pwd)


env-up:
	docker compose -f docker-compose.yaml up -d todoapp-postgres

env-down:
	docker compose -f docker-compose.yaml down todoapp-postgres

migrate-create:
	@if [-z "$(seq)" ]; then \
		echo "Отсутствует параметр seq" \
		exit 1;\
	fi;\

	docker compose -f docker-compose.yaml run --rm todoapp-pg-magrate \
		create\
		-ext sql \
		-dir /migrations\
		-seq "$(seq)"

migrate-up:
	make migrate-action action=up
migrate-down:
	make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
	echo "Отсутствует параметр action"; \
	exit 1; \
	fi; \
	docker compose -f docker-compose.yaml run --rm todoapp-pg-magrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"

env-port-forward:
	@docker compose up -d port-forwarder
env-port-close:
	@docker compose down -d port-forwarder