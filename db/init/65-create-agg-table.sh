psql --set ON_ERROR_STOP=true -U $POSTGRES_USER -d $POSTGRES_DB -f /docker-entrypoint-initdb.d/sql/65-create-agg-table.sql