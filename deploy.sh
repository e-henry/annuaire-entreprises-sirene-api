#!/bin/sh

ENV="blue"

if [ "$(docker ps -f name=db-$ENV -q | wc -l)" = 0 ]
then
    ENV="blue"
    OLD="green"
else
    ENV="green"
    OLD="blue"
fi

echo "Switching to ENV $ENV (old is $OLD)"

echo "Cleaning docker unused objects"
docker system prune
docker volume prune


echo "Starting Postgres $ENV container"
docker-compose -f docker-compose-postgres-$ENV.yml --project-name=$ENV up --build -d

while [ "$(docker ps --filter 'health=healthy' | grep -c $ENV)" = 0 ]
do
    sleep 30s
    echo "Waiting..."
done

echo "Starting Postgrest $ENV container"
docker-compose -f docker-compose-postgrest-$ENV.yml --project-name=$ENV up --build -d

while [ "$(docker ps --filter "health=healthy" | grep -c $ENV)" != 2 ]
do
    sleep 30s
    echo "Waiting..."
done

echo "Container up and healthy"

echo "Stopping $OLD container"
docker-compose -f docker-compose-postgres-$OLD.yml --project-name=$OLD down
docker-compose -f docker-compose-postgrest-$OLD.yml --project-name=$OLD down
