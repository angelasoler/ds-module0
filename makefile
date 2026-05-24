all: up

up:
	docker compose -f ex00/docker-compose.yml up -d

stop:
	docker compose -f ex00/docker-compose.yml stop

start:
	docker compose -f ex00/docker-compose.yml start

ps:
	docker compose -f ex00/docker-compose.yml ps

down:
	docker compose -f ex00/docker-compose.yml down

clean:
	docker compose -f ex00/docker-compose.yml down -v
