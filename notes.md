SELECT current_user, current_database(), current_date;

SELECT COUNT(*) FROM data_2022_oct

SELECT * FROM data_2022_oct LIMIT 20

SELECT * FROM data_2022_oct ORDER BY event_time DESC;


# filter by user_id
SELECT * FROM data_2022_oct WHERE user_id = 385985999;

# filter by product_id
SELECT * FROM data_2022_oct WHERE product_id = 1854625;

# filter by event_time
SELECT * FROM data_2022_oct WHERE event_time > '2022-10-01 00:00:00' AND event_time < '2022-10-01 00:10:00';

# filter by event_time and product_id
SELECT * FROM data_2022_oct WHERE event_time > '2022-10-01 00:00:00' AND event_time < '2022-10-01 00:10:00' AND product_id = 1854625;


# Connecting to postgres db container from local machine
psql -h localhost -p 5432 -U asoler -d piscineds -W

# Access postgres container shell
docker compose exec -it postgres bash

# Execute sql file from inside the container
psql -U asoler -d piscineds -f /workspace/ex02/table.sql

# Execute sql file from local machine using local psql
psql -h localhost -p 5432 -U asoler -d piscineds -f table.sql

SELECT * FROM data_2022_oct WHERE user_id = 385985999;
