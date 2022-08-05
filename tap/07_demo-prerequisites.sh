DB_NAMESPACE=dev
DB_NAME=spring-petclinic-vets-service

sh $TAP_FILES_PATH/script/create-additional-dev-space.sh $DB_NAMESPACE

# Create Postgresql instance
ytt -f $TAP_FILES_PATH/data/postgresql/postgresql.yaml \
  -v namespace=$DB_NAMESPACE \
  -v db=$DB_NAME | kubectl apply -f-

