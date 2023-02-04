FROM golang:1.20-buster as builder

WORKDIR /

COPY go.mod go.mod
COPY go.sum go.sum
COPY vendor/ vendor/
COPY cmd cmd
COPY Makefile Makefile

RUN make build-cni

FROM ubuntu:22.04
WORKDIR /
COPY --from=builder /bin/orion-cni  .
COPY build/cni/install.sh .
COPY build/cni/01-orion.conf .

ENTRYPOINT ["/install.sh"]
