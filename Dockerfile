FROM --platform=$BUILDPLATFORM golang:1.22-bookworm AS builder

ARG TARGETOS
ARG TARGETARCH
ARG VERSION=v0.0.0

WORKDIR /build
ADD . .

# Install build dependencies
RUN apt-get update && apt-get install -y git

# Set build environment variables
ENV CGO_CFLAGS="-O -D__BLST_PORTABLE__"
ENV CGO_CFLAGS_ALLOW="-O -D__BLST_PORTABLE__"

# Build each component directly with go build
RUN cd op-node && \
    GITCOMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown") && \
    GITDATE=$(git show -s --format='%ct' 2>/dev/null || echo "0") && \
    LDFLAGS="-X main.GitCommit=${GITCOMMIT} -X main.GitDate=${GITDATE} -X github.com/ethereum-optimism/optimism/op-node/version.Version=${VERSION}" && \
    CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags "${LDFLAGS}" -o ./bin/op-node ./cmd/main.go

RUN cd op-batcher && \
    GITCOMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown") && \
    GITDATE=$(git show -s --format='%ct' 2>/dev/null || echo "0") && \
    LDFLAGS="-X main.GitCommit=${GITCOMMIT} -X main.GitDate=${GITDATE} -X main.Version=${VERSION}" && \
    CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags "${LDFLAGS}" -o ./bin/op-batcher ./cmd

RUN cd op-proposer && \
    GITCOMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown") && \
    GITDATE=$(git show -s --format='%ct' 2>/dev/null || echo "0") && \
    LDFLAGS="-X main.GitCommit=${GITCOMMIT} -X main.GitDate=${GITDATE} -X main.Version=${VERSION}" && \
    CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags "${LDFLAGS}" -o ./bin/op-proposer ./cmd

FROM debian:bookworm
RUN apt-get update -y
RUN apt-get install -y curl
RUN apt-get install -y ca-certificates

WORKDIR /app
COPY --from=builder /build/op-node/bin/op-node .
COPY --from=builder /build/op-batcher/bin/op-batcher .
COPY --from=builder /build/op-proposer/bin/op-proposer .