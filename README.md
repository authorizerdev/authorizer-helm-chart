[![Tests](https://github.com/authorizerdev/authorizer-helm-chart/actions/workflows/test.yml/badge.svg)](https://github.com/authorizerdev/authorizer-helm-chart/actions/workflows/test.yml)

# authorizer-helm-chart

Helm Chart for Authorizer

**Authorizer** is an open-source authentication and authorization solution for your applications. Bring your database and have complete control over the user information. You can self-host authorizer instances and connect to any database (Currently supports 11+ databases including [Postgres](https://www.postgresql.org/), [MySQL](https://www.mysql.com/), [SQLite](https://www.sqlite.org/index.html), [SQLServer](https://www.microsoft.com/en-us/sql-server/), [YugaByte](https://www.yugabyte.com/), [MariaDB](https://mariadb.org/), [PlanetScale](https://planetscale.com/), [CassandraDB](https://cassandra.apache.org/_/index.html), [ScyllaDB](https://www.scylladb.com/), [MongoDB](https://mongodb.com/), [ArangoDB](https://www.arangodb.com/), [DynamoDB](https://aws.amazon.com/dynamodb/)).

## Getting Started

**Prerequisite**

- You should be connected to kubernetes cluster
- You should have [helm](https://helm.sh/docs/intro/install/) installed

### Step 1: Add repository

```sh
helm repo add authorizer https://helm-charts.authorizer.dev
```

### Step 2: Update helm repos

```sh
helm repo update
```

### Step 3: Install helm chart

```sh
helm install \
    --namespace authorizer \
    --create-namespace \
    --set authorizer.database_type=sqlite \
    --set authorizer.database_url="/tmp/db" \
    --set securityContext.readOnlyRootFilesystem=false \
    authorizer authorizer/authorizer
```

#### Variables

| Name                                    | Description                                                                                                                                       | Required | Default      |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------ |
| `authorizer.database_type`              | Type of database. Supported values `postgres, mysql, planetscale, sqlite, sqlserver, mongodb, arangodb, yugabyte, mariadb, cassandradb, scylladb` | true     | -            |
| `authorizer.database_url`               | Database connection string. For more information check [docs](https://docs.authorizer.dev/core/databases)                                         | true     | -            |
| `authorizer.database_host`              | Host name for the database. Use for cassandradb & scylladb.                                                                                       | false    | -            |
| `authorizer.database_username`          | Username for the database. Use for cassandradb & scylladb.                                                                                        | false    | -            |
| `authorizer.database_password`          | Password for the database. Use for cassandradb & scylladb.                                                                                        | false    | -            |
| `authorizer.database_cert`              | SSL Certificate for the database in base64 encoded form. Use for cassandradb & scylladb.                                                          | false    | -            |
| `authorizer.database_cert_key`          | SSL Certificate Key for the database in base64 encoded form. Use for cassandradb & scylladb.                                                      | false    | -            |
| `authorizer.database_ca_cert`           | CA Signed Certificate for the database in base64 encoded form. Use for cassandradb & scylladb.                                                    | false    | -            |
| `authorizer.aws_region`                 | AWS Region for dynamodb.                                                                                                                          | false    | -            |
| `authorizer.aws_access_key_id`          | AWS access key identifier for dynamodb.                                                                                                           | false    | -            |
| `authorizer.aws_secret_access_key`      | AWS secret access key for dynamodb.                                                                                                               | false    | -            |
| `authorizer.redis_url`                  | REDIS connection string for storing session information.                                                                                          | false    | -            |
| `redis.install`                         | Install Redis. Accepts (true/false) as value                                                                                                      | false    | -            |
| `redis.storageClassName`                | Storage class name for Redis PVC.                                                                                                                 | false    | -            |
| `redis.storage`                         | Size of Redis PVC.                                                                                                                                | false    | `5Gi`        |
| `authorizer.couchbase_bucket`           | Couchbase Bucket for authorizer collections.                                                                                                      | false    | `authorizer` |
| `authorizer.couchbase_bucket_ram_quota` | Couchbase Bucket RAM Quota in mega bytes. This value has to be numeric                                                                            | false    | `1000`       |
| `authorizer.couchbase_scope`            | Couchbase scope for authorizer collections.                                                                                                       | false    | `_default`   |
