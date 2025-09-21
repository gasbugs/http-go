# http-go

컨테이너 배포와 자동 빌드를 염두에 둔 최소한의 Go HTTP 서비스입니다.

## 주요 기능
- 컨테이너 호스트명과 버전을 포함한 JSON 환영 메시지를 제공합니다.
- SIGINT 수신 시 10초 타임아웃으로 우아하게 종료합니다.
- 다단계 Docker 빌드로 비루트 사용자 기반의 경량 Ubuntu 런타임 이미지를 생성합니다.

## 시작하기
```bash
# 로컬 실행
go run main.go

# 수동 테스트용 바이너리 빌드
go build -o main main.go
./main
```
서비스는 `:8080` 포트에서 리슨합니다. `http://localhost:8080/`에 접속하거나 `curl http://localhost:8080/`으로 JSON 응답을 확인하세요.

## 프로젝트 구조
- `main.go` – HTTP 핸들러와 서버 부트스트랩을 정의합니다.
- `build.sh` – 이미지를 교차 빌드하고 푸시하는 스크립트 (`./build.sh <tag>`).
- `Dockerfile` – 다단계 빌드로 Go 바이너리를 컴파일하고 경량 런타임 스테이지로 복사합니다.
- `buildspec.yml` – Docker 빌드·푸시 플로우를 반영한 AWS CodeBuild 설정입니다.
- `deployment.yaml` – 80 → 8080 포트를 노출하는 Kubernetes Deployment/Service 매니페스트입니다.
- `AGENTS.md` – 구조, 워크플로, 릴리스 기대치를 설명하는 기여자 가이드입니다.

## 컨테이너 워크플로
```bash
# 로컬 이미지 빌드 (Docker 데몬 접근 필요)
docker build -t http-go:dev .

# 컨테이너 실행 및 서비스 노출
docker run --rm -p 8080:8080 http-go:dev

# 응답 예시
curl http://localhost:8080/
# {"data":"Welcome! <hostname>","version":"v3.1"}
```
다른 서비스와 함께 실행할 경우 사용 가능한 호스트 포트에 매핑하세요(예: `-p 18080:8080`). 백그라운드 실행 시 `Ctrl+C` 또는 `docker rm -f <name>`으로 종료할 수 있습니다.

## 개발 워크플로
1. Go 1.21+ 환경을 사용하고 필요 시 `go mod init`, `go mod tidy`로 모듈을 준비합니다.
2. 간단한 핸들러는 `main.go`에 두고, 로직이 커지면 `internal/<feature>/` 패키지로 분리합니다.
3. 커밋 전 `go fmt ./...`로 포맷을 맞추고 표준 라이브러리 로깅을 사용합니다.
4. 모듈 변경 시에는 `go mod tidy`로 의존성을 정리합니다.

## 테스트
테이블 기반 테스트를 `*_test.go` 파일로 작성하고, 픽스처는 테스트와 같은 경로에 둡니다. 전체 테스트는 아래 명령으로 실행합니다.
```bash
go test ./...
```
새 패키지는 `-cover` 옵션으로 80% 이상 커버리지를 확인하세요.

## 배포 및 릴리스
- `./build.sh <tag>`는 교차 빌드·태깅·푸시를 수행합니다(레지스트리 로그인 선행 필요).
- CI는 `buildspec.yml`을 통해 동일한 다단계 빌드를 CodeBuild에서 실행합니다.
- 새 태그를 `deployment.yaml`에 반영한 뒤 `kubectl apply -f deployment.yaml`로 배포합니다.
- 롤아웃 후 컨테이너 로그에서 최초 요청 사이클을 확인해 핸들러 연결 여부를 검증합니다.

## 기여 안내
`AGENTS.md`의 지침을 따르고, `Add health probe`와 같은 짧은 명령형 커밋 메시지를 사용하세요. 동작이 바뀌면 PR 설명에 `go test ./...` 결과나 `curl` 예시를 포함해 주세요.

## 라이선스
프로젝트에 적용할 라이선스를 명시하세요(현재 미정).
