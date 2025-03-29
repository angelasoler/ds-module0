all: up

up:
	docker compose up -d

stop:
	docker compose stop

start:
	docker compose start

down:
	docker compose down

clean:
	docker compose down -v

psql:
	docker compose exec postgres psql -U <user> -d <db_name>
