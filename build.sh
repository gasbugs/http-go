#!/usr/bin/env bash
set -euo pipefail

# 첫 번째 인자를 이미지 태그로 사용하며, 없으면 사용 방법을 안내합니다.
tag=${1:?"usage: ./build.sh <tag>"}

# 빌드용 컨테이너 CLI 확인 및 멀티 아키텍처 이미지 빌드/푸시
if command -v podman >/dev/null 2>&1; then
  echo "building multi-arch image ${tag} using podman"
  podman build --platform linux/amd64,linux/arm64 --build-arg APP_VERSION=${tag} --manifest gasbugs/http-go:${tag} .
  podman manifest push gasbugs/http-go:${tag} docker://docker.io/gasbugs/http-go:${tag}
elif command -v docker >/dev/null 2>&1; then
  echo "building multi-arch image ${tag} using docker buildx"
  # Docker는 멀티 아키텍처 빌드 시 빌드와 동시에 푸시(--push)하는 방식을 기본으로 사용합니다.
  docker buildx build --platform linux/amd64,linux/arm64 --build-arg APP_VERSION=${tag} -t gasbugs/http-go:${tag} --push .
else
  echo "Error: podman or docker is required to build images." >&2
  exit 1
fi
