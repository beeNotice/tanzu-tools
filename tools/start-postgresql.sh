nohup docker run -e POSTGRES_USER=pgappuser -e POSTGRES_PASSWORD=pgappuser -e POSTGRES_DB=postgres-tanzu-app -p 5432:5432 postgres:14.2 > /dev/null 2>&1 & 
