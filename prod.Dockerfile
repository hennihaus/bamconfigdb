FROM postgres:14.4
ENV POSTGRES_DB=bambusinessintegration
ENV POSTGRES_USER=hfubusinessintegration
ENV POSTGRES_PASSWORD=dn6WC8NTtM3WmCXA
COPY init/ docker-entrypoint-initdb.d/
EXPOSE 5432