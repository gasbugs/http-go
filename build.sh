#!/usr/bin/env bash
set -euo pipefail

# 첫 번째 인자를 이미지 태그로 사용하며, 없으면 사용 방법을 안내합니다.
tag=${1:?"usage: ./build.sh <tag>"}

# 지정된 태그로 애플리케이션 이미지를 빌드합니다.
echo "building image ${tag}"
docker build -t gasbugs/http-go:${tag} .

# 빌드한 이미지를 Docker Hub(gasbugs) 레포지토리로 푸시합니다.
docker push gasbugs/http-go:${tag}
