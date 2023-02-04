FROM golang:1.20-buster as builder

WORKDIR /

COPY go.mod go.mod
COPY go.sum go.sum
COPY vendor/ vendor/
COPY cmd cmd
COPY Makefile Makefile

RUN make build-controller

FROM ubuntu:22.04
WORKDIR /
COPY --from=builder /bin/orion-controller  .

ENTRYPOINT ["/orion-controller"]
