# Repository Guidelines
This repository hosts a minimal Go HTTP service optimized for clean container builds. Treat this guide as the single source of truth for contributing efficiently and safely.

## Project Structure & Module Organization
- `main.go` exposes the HTTP handler and server bootstrap; keep route logic small and move complex flows into `internal/<feature>/` packages.
- Build assets live at the repo root (`build.sh`, `buildspec.yml`, `Dockerfile`, `deployment.yaml`); update them together when you change build or deploy behavior.
- Co-locate tests with their sources as `*_test.go`. Place helper scripts under `scripts/` to avoid cluttering the root.

## Build, Test, and Development Commands
- `go run main.go`: start the service on `localhost:8080` for quick manual checks.
- `go build -o main main.go`: create a local binary; run `./main` to sanity check container-ready output.
- `go test ./...`: execute all unit tests; add `-cover` to verify ≥80% coverage for new packages.
- `docker build -t http-go:dev .`: build the multi-stage image without requiring a local Go toolchain.
- `./build.sh <tag>`: cross-build, tag, and push; run `aws ecr get-login` beforehand when publishing to ECR.

## Coding Style & Naming Conventions
Format with `go fmt ./...` (tabs, gofmt defaults). Exported symbols use PascalCase, internal helpers stay lowerCamelCase, and JSON struct tags remain lower_snake_case. Keep logs concise, using the standard library only.

## Testing Guidelines
Prefer table-driven tests with Go's `testing` package. Stub environment-dependent values so handlers stay deterministic. Name fixtures after the scenario (`handler_success.json`) and keep them beside the test.

## Commit & Pull Request Guidelines
Write short, imperative commit subjects such as `Add health probe`. Scope each commit to one logical change and run `go test ./...` before pushing. PR descriptions should call out behavioral changes, list validation commands, reference related issues, and attach `curl` output or logs for HTTP updates.

## Deployment & Operations Notes
`buildspec.yml` drives CI using the Docker multi-stage build. Update `deployment.yaml` with new image tags and keep readiness/liveness probes aligned with handler routes. After deploys, confirm the first request cycle in container logs to ensure the handler is reachable.
