# Changelog

Notable changes to the Authorizer Helm chart. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Chart versions are independent of the Authorizer binary version, which the
chart tracks as `appVersion`. History starts at chart 2.4.0.

## [2.4.5] — 2026-08-19

App version 2.4.0.

### Fixed

- **A numeric value in any secret aborted the render.** All 47 secrets went
  through `b64enc` with no `toString`, and Helm parses `--set
  authorizer.client_id=123456` — the value the docs give as the example — as
  `int64`. The install failed with `wrong type for value; expected string; got
  int64`, naming no key. Present since 2.4.0. The install test now uses a
  numeric `client_id`.

## [2.4.4] — 2026-08-19

App version 2.4.0.

### Fixed

- `values.yaml`: `redirect_uris` had landed between the client-ID-metadata
  comment and the key it documented, so `helm show values` described
  `redirect_uris` under a CIMD comment and left
  `enable_client_id_metadata_document` undocumented. Moved beside
  `allowed_origins`, which is what it overrides. No change to rendering.

### Changed

- `Publish chart` now runs `test.yml` as a called job and depends on it. The
  two workflows were independent, which is how 2.4.2 reached `index.yaml` with
  failing tests.

## [2.4.3] — 2026-08-19

App version 2.4.0.

### Fixed

- Removed a comment that had been written inside the container's shell args
  block. See 2.4.2.

## [2.4.2] — 2026-08-19 — **YANKED**

Removed from `charts/` and `index.yaml`. `helm install --version 2.4.2` now
fails with "chart version not found" rather than deploying a pod that cannot
start.

The `REDIRECT_URIS` guard was documented with `#` comments placed inside the
container's shell command. `sh` treats `#` as a comment, so the line
continuation after `--allowed-origins` ran into it and every flag after that
point was executed as its own command. The container never started and
`helm --wait` reported only `context deadline exceeded`.

Superseded by 2.4.3.

## [2.4.1] — 2026-08-19 — **YANKED**

Removed from `charts/` and `index.yaml`.

Passed `--redirect-uris` unconditionally rather than guarding it with
`${REDIRECT_URIS:+...}`. Harmless on app version 2.4.0 and later, where an
empty value is a no-op, but `image.tag` is user-overridable and any older tag
rejects the unknown flag at boot.

Superseded by 2.4.3.

## [2.4.0] — 2026-08-19

App version 2.4.0.

### Added

- `authorizer.redirect_uris` (`--redirect-uris`): comma-separated **exact**
  redirect URIs for this deployment's own client. Unset falls back to matching
  `allowed_origins`, which compares origins, so any path under an allowed host
  is accepted.
- CIMD and dynamic client registration values:
  `enable_client_id_metadata_document`,
  `client_id_metadata_allowed_domains`, `enable_dynamic_client_registration`.

### Changed

- **`authorizer.authorizer_url` is now required.** The chart fails at render
  time without it, because app version 2.4.0 exits at boot without `--url`.
  The k8s install test now sets it — it never had, so the render aborted
  before the cluster was ever exercised.
