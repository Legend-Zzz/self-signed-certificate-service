FROM golang:1.21.1-alpine AS builder

LABEL stage=gobuilder

ENV CGO_ENABLED 0
ENV GOPROXY https://goproxy.cn,direct
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk update --no-cache && apk add --no-cache tzdata

WORKDIR /build

ADD go.mod .
ADD go.sum .
RUN go mod download
COPY . .
COPY ./etc /app/etc
RUN go build -ldflags="-s -w" -o /app/self-signed-certificate-service .


FROM alpine:latest
ENV TZ Asia/Shanghai
WORKDIR /app

RUN apk add openssl bash

COPY scripts scripts
RUN chmod +x scripts/*.sh

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /usr/share/zoneinfo/Asia/Shanghai


COPY --from=builder /app/self-signed-certificate-service /app/self-signed-certificate-service
COPY --from=builder /app/etc /app/etc

CMD ["./self-signed-certificate-service", "-f", "etc/self-signed-certificate-service-api.yaml"]
