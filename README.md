[![Tests](https://github.com/authorizerdev/authorizer-helm-chart/actions/workflows/test.yml/badge.svg)](https://github.com/authorizerdev/authorizer-helm-chart/actions/workflows/test.yml)

# authorizer-helm-chart

Helm chart for [Authorizer](https://authorizer.dev) — an open-source, self-hosted authentication and authorization server. Authorizer provides OAuth 2.0 / OpenID Connect compliant APIs, a GraphQL-first API surface, and supports 13+ database backends (Postgres, MySQL, SQLite, SQLServer, YugaByte, MariaDB, PlanetScale, CassandraDB, ScyllaDB, MongoDB, ArangoDB, DynamoDB, Couchbase). You bring your database; Authorizer handles auth.

This chart deploys the Authorizer binary as a Kubernetes `Deployment`, wires up a `Service` (HTTP + optional gRPC port), optional metrics infrastructure, and exposes all server flags as `values.yaml` keys.

Chart version: **2.4.2** | App version: **2.4.0**

## Getting Started

**Prerequisites**

- Connected to a Kubernetes cluster
- [Helm](https://helm.sh/docs/intro/install/) installed

### Step 1: Add the repository

```sh
helm repo add authorizer https://helm-charts.authorizer.dev
```

### Step 2: Update repos

```sh
helm repo update
```

### Step 3: Install the chart

```sh
helm install \
    --namespace authorizer \
    --create-namespace \
    --set authorizer.database_type=sqlite \
    --set authorizer.database_url="/tmp/authorizer.db" \
    --set authorizer.client_id=YOUR_CLIENT_ID \
    --set authorizer.client_secret=YOUR_CLIENT_SECRET \
    --set authorizer.admin_secret=YOUR_ADMIN_SECRET \
    --set authorizer.jwt_type=HS256 \
    --set authorizer.jwt_secret=YOUR_JWT_SECRET \
    --set securityContext.readOnlyRootFilesystem=false \
    authorizer authorizer/authorizer
```

> **Note:** In v2, `client_id`, `client_secret`, and `admin_secret` are **required**. The binary refuses to start when `admin_secret` is empty. All configuration is passed via CLI args at startup. See [MIGRATION.md](https://github.com/authorizerdev/authorizer/blob/main/MIGRATION.md) for upgrade details.

## Port Exposure

The chart exposes three ports:

| Port | Protocol | Purpose | Exposed on Service by default |
| ---- | -------- | ------- | ----------------------------- |
| `8080` | HTTP | Main API — GraphQL, REST, OAuth flows, dashboard | Always (via `service.port: 80 → targetPort: 8080`) |
| `9091` | gRPC | Same API over gRPC | Yes — opt-out via `service.grpc.enabled: false` |
| `8081` | HTTP | Prometheus `/metrics` endpoint | No — opt-in via `metrics.service.enabled: true` |

The MCP surface is served on the **main HTTP port**, not a port of its own: it must be publicly reachable on the same origin as the OAuth metadata clients discover it through, so it inherits the existing Ingress, CORS, security headers and rate limiting. Enable it with `authorizer.mcp_enabled: true` (requires `authorizer.authorizer_url`).

The metrics port is never added to the main `Service` used for Ingress. Use `metrics.service.enabled: true` to create a dedicated internal `ClusterIP` service for in-cluster scraping, or `metrics.serviceMonitor.enabled: true` for Prometheus Operator integration.

## Values Reference

### Core

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `replicaCount` | Number of pod replicas | false | `1` |
| `image.repository` | Container image repository | false | `quay.io/authorizer/authorizer` |
| `image.pullPolicy` | Image pull policy | false | `IfNotPresent` |
| `image.tag` | Image tag. Defaults to chart `appVersion` when empty | false | `""` |
| `imagePullSecrets` | Image pull secret references | false | `[]` |
| `nameOverride` | Override chart name component | false | `""` |
| `fullnameOverride` | Override full release name | false | `""` |
| `serviceAccount.create` | Create a `ServiceAccount` | false | `true` |
| `serviceAccount.annotations` | Annotations for the `ServiceAccount` | false | `{}` |
| `serviceAccount.name` | `ServiceAccount` name; auto-generated when empty | false | `""` |
| `podAnnotations` | Annotations added to every pod | false | `{}` |
| `podSecurityContext.fsGroup` | `fsGroup` for pod volumes | false | `2000` |
| `securityContext.capabilities.drop` | Linux capabilities to drop | false | `[ALL]` |
| `securityContext.readOnlyRootFilesystem` | Mount root filesystem read-only | false | `true` |
| `securityContext.runAsNonRoot` | Require non-root user | false | `true` |
| `securityContext.runAsUser` | UID to run the container as | false | `65534` |
| `resources` | CPU/memory requests and limits | false | `{}` |
| `nodeSelector` | Node selector labels | false | `{}` |
| `tolerations` | Pod tolerations | false | `[]` |
| `affinity` | Pod affinity rules | false | `{}` |

### Service

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `service.type` | Kubernetes `Service` type | false | `ClusterIP` |
| `service.port` | Service port for HTTP traffic | false | `80` |
| `service.targetPort` | Container port targeted by the HTTP service port | false | `8080` |
| `service.grpc.enabled` | Expose the gRPC listener as a `grpc` port on the `Service` | false | `true` |
| `service.grpc.port` | Service port for gRPC | false | `9091` |

### Metrics

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `metrics.service.enabled` | Create a `ClusterIP` service (`*-metrics`) for in-cluster scraping | false | `false` |
| `metrics.serviceMonitor.enabled` | Create a `ServiceMonitor` for Prometheus Operator. Implies `metrics.service.enabled` | false | `false` |
| `metrics.serviceMonitor.interval` | Scrape interval | false | `30s` |
| `metrics.serviceMonitor.scrapeTimeout` | Scrape timeout | false | `10s` |
| `metrics.serviceMonitor.labels` | Extra labels on the `ServiceMonitor` (e.g. Prometheus release selector) | false | `{}` |

### Authorizer Server — Core

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.http_port` | Main HTTP listen port (`--http-port`). Must differ from `metrics_port` | false | `8080` |
| `authorizer.metrics_port` | Dedicated Prometheus `/metrics` listen port (`--metrics-port`) | false | `8081` |
| `authorizer.metrics_host` | Bind address for `/metrics` (`--metrics-host`). Use `0.0.0.0` for in-cluster scraping | false | `0.0.0.0` |
| `authorizer.authorizer_url` | Public URL of this Authorizer deployment | false | — |
| `authorizer.mcp_enabled` | Serve the MCP tool surface at `POST <authorizer_url>/mcp` as an OAuth 2.1 resource server. **Requires `authorizer.authorizer_url`** — the chart fails at render time without it, because the server exits at boot | false | `false` |
| `authorizer.reset_password_url` | Custom URL for password reset emails | false | — |
| `authorizer.backchannel_logout_uri` | Back-channel logout URI | false | — |
| `authorizer.custom_access_token_script` | JavaScript snippet (URL-encoded) injected at token issuance | false | — |
| `authorizer.default_authorize_response_type` | Default OAuth `response_type` | false | — |
| `authorizer.default_authorize_response_mode` | Default OAuth `response_mode` | false | — |
| `authorizer.refresh_token_expires_in` | Refresh-token lifetime in seconds (`--refresh-token-expires-in`). Default 30 days | false | — |

### Authorizer Server — gRPC

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.grpc_port` | gRPC listen port (`--grpc-port`). Must differ from `http_port` and `metrics_port` | false | `9091` |
| `authorizer.enable_grpc_reflection` | Enable gRPC server reflection (`--enable-grpc-reflection`) | false | `true` |
| `authorizer.grpc_insecure` | Run gRPC without TLS (`--grpc-insecure`). Set `false` with certs for native TLS | false | `true` |
| `authorizer.grpc_tls_cert` | In-container path to the gRPC TLS certificate | false | — |
| `authorizer.grpc_tls_key` | In-container path to the gRPC TLS private key | false | — |

### Authorizer Server — Rate Limiting

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.rate_limit_rps` | Per-IP sustained RPS (`--rate-limit-rps`). `0` disables rate limiting | false | `30` |
| `authorizer.rate_limit_burst` | Per-IP burst allowance (`--rate-limit-burst`) | false | `20` |
| `authorizer.rate_limit_fail_closed` | If `true`, backend errors return HTTP 503 (`--rate-limit-fail-closed`) | false | `false` |

### Authorizer Server — Security Hardening

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.trusted_proxies` | Comma-separated CIDRs of trusted reverse proxies (`--trusted-proxies`). Empty means `RemoteAddr` is used directly — safe by default | false | — |
| `authorizer.enable_hsts` | Add `Strict-Transport-Security` response header (`--enable-hsts`). Only enable behind TLS | false | `false` |
| `authorizer.disable_csp` | Disable the default Content-Security-Policy header (`--disable-csp`). Use only if the default policy breaks a custom dashboard | false | `false` |
| `authorizer.graphql_max_complexity` | Max GraphQL query complexity (`--graphql-max-complexity`) | false | `300` |
| `authorizer.graphql_max_depth` | Max GraphQL query depth (`--graphql-max-depth`) | false | `15` |
| `authorizer.graphql_max_aliases` | Max GraphQL field aliases per query (`--graphql-max-aliases`) | false | `30` |
| `authorizer.graphql_max_body_bytes` | Max GraphQL request body size in bytes (`--graphql-max-body-bytes`) | false | `1048576` |

### Authorizer Server — Identity (Required)

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.client_id` | OAuth client ID | **true** | — |
| `authorizer.client_secret` | OAuth client secret | **true** | — |
| `authorizer.admin_secret` | Admin secret for admin API access. Binary refuses to start when empty | **true** | — |

### Database

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.database_type` | Database backend. One of: `postgres`, `mysql`, `planetscale`, `sqlite`, `sqlserver`, `mongodb`, `arangodb`, `yugabyte`, `mariadb`, `cassandradb`, `scylladb`, `dynamodb`, `couchbase` | **true** | — |
| `authorizer.database_url` | Database connection string. See [docs](https://docs.authorizer.dev/core/databases) | **true** | — |
| `authorizer.database_name` | Database name | false | — |
| `authorizer.database_host` | Database host. Used for `cassandradb` and `scylladb` | false | — |
| `authorizer.database_port` | Database port | false | — |
| `authorizer.database_username` | Database username. Used for `cassandradb` and `scylladb` | false | — |
| `authorizer.database_password` | Database password. Used for `cassandradb` and `scylladb` | false | — |
| `authorizer.database_cert` | SSL certificate (base64-encoded) | false | — |
| `authorizer.database_cert_key` | SSL certificate key (base64-encoded) | false | — |
| `authorizer.database_ca_cert` | CA-signed certificate (base64-encoded) | false | — |

### FGA (OpenFGA)

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.fga_store` | OpenFGA store ID | false | — |
| `authorizer.fga_store_url` | OpenFGA server URL | false | — |

### JWT

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.jwt_type` | JWT signing algorithm (e.g. `HS256`, `RS256`, `ES256`) | false | — |
| `authorizer.jwt_secret` | Secret for HMAC-based JWT signing | false | — |
| `authorizer.encryption_key` | Encrypts TOTP secrets and OTP digests at rest. **Required when `jwt_type` is `RS*`/`ES*`** — there is no `jwt_secret` to fall back to and the server refuses to start. Generate once with `openssl rand -hex 32` and keep it stable; changing it makes existing TOTP enrolments undecryptable | false | — |
| `authorizer.jwt_private_key` | Private key for RSA/EC-based JWT signing | false | — |
| `authorizer.jwt_public_key` | Public key for RSA/EC-based JWT verification | false | — |
| `authorizer.jwt_role_claim` | Custom claim name for roles in the JWT | false | — |
| `authorizer.jwt_secondary_type` | Secondary JWT signing algorithm (for dual-token scenarios) | false | — |
| `authorizer.jwt_secondary_secret` | Secondary HMAC secret | false | — |
| `authorizer.jwt_secondary_private_key` | Secondary RSA/EC private key | false | — |
| `authorizer.jwt_secondary_public_key` | Secondary RSA/EC public key | false | — |

### OAuth Providers

Each provider follows the pattern `authorizer.<provider>_client_id`, `authorizer.<provider>_client_secret`, and `authorizer.<provider>_scopes`. Microsoft additionally accepts `authorizer.microsoft_tenant_id`.

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.google_client_id` | Google OAuth client ID | false | — |
| `authorizer.google_client_secret` | Google OAuth client secret | false | — |
| `authorizer.google_scopes` | Google OAuth scopes (space-separated) | false | — |
| `authorizer.github_client_id` | GitHub OAuth client ID | false | — |
| `authorizer.github_client_secret` | GitHub OAuth client secret | false | — |
| `authorizer.github_scopes` | GitHub OAuth scopes | false | — |
| `authorizer.facebook_client_id` | Facebook OAuth client ID | false | — |
| `authorizer.facebook_client_secret` | Facebook OAuth client secret | false | — |
| `authorizer.facebook_scopes` | Facebook OAuth scopes | false | — |
| `authorizer.microsoft_client_id` | Microsoft OAuth client ID | false | — |
| `authorizer.microsoft_client_secret` | Microsoft OAuth client secret | false | — |
| `authorizer.microsoft_tenant_id` | Microsoft AAD tenant ID | false | — |
| `authorizer.microsoft_scopes` | Microsoft OAuth scopes | false | — |
| `authorizer.apple_client_id` | Apple OAuth client ID | false | — |
| `authorizer.apple_client_secret` | Apple OAuth client secret | false | — |
| `authorizer.apple_scopes` | Apple OAuth scopes | false | — |
| `authorizer.discord_client_id` | Discord OAuth client ID | false | — |
| `authorizer.discord_client_secret` | Discord OAuth client secret | false | — |
| `authorizer.discord_scopes` | Discord OAuth scopes | false | — |
| `authorizer.linkedin_client_id` | LinkedIn OAuth client ID | false | — |
| `authorizer.linkedin_client_secret` | LinkedIn OAuth client secret | false | — |
| `authorizer.linkedin_scopes` | LinkedIn OAuth scopes | false | — |
| `authorizer.twitch_client_id` | Twitch OAuth client ID | false | — |
| `authorizer.twitch_client_secret` | Twitch OAuth client secret | false | — |
| `authorizer.twitch_scopes` | Twitch OAuth scopes | false | — |
| `authorizer.twitter_client_id` | Twitter OAuth client ID | false | — |
| `authorizer.twitter_client_secret` | Twitter OAuth client secret | false | — |
| `authorizer.twitter_scopes` | Twitter OAuth scopes | false | — |
| `authorizer.roblox_client_id` | Roblox OAuth client ID | false | — |
| `authorizer.roblox_client_secret` | Roblox OAuth client secret | false | — |
| `authorizer.roblox_scopes` | Roblox OAuth scopes | false | — |

### SMTP

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.smtp_host` | SMTP server hostname | false | — |
| `authorizer.smtp_port` | SMTP server port | false | — |
| `authorizer.smtp_username` | SMTP authentication username | false | — |
| `authorizer.smtp_password` | SMTP authentication password | false | — |
| `authorizer.smtp_sender_email` | From address for outbound email | false | — |
| `authorizer.smtp_sender_name` | From display name for outbound email | false | — |
| `authorizer.smtp_local_name` | EHLO/HELO hostname sent to the SMTP server | false | — |
| `authorizer.smtp_skip_tls_verification` | Skip TLS certificate verification for SMTP. Do not use in production | false | `false` |

### Twilio (SMS)

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.twilio_account_sid` | Twilio Account SID | false | — |
| `authorizer.twilio_api_key` | Twilio API Key | false | — |
| `authorizer.twilio_api_secret` | Twilio API Secret | false | — |
| `authorizer.twilio_sender` | Twilio sender phone number | false | — |

### Redis

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.redis_url` | Redis connection string for session storage. If unset, sessions are stored in-memory (not recommended for multi-replica deployments) | false | — |
| `redis.install` | Install a bundled Redis instance | false | — |
| `redis.storageClassName` | Storage class for the Redis PVC | false | — |
| `redis.storage` | PVC size for Redis | false | `5Gi` |

### AWS (DynamoDB)

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.aws_region` | AWS region for DynamoDB | false | — |
| `authorizer.aws_access_key_id` | AWS access key ID | false | — |
| `authorizer.aws_secret_access_key` | AWS secret access key | false | — |

### Couchbase

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.couchbase_bucket` | Couchbase bucket name for Authorizer collections | false | — |
| `authorizer.couchbase_bucket_ram_quota` | Couchbase bucket RAM quota in MB | false | — |
| `authorizer.couchbase_scope` | Couchbase scope for Authorizer collections | false | — |

### Branding and Access Control

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `authorizer.roles` | Comma-separated list of available roles | false | — |
| `authorizer.default_roles` | Comma-separated list of roles assigned to new users | false | — |
| `authorizer.protected_roles` | Comma-separated list of roles that cannot be self-assigned | false | — |
| `authorizer.allowed_origins` | Comma-separated list of allowed CORS origins | false | — |
| `authorizer.organization_name` | Organization name shown in the dashboard and emails | false | — |
| `authorizer.organization_logo` | URL of organization logo shown in the dashboard | false | — |

### Extra Environment Variables

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `extraEnv` | Extra environment variables injected into the pod. Values are also expanded as CLI args. See [docs](https://docs.authorizer.dev/core/env) for the full list of supported flags | false | `[]` |

Example:

```yaml
extraEnv:
  - name: ENABLE_SIGNUP
    value: "true"
  - name: ENABLE_MFA
    value: "true"
```

> Do **not** duplicate `PORT`, `METRICS_PORT`, `METRICS_HOST`, `RATE_LIMIT_RPS`, `RATE_LIMIT_BURST`, or `RATE_LIMIT_FAIL_CLOSED` in `extraEnv`. Kubernetes rejects pods with duplicate environment variable names.

## Upgrading

**Chart version** (`version` in `Chart.yaml`) is incremented for any template, values, or packaging change. **App version** (`appVersion`) tracks the Authorizer binary release and is updated automatically by `release.sh` on each release.

When upgrading the chart, check the [CHANGELOG](https://github.com/authorizerdev/authorizer-helm-chart/releases) and [MIGRATION.md](https://github.com/authorizerdev/authorizer/blob/main/MIGRATION.md) for breaking changes introduced by the app version bump.

## Release Workflow

Publishing is automatic. `.github/workflows/publish.yml` runs on every push to `main`
that touches `Chart.yaml`, `values.yaml` or `templates/`. It packages the chart,
regenerates `index.yaml`, and commits both back to `main`. Netlify serves the branch
root at https://helm-charts.authorizer.dev, so the new version is live once that
commit deploys.

To cut a release, bump `version` in `Chart.yaml` (and `appVersion` when the binary
changes) and merge to `main`. Nothing else. A version that is already packaged under
`charts/` is skipped, so re-runs are no-ops.

Do not put a CI-skip marker in a commit that touches `charts/` or `index.yaml` —
Netlify honours those markers and the chart will land in git without ever being served.

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
