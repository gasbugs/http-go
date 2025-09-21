# syntax=docker/dockerfile:1

# --- 빌더 스테이지: Go 툴체인을 포함한 이미지에서 바이너리를 컴파일합니다.
FROM golang:1.21 AS builder
WORKDIR /go/src/http-go
# 전체 소스를 복사하여 빌드 컨텍스트를 준비합니다.
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=off go build -o /usr/local/bin/http-go ./main.go

# --- 런타임 스테이지: 최소한의 Ubuntu 이미지에 바이너리만 포함합니다.
FROM ubuntu:22.04
WORKDIR /usr/src/app
# 빌드된 정적 바이너리를 런타임 이미지에 복사합니다.
COPY --from=builder /usr/local/bin/http-go /usr/src/app/main
EXPOSE 8080
# 미리 생성된 비루트 UID로 실행해 보안을 강화합니다.
USER 1000
CMD ["/usr/src/app/main"]
