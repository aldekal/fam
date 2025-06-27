FROM postgres:17.5

# Copy initialization scripts
COPY init/ /docker-entrypoint-initdb.d/

# Expose PostgreSQL port
EXPOSE 5432
