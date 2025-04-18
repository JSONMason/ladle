FROM golang:1.24 AS base
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod tidy
COPY ./ ./

# Dev stage with Air (live reload)
FROM base AS dev
EXPOSE 8080
RUN go install github.com/air-verse/air@latest
CMD ["air", "-d", "-c", "/app/.air.toml"]

# Build production binary
FROM base AS build
# Disable Cgo to produce a fully static binary with no C dependencies.
ENV CGO_ENABLED=0
RUN go build -o ladle ./cmd/ladle/main.go

# Prod stage
FROM alpine:latest AS prod
# Install required system certificates for HTTPS support
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=build /app/ladle /usr/local/bin/ladle
EXPOSE 8080
CMD ["ladle"]
