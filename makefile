all: up

up:
	docker compose up -d

stop:
	docker compose stop

start:
	docker compose start

ps:
	docker compose ps

down:
	docker compose down

clean:
	docker compose down -v
