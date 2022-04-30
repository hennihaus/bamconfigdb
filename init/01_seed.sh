mongoimport --db businessintegration --collection bank --file /docker-entrypoint-initdb.d/bank.json --jsonArray
mongoimport --db businessintegration --collection group --file /docker-entrypoint-initdb.d/group.json --jsonArray
mongoimport --db businessintegration --collection task --file /docker-entrypoint-initdb.d/task.json --jsonArray