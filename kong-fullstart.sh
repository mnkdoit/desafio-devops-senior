docker network create kong-net

docker run -d --name kong-database \
--network=kong-net \
-p 5555:5432 \
-e “POSTGRES_USER=kong” \
-e “POSTGRES_DB=kong” \
postgres:9.6

docker run --rm \
--network=kong-net \
-e “KONG_DATABASE=postgres” \
-e “KONG_PG_HOST=kong-database” \
kong:latest kong migrations up