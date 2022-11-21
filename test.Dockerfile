FROM postgres:14.4

ENV POSTGRES_DB=bambusinessintegration
ENV POSTGRES_USER=hfubusinessintegrations
ENV POSTGRES_PASSWORD=dn6WC8NTtM3WmCXA

ARG TEAM_LIMIT=bbf8f214-5113-44f4-86ac-89d30eba469b

COPY init/ docker-entrypoint-initdb.d/

WORKDIR /docker-entrypoint-initdb.d/table-entries
RUN tac team.csv | sed -n "/$TEAM_LIMIT/,\$p" | tac > new-team.csv && \
    rm team.csv && \
    mv new-team.csv team.csv && \
    tac student.csv | sed -n "/$TEAM_LIMIT/,\$p" | tac > new-student.csv && \
    rm student.csv && \
    mv new-student.csv student.csv && \
    tac statistic.csv | sed -n "/$TEAM_LIMIT/,\$p" | tac > new-statistic.csv && \
    rm statistic.csv && \
    mv new-statistic.csv statistic.csv

EXPOSE 5432