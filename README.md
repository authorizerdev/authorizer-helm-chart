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
    --set authorizer.client_id=YOUR_CLIENT_ID \
    --set authorizer.client_secret=YOUR_CLIENT_SECRET \
    --set authorizer.admin_secret=YOUR_ADMIN_SECRET \
    --set authorizer.jwt_type=HS256 \
    --set authorizer.jwt_secret=YOUR_JWT_SECRET \
    --set securityContext.readOnlyRootFilesystem=false \
    authorizer authorizer/authorizer
```

> **Note:** In v2, `client_id` and `client_secret` are **required**. All configuration is passed via CLI args at startup. See [MIGRATION.md](https://github.com/authorizerdev/authorizer/blob/main/MIGRATION.md) for details.

#### Variables

| Name                                    | Description                                                                                                                                                | Required | Default |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `authorizer.database_type`              | Type of database. Supported values `postgres, mysql, planetscale, sqlite, sqlserver, mongodb, arangodb, yugabyte, mariadb, cassandradb, scylladb, dynamodb, couchbase` | true     | -       |
| `authorizer.database_url`               | Database connection string. For more information check [docs](https://docs.authorizer.dev/core/databases)                                                  | true     | -       |
| `authorizer.database_name`              | Database name.                                                                                                                                             | false    | -       |
| `authorizer.database_host`              | Host name for the database. Use for cassandradb & scylladb.                                                                                                | false    | -       |
| `authorizer.database_port`              | Port for the database.                                                                                                                                     | false    | -       |
| `authorizer.database_username`          | Username for the database. Use for cassandradb & scylladb.                                                                                                 | false    | -       |
| `authorizer.database_password`          | Password for the database. Use for cassandradb & scylladb.                                                                                                 | false    | -       |
| `authorizer.database_cert`              | SSL Certificate for the database in base64 encoded form.                                                                                                   | false    | -       |
| `authorizer.database_cert_key`          | SSL Certificate Key for the database in base64 encoded form.                                                                                               | false    | -       |
| `authorizer.database_ca_cert`           | CA Signed Certificate for the database in base64 encoded form.                                                                                             | false    | -       |
| `authorizer.client_id`                  | OAuth client ID. **Required in v2.**                                                                                                                       | true     | -       |
| `authorizer.client_secret`              | OAuth client secret. **Required in v2.**                                                                                                                   | true     | -       |
| `authorizer.admin_secret`               | Admin secret for admin API access.                                                                                                                         | false    | -       |
| `authorizer.jwt_type`                   | JWT signing algorithm (e.g. HS256, RS256).                                                                                                                 | false    | -       |
| `authorizer.jwt_secret`                 | Secret for HMAC-based JWT signing.                                                                                                                         | false    | -       |
| `authorizer.jwt_private_key`            | Private key for RSA/EC-based JWT signing.                                                                                                                  | false    | -       |
| `authorizer.jwt_public_key`             | Public key for RSA/EC-based JWT verification.                                                                                                              | false    | -       |
| `authorizer.redis_url`                  | Redis connection string for storing session information.                                                                                                   | false    | -       |
| `redis.install`                         | Install Redis. Accepts (true/false) as value.                                                                                                              | false    | -       |
| `redis.storageClassName`                | Storage class name for Redis PVC.                                                                                                                          | false    | -       |
| `redis.storage`                         | Size of Redis PVC.                                                                                                                                         | false    | `5Gi`   |
| `authorizer.aws_region`                 | AWS Region for dynamodb.                                                                                                                                   | false    | -       |
| `authorizer.aws_access_key_id`          | AWS access key identifier for dynamodb.                                                                                                                    | false    | -       |
| `authorizer.aws_secret_access_key`      | AWS secret access key for dynamodb.                                                                                                                        | false    | -       |
| `authorizer.couchbase_bucket`           | Couchbase Bucket for authorizer collections.                                                                                                               | false    | -       |
| `authorizer.couchbase_bucket_ram_quota` | Couchbase Bucket RAM Quota in mega bytes.                                                                                                                  | false    | -       |
| `authorizer.couchbase_scope`            | Couchbase scope for authorizer collections.                                                                                                                | false    | -       |
| `authorizer.twilio_account_sid`         | Twilio Account SID for SMS support.                                                                                                                        | false    | -       |
| `authorizer.twilio_api_key`             | Twilio API Key for SMS support.                                                                                                                            | false    | -       |
| `authorizer.twilio_api_secret`          | Twilio API Secret for SMS support.                                                                                                                         | false    | -       |
| `authorizer.twilio_sender`              | Twilio Sender phone number for SMS support.                                                                                                                | false    | -       |
| `authorizer.smtp_host`                  | SMTP host for email.                                                                                                                                       | false    | -       |
| `authorizer.smtp_port`                  | SMTP port for email.                                                                                                                                       | false    | -       |
| `authorizer.smtp_username`              | SMTP username for email.                                                                                                                                   | false    | -       |
| `authorizer.smtp_password`              | SMTP password for email.                                                                                                                                   | false    | -       |
| `authorizer.smtp_sender_email`          | SMTP sender email address.                                                                                                                                 | false    | -       |
| `authorizer.smtp_sender_name`           | SMTP sender display name.                                                                                                                                  | false    | -       |
| `authorizer.authorizer_url`             | URL for authorizer deployment.                                                                                                                             | false    | -       |
| `extraEnv`                              | Extra environment variables (e.g. feature flags, OAuth providers). Check [docs](https://docs.authorizer.dev/core/env) for all options.                     | false    | `[]`    |

#### Feature Flags and OAuth Providers via extraEnv

All v2 feature flags and OAuth provider configurations can be set via `extraEnv`. These are expanded as environment variables and passed as CLI args to the authorizer binary. For example:

```yaml
extraEnv:
  - name: "ENABLE_SIGNUP"
    value: "true"
  - name: "ENABLE_MFA"
    value: "true"
  - name: "GOOGLE_CLIENT_ID"
    value: "your-google-client-id"
  - name: "GOOGLE_CLIENT_SECRET"
    value: "your-google-client-secret"
```

See `cmd/root.go` in the [authorizer repo](https://github.com/authorizerdev/authorizer) or run `./authorizer --help` for the full list of supported flags.

## Local Testing with Kind

You can test this Helm chart locally using [kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker).

**Prerequisites**

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

### Step 1: Create a kind cluster

```sh
kind create cluster --name authorizer-test
```

### Step 2: Install the chart

```sh
helm install \
    --namespace authorizer \
    --create-namespace \
    --set authorizer.database_type=sqlite \
    --set authorizer.database_url="/tmp/authorizer.db" \
    --set authorizer.client_id=test-client-id \
    --set authorizer.client_secret=test-client-secret \
    --set authorizer.admin_secret=test-admin-secret \
    --set authorizer.jwt_type=HS256 \
    --set authorizer.jwt_secret=test-jwt-secret \
    --set securityContext.readOnlyRootFilesystem=false \
    --set securityContext.runAsNonRoot=false \
    --set securityContext.runAsUser=0 \
    --set replicaCount=2 \
    authorizer . \
    --kube-context kind-authorizer-test
```

### Step 3: Verify the deployment

```sh
kubectl --context kind-authorizer-test -n authorizer rollout status deployment/authorizer --timeout=120s
kubectl --context kind-authorizer-test -n authorizer get pods
```

### Step 4: Access the dashboard

```sh
kubectl --context kind-authorizer-test -n authorizer port-forward svc/authorizer 8080:80
```

Visit http://127.0.0.1:8080/dashboard/ in your browser.

### Cleanup

```sh
kind delete cluster --name authorizer-test
```
